#!/usr/bin/env bash
# Build the app and ship it to the Lightsail or EC2 box. Safe to rerun.
# Usage: scripts/deploy.sh <host>     e.g. scripts/deploy.sh 44-1-2-3.sslip.io
set -euo pipefail

# Set these once per project.
APP=app            # service name: /srv/$APP, /etc/$APP.env. Rust: the Cargo binary name too.
STACK=rust         # rust | python | static
SERVER_DIR=server  # Rust crate, or Python project with pyproject.toml + uv.lock
WEB_DIR=web        # Vite app, built into dist/
QDRANT=no          # yes: run Qdrant in Docker on the box, at 127.0.0.1:6333
# Keys copied from .env to the box on first deploy.
ENV_KEYS=(LLM_PROVIDER BEDROCK_MODEL_ID AWS_REGION ANTHROPIC_API_KEY QDRANT_URL)

HOST=${1:?usage: scripts/deploy.sh <host>}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/$APP-deploy
STAGE=$CACHE/stage
SSH=(ssh -o StrictHostKeyChecking=accept-new "ubuntu@$HOST")
rm -rf "$STAGE" && mkdir -p "$STAGE"

echo "1/4 Build the server ($STACK)"
case $STACK in
  rust)
    # Docker: this machine's glibc is newer than the box's.
    mkdir -p "$CACHE/cargo" "$CACHE/target"
    docker run --rm --user "$(id -u):$(id -g)" \
      -v "$ROOT:/src:ro" -v "$CACHE/cargo:/cargo" -v "$CACHE/target:/target" \
      -e CARGO_HOME=/cargo -e CARGO_TARGET_DIR=/target -w "/src/$SERVER_DIR" \
      rust:1-bookworm cargo build --release --locked
    cp "$CACHE/target/release/$APP" "$STAGE/server"
    ;;
  python)
    # Source only: the box runs uv sync itself.
    mkdir -p "$STAGE/server"
    tar -C "$ROOT/$SERVER_DIR" --exclude=.venv --exclude=__pycache__ --exclude=.env -c . | tar -C "$STAGE/server" -x
    ;;
  static) ;;
  *) echo "STACK must be rust, python or static" >&2; exit 1 ;;
esac

echo "2/4 Build the web app"
if [ -d "$ROOT/$WEB_DIR" ]; then
  (cd "$ROOT/$WEB_DIR" && pnpm build)
  cp -r "$ROOT/$WEB_DIR/dist" "$STAGE/web"
fi

echo "3/4 Server settings (first deploy only; secrets come from .env, never from the repo)"
if [ "$STACK" != static ] && ! "${SSH[@]}" test -f "/etc/$APP.env"; then
  set -a; . "$ROOT/.env"; set +a
  {
    for key in "${ENV_KEYS[@]}"; do
      if [ -n "${!key:-}" ]; then echo "$key=${!key}"; fi
    done
    # Lightsail can't take an IAM role, so the app user's keys go here (aws.md, AWS-09).
    if [ -n "${APP_AWS_ACCESS_KEY_ID:-}" ]; then
      echo "AWS_ACCESS_KEY_ID=$APP_AWS_ACCESS_KEY_ID"
      echo "AWS_SECRET_ACCESS_KEY=${APP_AWS_SECRET_ACCESS_KEY:?missing in .env}"
    fi
    echo "APP_URL=https://$HOST"
    echo "PORT=3000"
  } | "${SSH[@]}" "sudo sh -c 'umask 077; cat > /etc/$APP.env'"
fi

echo "4/4 Upload and restart"
sed "s/APP_NAME/$APP/g" "$ROOT/deploy/app.service" > "$STAGE/app.service"
sed "s/APP_NAME/$APP/g; s/APP_HOST/$HOST/g" "$ROOT/deploy/Caddyfile" > "$STAGE/Caddyfile"
cp "$ROOT/deploy/setup.sh" "$STAGE/"
tar -C "$STAGE" -cz . | "${SSH[@]}" \
  "rm -rf /tmp/$APP-up && mkdir /tmp/$APP-up && tar -xz -C /tmp/$APP-up && sudo bash /tmp/$APP-up/setup.sh $APP $STACK $QDRANT"

echo "Live: https://$HOST"
