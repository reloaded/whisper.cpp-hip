# Project: whisper.cpp-hip

Builds and publishes multi-architecture container images of
[whisper.cpp](https://github.com/ggml-org/whisper.cpp) compiled with
the **ROCm/HIP** backend (`GGML_HIP=ON`) for AMD-GPU-accelerated
inference. The product of this repository is a `Dockerfile` and a
release pipeline — nothing else. Keep the surface that small.

## What this repo is (and is not)

- **Is:** a reproducible, pinned build of upstream whisper.cpp with the
  HIP backend enabled, published to GHCR on version tags.
- **Is not:** a fork of whisper.cpp, an application, or a place for
  feature work. Track upstream; do not patch it unless a build fix is
  unavoidable, and if so keep the patch minimal and documented.

## Repository layout

- `Dockerfile` — the HIP/ROCm build (added in a follow-up change).
- `.github/workflows/` — CI (lint on PRs) + release (tag → GHCR).
- `.devcontainer/` — dev environment (docker-in-docker, lint tools).
- `CLAUDE.md` — this file: conventions any contributor (human or
  agent) follows.

## Build / release model

- Image targets AMD GPUs via ROCm/HIP. Supported GPU architectures
  (e.g. `gfx1100`) are passed as a build argument and recorded in the
  README and release notes — never silently changed.
- **Pin everything.** Base image, ROCm version, and the upstream
  whisper.cpp ref are build args with explicit defaults. A build must
  be reproducible from a tag alone.
- **Releases are tag-driven.** Pushing a semver tag (`vX.Y.Z`) builds
  the multi-arch image and pushes it to GHCR. No manual pushes.
- Image tags track the upstream whisper.cpp version plus a build
  revision; the scheme is documented in the README. Don't repurpose an
  already-published tag.

## Commit style

- Concise, imperative mood, 1–2 sentence summary focused on *why*.
- **Do not** add `Co-Authored-By` trailers to commit messages.
- One logical change per commit.

## Git workflow

- **NEVER commit directly to `main` or push to `main`. All work is done
  on a feature branch.** The only exception is the very first
  repository-seeding commit on an empty repo (bootstrap), which by
  definition has no branch to target.
- Create a `workitem/<short-topic>` branch before making changes (e.g.
  `workitem/add-dockerfile`).
- One logical task = **one commit** (squash locally if a task sprawled
  across several WIP commits). PRs are **squash-merged**, so the PR
  title becomes the final commit message — make it a clear, concise
  imperative sentence.
- When a task is complete: stage the changed files, commit, push the
  branch, and open a **draft** PR (`gh pr create --draft`) if one does
  not exist. Do not flip a PR's draft/ready state on later pushes.
- The PR body summarizes the full scope so a reviewer needn't read
  every commit. Don't merge another contributor's PR without approval;
  the maintainer marks ready and merges.

### GitHub `#N` autolink hygiene

GitHub auto-links a bare `#N` to issue/PR N everywhere — titles,
bodies, comments. Only write `#N` when you mean a real issue/PR
cross-reference. For anything else (ordered list items, option
numbers, version components), write "item N" / "step N" so the title
doesn't render a broken autolink in every list view. Before
submitting a `gh pr`/`gh issue` command, scan the title and body for
stray `#<low-number>` and rewrite the non-references.

## Concurrent work with worktrees

(There is intentionally no separate `docs/worktrees.md` — worktree
guidance lives here.)

Multiple agent or developer sessions can work in parallel. Each
session **must** use a git worktree so branches don't collide in one
working copy.

- Start a task by creating a worktree for your branch:
  `git worktree add ../wt-<topic> -b workitem/<topic>` (or check out an
  existing branch into a fresh worktree).
- Each worktree is an isolated working directory sharing the repo's
  git history. Two worktrees cannot check out the same branch at once.
- Pull `main` and rebase/merge before starting so the branch is
  current.
- After the PR merges, remove the worktree: `git worktree remove
  ../wt-<topic>`.
- Worktrees are local-only; they are never pushed. To continue a
  branch on another machine: `git fetch origin` then
  `git worktree add ../wt-<topic> origin/workitem/<topic>`.

## Self-improvement

When you learn a durable, repo-wide lesson — a convention discovered,
a recurring mistake, a build gotcha that wasted time — **add it to
this `CLAUDE.md` via a small focused PR**, don't just keep it in
ephemeral context. The PR gives the maintainer oversight while letting
the conventions compound over time. Scope it tightly (conventions and
gotchas, not one-off task state), title it clearly as a
convention/process change, and bias to doing it proactively the moment
the lesson is clear.

## Hard rules

- This is a **public** repository. Never commit secrets, credentials,
  private hostnames, internal infrastructure details, employer or
  organization names, or anything that is not strictly about building
  whisper.cpp with HIP. When in doubt, leave it out.
- Never weaken provenance: no unsigned base images, no unpinned
  upstream refs, no curl-pipe-to-shell of unverified sources in the
  image build.
