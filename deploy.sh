#!/bin/bash
#
# Deploy the Chemical Playground binary to the server.
#
# Authentication is key-only. The private key is never read from a command
# line, never printed, and never stored in this repository:
#
#   DEPLOY_SSH_KEY_FILE        path to the deploy private key (default ~/.ssh/chemical_playground_deploy)
#   DEPLOY_KNOWN_HOSTS_FILE    pinned known_hosts file (default ~/.ssh/chemical_playground_known_hosts)
#
# The old DEPLOY_PASSWORD/sshpass path is intentionally gone.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/deploy.env"
REPO="chemicallang/playground"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { printf '%bError:%b %s\n' "$RED" "$NC" "$1" >&2; exit 1; }
info()  { printf '%bInfo:%b %s\n' "$GREEN" "$NC" "$1"; }
warn()  { printf '%bWarning:%b %s\n' "$YELLOW" "$NC" "$1"; }

# --- Argument parsing -------------------------------------------------------
USE_RELEASE=false
VERSION="latest"
USE_TCC=true
INPUT_PATH=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --use-release) USE_RELEASE=true ;;
        --version) VERSION="${2:-}"; shift ;;
        --no-tcc) USE_TCC=false ;;
        -i) INPUT_PATH="${2:-}"; shift ;;
        -h|--help)
            cat <<'EOF'
Usage: deploy.sh [--use-release] [--version TAG] [--no-tcc] [-i BINARY]

  --use-release     download pg-linux-x64[-tcc] from GitHub Releases
  --version TAG     release tag (default: latest)
  --no-tcc          use the LLVM variant instead of the TCC variant
  -i BINARY         upload a local binary instead of downloading a release

Environment (from deploy.env or the CI job):
  DEPLOY_USER, DEPLOY_HOST, DEPLOY_PORT, DEPLOY_PATH,
  DEPLOY_SSH_KEY_FILE, DEPLOY_KNOWN_HOSTS_FILE
EOF
            exit 0
            ;;
        *) error "unknown parameter: $1" ;;
    esac
    shift
done

# --- Environment ------------------------------------------------------------
if [ -f "$ENV_FILE" ]; then
    info "Loading environment from $ENV_FILE"
    set -a
    # shellcheck disable=SC1090
    . "$ENV_FILE"
    set +a
else
    warn "$ENV_FILE not found, using environment variables"
fi

: "${DEPLOY_USER:=deploy}"
: "${DEPLOY_HOST:=}"
: "${DEPLOY_PORT:=22}"
: "${DEPLOY_PATH:=/home/playground/app}"
: "${DEPLOY_SSH_KEY_FILE:=$HOME/.ssh/chemical_playground_deploy}"
: "${DEPLOY_KNOWN_HOSTS_FILE:=$HOME/.ssh/chemical_playground_known_hosts}"
: "${ASSETS_DIR:=$SCRIPT_DIR/src/assets}"

[ -n "$DEPLOY_HOST" ] || error "DEPLOY_HOST is not set"
[ -f "$DEPLOY_SSH_KEY_FILE" ] || error "deploy SSH key not found: $DEPLOY_SSH_KEY_FILE (run scripts/setup-server.sh first)"
[ -f "$DEPLOY_KNOWN_HOSTS_FILE" ] || error "pinned known_hosts not found: $DEPLOY_KNOWN_HOSTS_FILE (run scripts/setup-server.sh first)"

