# whisper.cpp-hip

Multi-architecture container images of
[whisper.cpp](https://github.com/ggml-org/whisper.cpp) built with the
**ROCm/HIP** backend (`GGML_HIP=ON`) for GPU-accelerated speech
recognition on AMD GPUs.

Upstream whisper.cpp publishes CPU and CUDA images only — there is no
official HIP/ROCm image. This repository builds one from source,
pinned and reproducible, and publishes it to the GitHub Container
Registry (GHCR).

## Why

`whisper.cpp` has a first-class ROCm/HIP backend, but consuming it
otherwise means building from source on every host. This repo does
that build once, in CI, and ships a ready-to-run image so an AMD-GPU
host can `docker run` Whisper inference without a local toolchain.

## Status

Bootstrapping. This change establishes the repository scaffold
(dev environment, conventions, license). The build itself —
`Dockerfile`, supported GPU targets, image tags, and the
tag-triggered GHCR release pipeline — lands in the next change.

## Planned usage (subject to change until the build lands)

```bash
docker pull ghcr.io/reloaded/whisper-cpp-hip:<tag>
```

Image tags will encode the upstream whisper.cpp version plus a build
revision; supported AMD GPU architectures (e.g. `gfx1100`) will be
listed here once the `Dockerfile` is added.

## Build (local)

The dev container ships docker (with buildx) and lint tooling. Once
the `Dockerfile` lands, a local multi-arch build will be:

```bash
docker buildx build --build-arg GPU_TARGETS=gfx1100 -t whisper-cpp-hip:dev .
```

## Releases

Pushing a semantic-version tag (`vX.Y.Z`) triggers CI to build the
multi-architecture image and push it to GHCR. There are no manual
image pushes.

## Contributing

Conventions (git workflow, commit style, worktree-based concurrency,
build/release rules) live in [`CLAUDE.md`](CLAUDE.md). In short:
feature branches only, draft PRs, squash-merge, pin everything in the
build.

## License

[MIT](LICENSE). This repository packages upstream whisper.cpp (also
MIT); bundled components retain their own licenses.
