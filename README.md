# nono Kata qualification fixture

A disposable amd64 container image used to test whether a nono sandbox behaves
correctly inside a Kata Containers guest. It is **not** a production image and
not a general-purpose agent environment.

## What is in the image

| Element | Value |
| --- | --- |
| Base | `docker.io/library/busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662` |
| Binary | nono `v0.80.0`, source commit `8bb041356d48f771a221e58c98d9b1ff442e76fe` |
| Binary SHA-256 | `a66396777ed756dff196ef61cf704abd4feebf58599d41e2da3363bbe90e22af` |
| Release archive SHA-256 | `cae6755f1188b561ea02f62995feb8ad87d457f6d5255956ec54f41bbefca31e` |
| Fixtures | `/fixtures/allowed`, `/fixtures/restricted`, `/fixtures/unrelated` |
| Identity | `USER 10001:10001`, `HOME=/state`, `WORKDIR=/work` |
| Entrypoint | `/usr/local/bin/nono` |

The image contains no credentials, no repository content and no writable host
paths. `Containerfile` is the entire build definition.

## Published reference

`ghcr.io/nephilus/nono-kata-fixture@sha256:c6ff8bbfcdd21ee42feae04a8f0a0503990215e3852ad18324c25838fe673562`

Published 2026-10-26 from commit `b767c90` by the workflow below. The package is
public: the registry returns an anonymous pull token and the manifest to an
unauthenticated client.

Pin by digest, never by tag:

```sh
podman pull ghcr.io/nephilus/nono-kata-fixture@sha256:c6ff8bbfcdd21ee42feae04a8f0a0503990215e3852ad18324c25838fe673562
```

Verified after publication, anonymously:

| Check | Observed |
| --- | --- |
| Anonymous manifest fetch | HTTP 200 with a registry token issued without credentials |
| Image config digest | `sha256:676a3a6eaa08c08fcbfc4a92298ca760990e1ab006f9af837b8e834a5b2f55f9` |
| `/usr/local/bin/nono` SHA-256 | `a66396777ed756dff196ef61cf704abd4feebf58599d41e2da3363bbe90e22af`, matching the pinned value |
| `nono --version` | `nono 0.80.0` |
| Process identity | `uid=10001(10001) gid=10001(10001)` |
| Fixture contents | `allowed fixture`, `restricted fixture`, `unrelated fixture` |

This manifest digest differs from the 2026-10-25 local build
(`sha256:99c7f53f5973d1b805baac90ccb215163273f19a4661d236711a39e821bb12a5`)
because that build was produced offline with `--pull=never` and a different
layer set. Content identity is established by the matching binary hash, config
and fixtures above, not by manifest-digest equality.

## Publishing

`.github/workflows/publish-image.yml` runs on every push to `main` and on
manual dispatch. It uses the repository's built-in `GITHUB_TOKEN` with
`packages: write`, so no personal access token or organization grant is
involved. It verifies both the release archive and the extracted binary by
SHA-256 before building, and it exercises the image locally before pushing.

## How this is used

The qualification harness renders a Sandbox resource that pins this image by
digest, admits it on a worker with the `kata-qemu` RuntimeClass, attaches to
the supervised shell and records whether the guest actually enforces the
requested restrictions. An admitted Pod or a successful `pull` is not runtime
acceptance.
