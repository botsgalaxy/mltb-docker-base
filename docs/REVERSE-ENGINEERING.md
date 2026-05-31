# Reverse-engineering `anasty17/mltb`

This documents how the base image was analyzed and how the Dockerfile in this
repo was reconstructed. Everything here was derived from the **publicly
distributed** image (`docker pull anasty17/mltb`) — no private data, secrets,
or credentials were involved.

## 1. The build is hidden behind a BuildKit secret

`docker history` shows a single opaque instruction:

```
RUN |1 DEBIAN_FRONTEND=noninteractive /bin/sh -c bash /run/secrets/secretxt
```

The entire build runs from a script mounted as a **BuildKit secret**
(`--mount=type=secret,id=secretxt`). Secret mounts are never written to any
layer, so the commands cannot be read back from image history. That's the only
"obfuscation" in play — and it's defeated simply by inspecting the resulting
filesystem.

## 2. Identify the base

```
$ docker inspect anasty17/mltb:latest   # labels
org.opencontainers.image.title: ubuntu
org.opencontainers.image.version: 26.04
```

The `/.rock/metadata.yaml` file confirms a Canonical **rockcraft** "bare" rock
of Ubuntu 26.04 (codename *resolute*). The standard `ubuntu:26.04` image is a
functionally equivalent starting point.

## 3. Recover installed components

Binaries and versions, read directly from the running image:

```
$ docker run --rm anasty17/mltb bash -c 'python3 --version; aria2c --version | head -1; \
    qbittorrent-nox --version; ffmpeg -version | head -1; rclone --version | head -1'
Python 3.14.4
aria2 version 1.37.0
qBittorrent v5.2.1
ffmpeg version 8.0.1
rclone v1.74.2
```

## 4. Recover repositories (the key to the prebuilt bits)

```
$ ls /etc/apt/sources.list.d/
jcfp-ubuntu-nobetas-resolute.sources
qbittorrent-team-ubuntu-qbittorrent-stable-resolute.sources
ubuntu.sources
```

Two PPAs supply the heavy prebuilt packages:

- `ppa:qbittorrent-team/qbittorrent-stable` → qbittorrent-nox 5.2.1 + libtorrent 2.0
- `ppa:jcfp/nobetas` → SABnzbd 5.x + sabctools

`ubuntu.sources` shows `universe multiverse restricted` enabled across
`resolute`, `-updates`, `-backports`, `-security`.

## 5. Determine how Python deps were installed

```
$ python3 -c "import apprise; print(apprise.__file__)"
/usr/lib/python3/dist-packages/apprise/__init__.py        # dist-packages => apt, not pip
$ dpkg -l | awk '/^ii/ && $2 ~ /^python3/ {print $2}'      # full list
```

All dependencies resolve to Ubuntu archive packages (`python3-*`, plus
`apprise`), and `pip freeze` versions match the `dpkg` versions exactly. The
`EXTERNALLY-MANAGED` marker is present and there is no pip override — confirming
**apt, not pip**, was used. (Note the notification library is packaged as
`apprise`, not `python3-apprise`.)

## 6. rclone and JDownloader

- `rclone version` reports a static Go build with no tags — i.e. the official
  release binary, not the apt package.
- `/JDownloader/JDownloader.jar` is the headless jar, run via the bundled JRE.

## 7. Reconstruct and verify

The recovered facts map directly to [`../Dockerfile`](../Dockerfile). The
rebuilt image was verified to produce identical tool versions and a passing
Python import smoke test, at a slightly smaller size (headless JRE + no apt
cache retained in layers).
