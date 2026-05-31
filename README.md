# MLTB Docker Base Image

A transparent, fully-buildable reconstruction of the **`anasty17/mltb`** base
image used by [mirror-leech-telegram-bot][mltb].

The upstream image is published to Docker Hub without its Dockerfile — the
build is executed from a BuildKit secret, so `docker history` reveals nothing.
This repo provides a clean, readable Dockerfile that reproduces a functionally
equivalent base image from public packages only.

> [!NOTE]
> **Unofficial.** This project is not affiliated with, endorsed by, or
> supported by the upstream maintainer. It is an independent reconstruction
> derived by inspecting the publicly distributed image. The bot itself lives
> at [anasty17/mirror-leech-telegram-bot][mltb] under its own license.

## What's inside

This is a **base image** — it ships the runtime and download/processing
binaries only. The bot's own source is layered on top by the consumer
(see [`examples/Dockerfile`](examples/Dockerfile)).

| Component | Version | Source |
|-----------|---------|--------|
| Ubuntu | 26.04 (resolute) | `ubuntu:26.04` |
| Python | 3.14 | Ubuntu archive |
| aria2 | 1.37.0 | Ubuntu archive |
| qBittorrent (nox) + libtorrent | 5.2.1 / 2.0 | `ppa:qbittorrent-team/qbittorrent-stable` |
| SABnzbd + sabctools | 5.x | `ppa:jcfp/nobetas` |
| ffmpeg | 8.0.1 | Ubuntu archive |
| MediaInfo | 26.01 | Ubuntu archive |
| 7zip (+ rar) | 26.00 | Ubuntu archive |
| OpenJDK (for JDownloader) | 25 | Ubuntu archive |
| rclone | 1.74.2 | official static release |
| JDownloader | latest | installer.jdownloader.org |

Python dependencies are installed from the Ubuntu archive as `python3-*` /
`apprise` packages rather than via pip — matching upstream and avoiding the
`EXTERNALLY-MANAGED` restriction on Python 3.14.

## Usage

### Build the base image

```bash
docker build -t mltb-base .
```

### Layer the bot on top

```bash
git clone https://github.com/anasty17/mirror-leech-telegram-bot
cd mirror-leech-telegram-bot
cp /path/to/this/examples/Dockerfile .
docker build -t mltb-bot .
```

See [`examples/Dockerfile`](examples/Dockerfile) for the pattern.

### Verify

```bash
docker run --rm mltb-base bash -c '
  python3 --version; aria2c --version | head -1; qbittorrent-nox --version
  rclone --version | head -1
  python3 -c "import apprise, cryptography, requests, guessit; print(\"imports OK\")"
'
```

## How this was reconstructed

The full reverse-engineering process — how the build was hidden and how each
component was recovered from the image filesystem — is documented in
[`docs/REVERSE-ENGINEERING.md`](docs/REVERSE-ENGINEERING.md).

## License

The Dockerfile and scripts in this repository are released under the
[MIT License](LICENSE). They are original work and contain no upstream source
code. The bot they support is licensed separately by its own authors.

[mltb]: https://github.com/anasty17/mirror-leech-telegram-bot
