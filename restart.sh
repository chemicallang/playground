#!/bin/bash
#
# Restart the deployed Chemical Playground service.
#
# Uses the same key-only configuration as deploy.sh (deploy.env, or the
# DEPLOY_* environment variables). No password or sshpass is involved.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/deploy.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$ENV_FILE"
    set +a
else
    echo "Error: deploy.env file not found." >&2
    exit 1
fi

: "${DEPLOY_USER:=deploy}"
: "${DEPLOY_HOST:=}"
: "${DEPLOY_PORT:=22}"
: "${DEPLOY_SSH_KEY_FILE:=$HOME/.ssh/chemical_playground_deploy}"
: "${DEPLOY_KNOWN_HOSTS_FILE:=$HOME/.ssh/chemical_playground_known_hosts}"

[ -n "$DEPLOY_HOST" ] || { echo "Error: DEPLOY_HOST is not set." >&2; exit 1; }
[ -f "$DEPLOY_SSH_KEY_FILE" ] || { echo "Error: deploy key not found: $DEPLOY_SSH_KEY_FILE" >&2; exit 1; }
[ -f "$DEPLOY_KNOWN_HOSTS_FILE" ] || { echo "Error: known_hosts not found: $DEPLOY_KNOWN_HOSTS_FILE" >&2; exit 1; }

ssh -i "$DEPLOY_SSH_KEY_FILE" \
    -o IdentitiesOnly=yes \
    -o BatchMode=yes \
    -o "UserKnownHostsFile=$DEPLOY_KNOWN_HOSTS_FILE" \
    -o StrictHostKeyChecking=yes \
    -o ConnectTimeout=15 \
    -p "$DEPLOY_PORT" \
    "$DEPLOY_USER@$DEPLOY_HOST" \
    'sudo -n /usr/local/sbin/playground-restart && systemctl status playground.service --no-pager'
