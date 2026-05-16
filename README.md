# whisper.cpp-hip

Container image of [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
built with the **ROCm/HIP** backend (`GGML_HIP=ON`) for
GPU-accelerated speech recognition on AMD GPUs.

Upstream whisper.cpp publishes CPU and CUDA images only — there is no
official HIP/ROCm image. This repository builds one from source,
pinned and reproducible, and publishes it to the GitHub Container
Registry (GHCR).

## Why

`whisper.cpp` has a first-class ROCm/HIP backend, but consuming it
otherwise means building from source on every host. This repo does
that build once, in CI, and ships a ready-to-run image so an AMD-GPU
host can `docker run` Whisper inference without a local toolchain.

## Image

```
ghcr.io/reloaded/whisper-cpp-hip:<tag>
```

Tags (set by the release pipeline from the pushed git tag):

| Tag | Meaning |
|-----|---------|
| `X.Y.Z` | exact release |
| `X.Y` | latest patch of that minor |
| `latest` | newest release |

`linux/amd64` only — ROCm has no arm64 distribution, so no multi-arch
manifest is published.

## Usage

Models are **not** baked into the image (large, use-specific). Mount a
directory containing a whisper `ggml-*.bin` model at `/models` and
expose the AMD GPU devices:

```bash
docker run --rm \
  --device /dev/kfd --device /dev/dri \
  --security-opt seccomp=unconfined --group-add video \
  -v "$PWD/models:/models" \
  -p 8080:8080 \
  ghcr.io/reloaded/whisper-cpp-hip:latest \
  -m /models/ggml-base.en.bin
```

The container runs whisper.cpp's bundled HTTP server on `:8080`
(`/inference` plus an OpenAI-shaped transcription route).

## Build (local)

The dev container ships docker (buildx) and lint tooling. All inputs
are pinned `--build-arg`s (see the `Dockerfile` for current defaults):

```bash
docker buildx build \
  --build-arg ROCM_VERSION=6.2.4 \
  --build-arg WHISPER_CPP_REF=v1.7.4 \
  --build-arg GPU_TARGETS=gfx1100 \
  -t whisper-cpp-hip:dev .
```

`GPU_TARGETS` is an AMDGPU LLVM arch (e.g. `gfx1100` = RDNA3 /
RX 7900). Set it to your card's arch; building for an arch the GPU
doesn't match yields a binary that won't run on it.

## Releases

Pushing a semantic-version tag triggers CI to build and push the
image. There are no manual image pushes.

```bash
git tag v0.1.0 && git push origin v0.1.0
```

PR CI is lint-only (hadolint + shellcheck + a no-execution BuildKit
`--check`); the full ROCm compile runs only on a tag.

## Contributing

Conventions (git workflow, commit style, worktree-based concurrency,
build/release rules) live in [`CLAUDE.md`](CLAUDE.md): feature
branches only, draft PRs, squash-merge, pin everything in the build.

## License

[MIT](LICENSE). This repository packages upstream whisper.cpp (also
MIT); bundled components retain their own licenses.
