# Example: how mirror-leech-telegram-bot layers its source onto the base image.
# This mirrors the upstream repo's own Dockerfile pattern.
#
#   # 1. build the base once (from the repo root):
#   docker build -t mltb-base ..
#
#   # 2. drop this file into a checkout of the bot and build:
#   git clone https://github.com/anasty17/mirror-leech-telegram-bot
#   cd mirror-leech-telegram-bot
#   docker build -t mltb-bot -f /path/to/this/Dockerfile .

FROM mltb-base

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# Bring in the bot source (config_sample.py -> config.py, etc.)
COPY . .

# Upstream installs any remaining pip-only requirements here, e.g.:
# RUN pip install --break-system-packages --no-cache-dir -r requirements.txt

CMD ["bash", "start.sh"]
