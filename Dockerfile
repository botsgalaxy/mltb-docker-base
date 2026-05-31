# MLTB Docker Base Image — transparent rebuild of anasty17/mltb.
# https://github.com/botsgalaxy/mltb-docker-base
#
# Everything is inline; no hidden BuildKit secret (unlike the upstream image).
# This is a BASE image: it ships the runtime/binaries only. The bot source is
# layered on top by the consumer (FROM mltb-base; COPY . .) — see examples/.
#
# Build:   docker build -t mltb-base .

FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---------------------------------------------------------------------------
# 1. Bootstrap: tools needed to add repositories
# ---------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        gnupg \
        ca-certificates \
        curl \
        unzip \
        locales \
        xz-utils && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 2. Repositories: universe/multiverse + qBittorrent and SABnzbd PPAs
#    (these PPAs provide prebuilt qbittorrent-nox + libtorrent and SABnzbd)
# ---------------------------------------------------------------------------
RUN add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    add-apt-repository -y restricted && \
    add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable && \
    add-apt-repository -y ppa:jcfp/nobetas && \
    apt-get update

# ---------------------------------------------------------------------------
# 3. Core download/processing tooling
# ---------------------------------------------------------------------------
RUN apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        gcc \
        g++ \
        aria2 \
        qbittorrent-nox \
        sabnzbdplus \
        python3-sabctools \
        ffmpeg \
        mediainfo \
        libmediainfo0v5 \
        libmagic1t64 \
        7zip \
        7zip-rar \
        atomicparsley \
        cabextract \
        jq \
        pv \
        zstd \
        default-jre \
        git \
        curl && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 4. Python dependencies — installed from the Ubuntu archive as python3-*
#    packages (matches upstream: no pip, avoids EXTERNALLY-MANAGED friction
#    on Python 3.14). Transitive deps (jaraco.*, rebulk, babelfish, etc.)
#    are pulled in automatically.
# ---------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apprise \
        python3-cryptography \
        python3-requests \
        python3-requests-oauthlib \
        python3-oauthlib \
        python3-jwt \
        python3-bcrypt \
        python3-feedparser \
        python3-guessit \
        python3-orjson \
        python3-yaml \
        python3-dateutil \
        python3-rarfile \
        python3-puremagic \
        python3-markdown \
        python3-cheroot \
        python3-cherrypy3 \
        python3-gi \
        python3-dbus \
        python3-socks \
        python3-chardet \
        python3-certifi && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 5. rclone — official static release binary (not the apt package)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://downloads.rclone.org/rclone-current-linux-amd64.zip -o /tmp/rclone.zip && \
    cd /tmp && unzip -q rclone.zip && \
    cp rclone-*-linux-amd64/rclone /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    rm -rf /tmp/rclone.zip /tmp/rclone-*-linux-amd64

# ---------------------------------------------------------------------------
# 6. JDownloader (headless .jar, run via the bundled JRE)
# ---------------------------------------------------------------------------
RUN mkdir -p /JDownloader && \
    curl -fsSL https://installer.jdownloader.org/JDownloader.jar \
        -o /JDownloader/JDownloader.jar

CMD ["/bin/bash"]