[[ "$DEPLOY_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || error "invalid DEPLOY_USER"
[[ "$DEPLOY_HOST" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || error "invalid DEPLOY_HOST"
[[ "$DEPLOY_PORT" =~ ^[0-9]+$ ]] || error "invalid DEPLOY_PORT"
[ "$DEPLOY_PATH" = "/home/playground/app" ] || error "DEPLOY_PATH must be /home/playground/app"

key_mode="$(stat -c '%a' "$DEPLOY_SSH_KEY_FILE")"
case "$key_mode" in
    600|400) ;;
    *) warn "deploy key $DEPLOY_SSH_KEY_FILE has mode $key_mode (expected 600 or 400)" ;;
esac

REMOTE="${DEPLOY_USER}@${DEPLOY_HOST}"
SSH_OPTS=(
    -i "$DEPLOY_SSH_KEY_FILE"
    -o IdentitiesOnly=yes
    -o BatchMode=yes
    -o "UserKnownHostsFile=$DEPLOY_KNOWN_HOSTS_FILE"
    -o StrictHostKeyChecking=yes
    -o ConnectTimeout=15
    -p "$DEPLOY_PORT"
)
SCP_OPTS=(
    -i "$DEPLOY_SSH_KEY_FILE"
    -o IdentitiesOnly=yes
    -o BatchMode=yes
    -o "UserKnownHostsFile=$DEPLOY_KNOWN_HOSTS_FILE"
    -o StrictHostKeyChecking=yes
    -o ConnectTimeout=15
    -P "$DEPLOY_PORT"
)

# --- Locate/download the binary --------------------------------------------
if [ "$USE_RELEASE" = true ]; then
    [ -n "$VERSION" ] || error "--version requires a tag"
    if [ "$USE_TCC" = true ]; then
        ASSET_NAME="pg-linux-x64-tcc"
    else
        ASSET_NAME="pg-linux-x64"
    fi

    if [ "$VERSION" = "latest" ]; then
        DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$ASSET_NAME"
    else
        DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ASSET_NAME"
    fi

    info "Downloading $ASSET_NAME from $DOWNLOAD_URL"
    INPUT_PATH="$SCRIPT_DIR/.playground.downloaded"
    curl -fL --retry 3 --connect-timeout 15 --max-time 180 \
        -o "$INPUT_PATH" "$DOWNLOAD_URL" \
        || error "failed to download $ASSET_NAME"
    chmod +x "$INPUT_PATH"
else
    if [ -z "$INPUT_PATH" ]; then
        if [ -f "$SCRIPT_DIR/playground" ]; then
            INPUT_PATH="$SCRIPT_DIR/playground"
        elif [ -f "$SCRIPT_DIR/build/playground" ]; then
            INPUT_PATH="$SCRIPT_DIR/build/playground"
        elif [ -f "$SCRIPT_DIR/playground.exe" ]; then
            INPUT_PATH="$SCRIPT_DIR/playground.exe"
        else
            error "no local binary found (use -i PATH or --use-release)"
        fi
    fi
    [ -f "$INPUT_PATH" ] || error "input file not found: $INPUT_PATH"
fi

[ "$(head -c 4 "$INPUT_PATH" | od -An -tx1 | tr -d ' \n')" = "7f454c46" ] \
    || error "input is not a Linux ELF binary: $INPUT_PATH"

cleanup() {
    if [ "$USE_RELEASE" = true ] && [ -f "$SCRIPT_DIR/.playground.downloaded" ]; then
        rm -f "$SCRIPT_DIR/.playground.downloaded"
    fi
}
trap cleanup EXIT

# --- Upload ----------------------------------------------------------------
info "Uploading binary to ${REMOTE}:${DEPLOY_PATH}/playground.new"
scp "${SCP_OPTS[@]}" "$INPUT_PATH" "${REMOTE}:${DEPLOY_PATH}/playground.new" \
    || error "failed to upload the binary"

if [ -f "$ASSETS_DIR/Logo.png" ]; then
    info "Uploading Logo.png"
    scp "${SCP_OPTS[@]}" "$ASSETS_DIR/Logo.png" "${REMOTE}:${DEPLOY_PATH}/Logo.png" \
        || error "failed to upload Logo.png"
else
    warn "Logo.png not found in $ASSETS_DIR; the root page logo may 404"
fi

if [ -f "$ASSETS_DIR/Favicon.png" ]; then
    info "Uploading Favicon.png"
    scp "${SCP_OPTS[@]}" "$ASSETS_DIR/Favicon.png" "${REMOTE}:${DEPLOY_PATH}/Favicon.png" \
        || error "failed to upload Favicon.png"
else
    warn "Favicon.png not found in $ASSETS_DIR; the favicon may 404"
fi

# --- Install and restart ---------------------------------------------------
info "Installing and restarting the service"
if ! ssh "${SSH_OPTS[@]}" "$REMOTE" "DEPLOY_PATH='$DEPLOY_PATH' bash -s" <<'EOF'
set -euo pipefail
cd "$DEPLOY_PATH"

[ -f playground.new ] || { echo "playground.new is missing" >&2; exit 1; }

magic="$(head -c 4 playground.new | od -An -tx1 | tr -d ' \n')"
[ "$magic" = "7f454c46" ] || { echo "uploaded file is not an ELF binary" >&2; exit 1; }

chmod 0750 playground.new

# A fresh server has no playground/playground.old; both cases are fine.
if [ -f playground ]; then
    mv -f playground playground.old
fi
mv -f playground.new playground

if sudo -n /usr/local/sbin/playground-restart; then
    echo "service restarted successfully"
else
    echo "service restart failed; rolling back" >&2
    if [ -f playground.old ]; then
        mv -f playground playground.failed
        mv -f playground.old playground
        sudo -n /usr/local/sbin/playground-restart || true
    fi
    exit 1
fi
EOF
then
    ssh "${SSH_OPTS[@]}" "$REMOTE" "journalctl -u playground.service -n 80 --no-pager" || true
    error "deployment failed at the remote install step"
fi

info "Deployment successful"
