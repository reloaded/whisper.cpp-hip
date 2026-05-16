# whisper.cpp-hip

Multi-architecture container images of
[whisper.cpp](https://github.com/ggml-org/whisper.cpp) built with the
**ROCm/HIP** backend (`GGML_HIP=ON`) for GPU-accelerated speech
recognition on AMD GPUs.

Upstream whisper.cpp publishes CPU and CUDA images only — there is no
official HIP/ROCm image. This repository builds one from source and
publishes it to GHCR.

> Bootstrapping in progress. Build instructions, supported GPU
> targets, and image tags are added in follow-up changes.
