# syntax=docker/dockerfile:1.7

# whisper.cpp built with the ROCm/HIP backend (GGML_HIP=ON) for AMD GPUs.
#
# Everything that determines the build is an ARG with a pinned default,
# so an image is reproducible from a tag alone. Bump deliberately.
#
#   ROCM_VERSION     ROCm release; must support the chosen GPU_TARGETS.
#   WHISPER_CPP_REF  upstream git ref (a release tag), pinned.
#   GPU_TARGETS      AMDGPU LLVM targets, e.g. gfx1100 (RDNA3 / RX 7900).
#
# ROCm has no arm64 distribution, so this image is linux/amd64 only —
# the release workflow does not fake a multi-arch manifest.

ARG ROCM_VERSION=6.2.4

# ---------------------------------------------------------------------------
# Builder — full ROCm toolchain (hipcc, rocBLAS dev, cmake) to compile.
# ---------------------------------------------------------------------------
FROM rocm/dev-ubuntu-22.04:${ROCM_VERSION}-complete AS builder

ARG WHISPER_CPP_REF=v1.7.4
ARG GPU_TARGETS=gfx1100

# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git ca-certificates cmake build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${WHISPER_CPP_REF}" \
      https://github.com/ggml-org/whisper.cpp.git .

# GGML_HIP=ON selects the HIP/ROCm backend. AMDGPU_TARGETS pins the
# GPU arch so the kernels are built for the card we run on. ROCm lives
# at /opt/rocm; point CMake/HIP at it explicitly.
ENV ROCM_PATH=/opt/rocm
ENV PATH=/opt/rocm/bin:${PATH}
RUN cmake -S . -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DGGML_HIP=ON \
      -DAMDGPU_TARGETS="${GPU_TARGETS}" \
      -DCMAKE_HIP_ARCHITECTURES="${GPU_TARGETS}" \
      -DWHISPER_BUILD_SERVER=ON \
 && cmake --build build --config Release -j"$(nproc)" \
      --target whisper-server whisper-cli \
 && cmake --install build --prefix /opt/whisper

# ---------------------------------------------------------------------------
# Runtime — ROCm runtime libs only (no -complete dev toolchain).
# ---------------------------------------------------------------------------
FROM rocm/dev-ubuntu-22.04:${ROCM_VERSION} AS runtime

ARG ROCM_VERSION
ARG WHISPER_CPP_REF
ARG GPU_TARGETS

LABEL org.opencontainers.image.source="https://github.com/reloaded/whisper.cpp-hip" \
      org.opencontainers.image.description="whisper.cpp (ROCm/HIP, GGML_HIP=ON) for AMD GPUs" \
      org.opencontainers.image.licenses="MIT" \
      io.whisper-cpp-hip.rocm-version="${ROCM_VERSION}" \
      io.whisper-cpp-hip.whisper-cpp-ref="${WHISPER_CPP_REF}" \
      io.whisper-cpp-hip.gpu-targets="${GPU_TARGETS}"

# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid 10001 whisper

COPY --from=builder /opt/whisper /opt/whisper

ENV PATH=/opt/whisper/bin:/opt/rocm/bin:${PATH}

# Models are large and license/use-specific: never baked in. Mount or
# download into /models at run time.
RUN mkdir -p /models && chown whisper:whisper /models
VOLUME ["/models"]

USER whisper
WORKDIR /models
EXPOSE 8080

# whisper.cpp's bundled HTTP server (OpenAI-shaped transcription route
# plus /inference). Override the model with `-m /models/<file>.bin`.
ENTRYPOINT ["whisper-server", "--host", "0.0.0.0", "--port", "8080"]
CMD ["--help"]
