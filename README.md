# motion-docker-arm64

Automated ARM64 Docker image for [Motion-Project/motion](https://github.com/Motion-Project/motion), built and pushed via GitHub Actions to GHCR.

## Image

```bash
docker pull ghcr.io/<owner>/motion-docker-arm64:latest
```

Built for `linux/arm64` only.

## Usage

```bash
docker run --rm \
  -p 8080:8080 \
  -v ./motion.conf:/etc/motion/motion.conf \
  ghcr.io/<owner>/motion-docker-arm64:latest
```

Ports:
- **8080** — web control interface
- **8081** — stream interface

## Build

This is handled automatically by the GitHub Actions workflow on every push to `main`/`master`. Manual trigger is also available via `workflow_dispatch`.

The Dockerfile builds motion from source (default: `release-4.7.1`) on Debian Bookworm and produces a slim runtime image.
