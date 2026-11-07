#!/usr/bin/env bash
# Runs on the box as root, from the folder scripts/deploy.sh uploaded. Safe to rerun.
# Usage: setup.sh <app> <stack> <qdrant yes|no>
set -euo pipefail
APP=${1:?app}
STACK=${2:?stack}
QDRANT=${3:-no}
QDRANT_IMAGE=qdrant/qdrant:v1.20.0  # to change it: docker rm -f qdrant, then rerun
cd "$(dirname "$0")"

command -v caddy >/dev/null || { apt-get update -q; apt-get install -y -q caddy; }
id "$APP" &>/dev/null || useradd --system --no-create-home --shell /usr/sbin/nologin "$APP"
mkdir -p "/srv/$APP"

if [ -e server ]; then
  rm -rf "/srv/$APP/server" && cp -r server "/srv/$APP/server"
fi
if [ "$STACK" = python ]; then
  command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL=/usr/local/bin sh
  # Python and the venv live under /srv, so the service user can read them.
  (cd "/srv/$APP/server" && UV_PYTHON_INSTALL_DIR="/srv/$APP/python" UV_CACHE_DIR=/var/cache/uv uv sync --frozen --no-dev)
fi

rm -rf "/srv/$APP/web"
if [ -d web ]; then cp -r web "/srv/$APP/web"; fi

if [ "$QDRANT" = yes ]; then
  command -v docker >/dev/null || { apt-get update -q; apt-get install -y -q docker.io; }
  # Bound to 127.0.0.1: the app reaches it, the internet can't. Data survives redeploys in /srv/qdrant.
  docker inspect qdrant &>/dev/null || docker run -d --name qdrant --restart unless-stopped \
    -p 127.0.0.1:6333:6333 -v /srv/qdrant:/qdrant/storage "$QDRANT_IMAGE"
fi

if [ "$STACK" != static ]; then
  install -m 644 app.service "/etc/systemd/system/$APP.service"
  systemctl daemon-reload
  systemctl enable "$APP"
  systemctl restart "$APP"
fi
install -m 644 Caddyfile /etc/caddy/Caddyfile
systemctl reload caddy || systemctl restart caddy
