#!/usr/bin/env bash
#
# Chemical Playground — interactive server setup (run on your local machine).
#
#   ./scripts/setup-server.sh
#
# The script asks for the server address and SSH login, installs a dedicated
# public key over an interactive `ssh-copy-id` prompt (the password is typed
# into ssh's own prompt and is never captured or written to disk), provisions
# Ubuntu 24.04, hardens SSH, deploys the playground, and optionally updates the
# GitHub Actions secrets.
#
# Re-running it against a new server reuses the same keys and updates the local
# configuration, known_hosts entry and GitHub secrets.
#
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_SCRIPT="$SCRIPT_DIR/setup-server-remote.sh"
REPO="chemicallang/playground"
APP_DIR="/home/playground/app"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/chemical-playground"
CONFIG_FILE="$CONFIG_DIR/setup.conf"
OPS_KEY="$HOME/.ssh/chemical_playground_ops"
DEPLOY_KEY="$HOME/.ssh/chemical_playground_deploy"
KNOWN_HOSTS="$HOME/.ssh/chemical_playground_known_hosts"

# Defaults (overridable by config file, then CLI, then prompts)
TARGET_HOST=""
BOOTSTRAP_USER="root"
SSH_PORT="22"
ADMIN_USER="admin"
DOMAIN="chemicallang.com www.chemicallang.com"
EMAIL=""
TLS_MODE=""
IMAGE_TAGS=""
RELEASE_TAG="latest"
OPT_BINARY=""
SKIP_IMAGES=0
DO_GITHUB=1
DO_SSH_CONFIG=1
DO_DEPLOY_ENV=1
TLS_ONLY=0
TMP_DIR=""
SSH_ALIAS_WRITTEN=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { printf '\n%b[setup]%b %s\n' "$GREEN" "$NC" "$*"; }
warn() { printf '\n%b[setup] warning:%b %s\n' "$YELLOW" "$NC" "$*" >&2; }
die()  { printf '\n%b[setup] error:%b %s\n' "$RED" "$NC" "$*" >&2; exit 1; }
note() { printf '%b[setup]%b %s\n' "$BLUE" "$NC" "$*"; }

usage() {
    cat <<'EOF'
Usage: setup-server.sh [options]

Options:
  --host HOST            Server IP or hostname (prompted if omitted)
  --ssh-user USER        Initial SSH user for ssh-copy-id (default: root)
  --ssh-port PORT        SSH port (default: 22)
  --admin-user USER      Non-root admin account to create/use (default: admin)
  --domain "D..."        Space-separated domains (default: chemicallang.com www.chemicallang.com)
  --email EMAIL          Let's Encrypt account email
  --tls-mode MODE        cloudflare | http | none (prompted if omitted)
  --tls-only             Only issue/install the certificate (uses saved config)
  --binary PATH          Use this local playground binary instead of the latest release
  --release-tag TAG      Release tag to download (default: latest)
  --skip-images          Do not pre-pull the chemical Docker images
  --no-github            Do not update GitHub Actions secrets
  --no-ssh-config        Do not add/update the Host playground block
  --no-deploy-env        Do not rewrite local deploy.env
  -h, --help             Show this help

The server password is requested by ssh-copy-id / sudo on the terminal. It is
never read by this script, never written to a file, and never placed on a
command line.
EOF
}

# ---------------------------------------------------------------------------
# argument parsing
# ---------------------------------------------------------------------------

while [ "$#" -gt 0 ]; do
    case "$1" in
        --host) TARGET_HOST="${2:-}"; shift 2 ;;
        --ssh-user) BOOTSTRAP_USER="${2:-}"; shift 2 ;;
        --ssh-port) SSH_PORT="${2:-}"; shift 2 ;;
        --admin-user) ADMIN_USER="${2:-}"; shift 2 ;;
        --domain) DOMAIN="${2:-}"; shift 2 ;;
        --email) EMAIL="${2:-}"; shift 2 ;;
        --tls-mode) TLS_MODE="${2:-}"; shift 2 ;;
        --tls-only) TLS_ONLY=1; shift ;;
        --binary) OPT_BINARY="${2:-}"; shift 2 ;;
        --release-tag) RELEASE_TAG="${2:-}"; shift 2 ;;
        --skip-images|--no-images) SKIP_IMAGES=1; shift ;;
        --no-github) DO_GITHUB=0; shift ;;
        --no-ssh-config) DO_SSH_CONFIG=0; shift ;;
        --no-deploy-env) DO_DEPLOY_ENV=0; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1 (use --help)" ;;
    esac
done

# ---------------------------------------------------------------------------
# saved configuration (never contains passwords or tokens)
# ---------------------------------------------------------------------------

if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
    TARGET_HOST="${TARGET_HOST:-${SETUP_HOST:-}}"
    BOOTSTRAP_USER="${BOOTSTRAP_USER:-${SETUP_USER:-root}}"
    SSH_PORT="${SSH_PORT:-${SETUP_PORT:-22}}"
    ADMIN_USER="${ADMIN_USER:-${SETUP_ADMIN_USER:-admin}}"
    DOMAIN="${DOMAIN:-${SETUP_DOMAIN:-chemicallang.com www.chemicallang.com}}"
    EMAIL="${EMAIL:-${SETUP_EMAIL:-}}"
    TLS_MODE="${TLS_MODE:-${SETUP_TLS_MODE:-}}"
    IMAGE_TAGS="${IMAGE_TAGS:-${SETUP_IMAGE_TAGS:-}}"
fi

# ---------------------------------------------------------------------------
# prompts and validation
# ---------------------------------------------------------------------------

prompt_value() {
    local var="$1" text="$2" default="${3:-}" value=""
    if [ -n "$default" ]; then
        read -rp "$text [$default]: " value
        value="${value:-$default}"
    else
        read -rp "$text: " value
    fi
    printf -v "$var" '%s' "$value"
}

prompt_secret() {
    local var="$1" text="$2" value=""
    read -rsp "$text: " value
    echo
    printf -v "$var" '%s' "$value"
}

prompt_yes_no() {
    local text="$1" default="${2:-y}" answer=""
    if [ "$default" = "y" ]; then
        read -rp "$text [Y/n]: " answer
        answer="${answer:-y}"
    else
        read -rp "$text [y/N]: " answer
        answer="${answer:-n}"
    fi
    [[ "$answer" =~ ^[Yy] ]]
}

validate_settings() {
    [[ "$TARGET_HOST" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "invalid server host: $TARGET_HOST"
    [[ "$BOOTSTRAP_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "invalid initial SSH user: $BOOTSTRAP_USER"
    [[ "$ADMIN_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "invalid admin user: $ADMIN_USER"
    [ "$ADMIN_USER" != "root" ] || die "admin user must not be root"
    [ "$ADMIN_USER" != "deploy" ] || die "admin user must not be 'deploy'"
    [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || die "invalid SSH port: $SSH_PORT"
    [ "$SSH_PORT" -ge 1 ] && [ "$SSH_PORT" -le 65535 ] || die "SSH port out of range"

    local d
    [ -n "$DOMAIN" ] || die "domain is required"
    for d in $DOMAIN; do
        [[ "$d" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ ]] || die "invalid domain: $d"
    done

    case "$TLS_MODE" in
        cloudflare|http|none) ;;
        *) die "invalid TLS mode: $TLS_MODE (use cloudflare, http or none)" ;;
    esac

    if [ "$TLS_MODE" != "none" ]; then
        [[ "$EMAIL" == *"@"*"."* ]] || die "a valid Let's Encrypt email is required"
    fi
}

choose_tls_mode() {
    [ -n "$TLS_MODE" ] && return 0
    printf '\nTLS certificate:\n'
    printf '  1) Cloudflare DNS-01 (works before DNS cutover) [recommended]\n'
    printf '  2) Let\x27s Encrypt HTTP-01 (DNS must already point at this server)\n'
    printf '  3) Skip TLS for now\n'
    local choice=""
    read -rp "Choose [1]: " choice
    choice="${choice:-1}"
    case "$choice" in
        1) TLS_MODE="cloudflare" ;;
        2) TLS_MODE="http" ;;
        3) TLS_MODE="none" ;;
        *) die "invalid choice" ;;
    esac

    if [ "$TLS_MODE" = "http" ] && ! prompt_yes_no "Has DNS for ${DOMAIN%% *} been pointed at this server (or is Cloudflare proxying it)?" "n"; then
        warn "Leaving TLS for later; the site will be reachable over HTTP until you re-run with --tls-only."
        TLS_MODE="none"
    fi
}

require_commands() {
    local cmd
    for cmd in ssh scp ssh-keygen ssh-keyscan ssh-copy-id curl; do
        command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
    done
}

ensure_keys() {
    if [ ! -f "$OPS_KEY" ]; then
        log "Generating operator SSH key: $OPS_KEY"
        ssh-keygen -q -t ed25519 -a 100 -C "chemical-playground-ops" -f "$OPS_KEY" -N ""
    fi
    if [ ! -f "$OPS_KEY.pub" ]; then
        ssh-keygen -y -f "$OPS_KEY" > "$OPS_KEY.pub"
    fi
    chmod 600 "$OPS_KEY"
    chmod 644 "$OPS_KEY.pub"

    if [ ! -f "$DEPLOY_KEY" ]; then
        log "Generating CI deploy SSH key: $DEPLOY_KEY"
        ssh-keygen -q -t ed25519 -a 100 -C "chemical-playground-deploy" -f "$DEPLOY_KEY" -N ""
    fi
    if [ ! -f "$DEPLOY_KEY.pub" ]; then
        ssh-keygen -y -f "$DEPLOY_KEY" > "$DEPLOY_KEY.pub"
    fi
    chmod 600 "$DEPLOY_KEY"
    chmod 644 "$DEPLOY_KEY.pub"

    OPS_PUBKEY="$(cat "$OPS_KEY.pub")"
    DEPLOY_PUBKEY="$(cat "$DEPLOY_KEY.pub")"
}

host_key_name() {
    if [ "$SSH_PORT" = "22" ]; then
        printf '%s' "$TARGET_HOST"
    else
        printf '[%s]:%s' "$TARGET_HOST" "$SSH_PORT"
    fi
}

scan_host_key() {
    local scan fp old_fp
    log "Fetching SSH host key from $TARGET_HOST:$SSH_PORT"
    scan="$(ssh-keyscan -p "$SSH_PORT" -T 10 -t ed25519 "$TARGET_HOST" 2>/dev/null | grep -v '^#' | sort -u | head -1)"
    [ -n "$scan" ] || die "could not fetch the SSH host key; check the IP, port and provider firewall"
    fp="$(printf '%s\n' "$scan" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}')"
    [ -n "$fp" ] || die "could not parse the SSH host key fingerprint"

    old_fp=""
    if [ -f "$KNOWN_HOSTS" ]; then
        old_fp="$(ssh-keygen -lf "$KNOWN_HOSTS" -F "$(host_key_name)" 2>/dev/null | awk '{print $2}' | head -1 || true)"
    fi

    if [ -n "$old_fp" ] && [ "$old_fp" = "$fp" ]; then
        log "Host key already pinned: $fp"
    else
        printf '\nServer host key fingerprint: %s\n' "$fp"
        printf 'Verify this in the provider console or another trusted channel.\n'
        printf 'On the server console: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub\n'
        if ! prompt_yes_no "Does the fingerprint match?" "n"; then
            die "host key was not verified; refusing to continue"
        fi
        if [ -f "$KNOWN_HOSTS" ]; then
            ssh-keygen -R "$(host_key_name)" -f "$KNOWN_HOSTS" >/dev/null 2>&1 || true
        fi
        printf '%s\n' "$scan" >> "$KNOWN_HOSTS"
        chmod 600 "$KNOWN_HOSTS"
    fi
    SCAN_LINE="$scan"
}

install_operator_key() {
    if ssh -o "UserKnownHostsFile=$KNOWN_HOSTS" -o "StrictHostKeyChecking=yes" \
        -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=15 -p "$SSH_PORT" \
        -i "$OPS_KEY" "$BOOTSTRAP_USER@$TARGET_HOST" true >/dev/null 2>&1; then
        log "Operator key already works for $BOOTSTRAP_USER@$TARGET_HOST"
        return 0
    fi

    log "Installing the operator public key (ssh will prompt for the server password)"
    note "The password is entered into ssh's own prompt; this script never sees or stores it."
    ssh-copy-id -i "$OPS_KEY.pub" -p "$SSH_PORT" \
        -o "UserKnownHostsFile=$KNOWN_HOSTS" \
        -o "StrictHostKeyChecking=yes" \
        "$BOOTSTRAP_USER@$TARGET_HOST"

    ssh -o "UserKnownHostsFile=$KNOWN_HOSTS" -o "StrictHostKeyChecking=yes" \
        -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=15 -p "$SSH_PORT" \
        -i "$OPS_KEY" "$BOOTSTRAP_USER@$TARGET_HOST" true >/dev/null \
        || die "key login still fails after ssh-copy-id"
}

# ---------------------------------------------------------------------------
# remote execution helpers
# ---------------------------------------------------------------------------

SSH_COMMON=()
SCP_COMMON=()

init_ssh_opts() {
    SSH_COMMON=(
        -o "UserKnownHostsFile=$KNOWN_HOSTS"
        -o "StrictHostKeyChecking=yes"
        -o "IdentitiesOnly=yes"
        -o "ConnectTimeout=15"
        -o "ServerAliveInterval=30"
        -o "ServerAliveCountMax=10"
        -p "$SSH_PORT"
    )
    SCP_COMMON=(
        -P "$SSH_PORT"
        -o "UserKnownHostsFile=$KNOWN_HOSTS"
        -o "StrictHostKeyChecking=yes"
        -o "IdentitiesOnly=yes"
        -o "ConnectTimeout=15"
        -o "ServerAliveInterval=30"
        -o "ServerAliveCountMax=10"
    )
}

ssh_admin() {
    ssh "${SSH_COMMON[@]}" -i "$OPS_KEY" -o BatchMode=yes "$ADMIN_USER@$TARGET_HOST" "$@"
}

ssh_deploy() {
    ssh "${SSH_COMMON[@]}" -i "$DEPLOY_KEY" -o BatchMode=yes "deploy@$TARGET_HOST" "$@"
}

scp_admin() {
    scp "${SCP_COMMON[@]}" -i "$OPS_KEY" "$@"
}

scp_deploy() {
    scp "${SCP_COMMON[@]}" -i "$DEPLOY_KEY" "$@"
}

write_remote_config() {
    local file="$TMP_DIR/setup.env"
    {
        printf 'ADMIN_USER=%q\n' "$ADMIN_USER"
        printf 'OPS_PUBKEY=%q\n' "$OPS_PUBKEY"
        printf 'DEPLOY_PUBKEY=%q\n' "$DEPLOY_PUBKEY"
        printf 'APP_DIR=%q\n' "$APP_DIR"
        printf 'DOMAIN=%q\n' "$DOMAIN"
        printf 'EMAIL=%q\n' "$EMAIL"
        printf 'TLS_MODE=%q\n' "$TLS_MODE"
        printf 'SSH_PORT=%q\n' "$SSH_PORT"
        printf 'IMAGE_TAGS=%q\n' "$IMAGE_TAGS"
        printf 'SKIP_IMAGES=%q\n' "$SKIP_IMAGES"
    } > "$file"
    chmod 600 "$file"
}

upload_remote_files() {
    local user="$1" key="$2"
    scp "${SCP_COMMON[@]}" -i "$key" \
        "$REMOTE_SCRIPT" "$user@$TARGET_HOST:/tmp/chemical-setup-remote.sh"
    scp "${SCP_COMMON[@]}" -i "$key" \
        "$TMP_DIR/setup.env" "$user@$TARGET_HOST:/tmp/chemical-setup.env"
    if [ "$TLS_MODE" = "cloudflare" ] && [ -f "$TMP_DIR/cloudflare.ini" ]; then
        scp "${SCP_COMMON[@]}" -i "$key" \
            "$TMP_DIR/cloudflare.ini" "$user@$TARGET_HOST:/tmp/chemical-cloudflare.ini"
    fi
    ssh "${SSH_COMMON[@]}" -i "$key" -o BatchMode=yes "$user@$TARGET_HOST" \
        "chmod 700 /tmp/chemical-setup-remote.sh; chmod 600 /tmp/chemical-setup.env; if [ -f /tmp/chemical-cloudflare.ini ]; then chmod 600 /tmp/chemical-cloudflare.ini; fi"
}

run_remote_phase() {
    local phase="$1" user="$2" key="$3" sudo_mode="$4" cmd
    upload_remote_files "$user" "$key"
    if [ "$user" = "root" ]; then
        cmd="bash /tmp/chemical-setup-remote.sh --config /tmp/chemical-setup.env --phase $phase"
    elif [ "$sudo_mode" = "nopasswd" ]; then
        cmd="sudo -n bash /tmp/chemical-setup-remote.sh --config /tmp/chemical-setup.env --phase $phase"
    else
        cmd="sudo bash /tmp/chemical-setup-remote.sh --config /tmp/chemical-setup.env --phase $phase"
    fi
    ssh "${SSH_COMMON[@]}" -i "$key" -t "$user@$TARGET_HOST" "$cmd"
}

detect_sudo_mode() {
    if [ "$BOOTSTRAP_USER" = "root" ]; then
        SUDO_MODE="root"
    elif ssh "${SSH_COMMON[@]}" -i "$OPS_KEY" -o BatchMode=yes "$BOOTSTRAP_USER@$TARGET_HOST" 'sudo -n true' >/dev/null 2>&1; then
        SUDO_MODE="nopasswd"
    else
        SUDO_MODE="prompt"
        note "sudo on the server may ask for the password; type it when prompted."
    fi
}

# ---------------------------------------------------------------------------
# deployment
# ---------------------------------------------------------------------------

prepare_binary() {
    log "Preparing the playground binary"
    if [ -n "$OPT_BINARY" ]; then
        BIN_PATH="$OPT_BINARY"
        [ -f "$BIN_PATH" ] || die "binary not found: $BIN_PATH"
    else
        BIN_PATH="$TMP_DIR/playground"
        local url
        if [ "$RELEASE_TAG" = "latest" ]; then
            url="https://github.com/$REPO/releases/latest/download/pg-linux-x64-tcc"
        else
            url="https://github.com/$REPO/releases/download/$RELEASE_TAG/pg-linux-x64-tcc"
        fi
        log "Downloading $url"
        curl -fL --retry 3 --connect-timeout 15 --max-time 180 -o "$BIN_PATH" "$url" \
            || die "could not download the playground release asset (use --binary PATH)"
    fi

    [ "$(head -c 4 "$BIN_PATH" | od -An -tx1 | tr -d ' \n')" = "7f454c46" ] \
        || die "not a Linux ELF binary: $BIN_PATH"
    chmod +x "$BIN_PATH"
}

upload_and_start() {
    local assets="$SCRIPT_DIR/../src/assets"
    [ -f "$assets/Logo.png" ] || die "missing asset: $assets/Logo.png"
    [ -f "$assets/Favicon.png" ] || die "missing asset: $assets/Favicon.png"

    log "Uploading binary and assets"
    scp_deploy "$BIN_PATH" "deploy@$TARGET_HOST:$APP_DIR/playground.new"
    scp_deploy "$assets/Logo.png" "deploy@$TARGET_HOST:$APP_DIR/Logo.png"
    scp_deploy "$assets/Favicon.png" "deploy@$TARGET_HOST:$APP_DIR/Favicon.png"

    log "Installing and starting the service"
    if ! ssh_deploy "set -euo pipefail; cd '$APP_DIR'; chmod 0750 playground.new; if [ -f playground ]; then mv -f playground playground.old; fi; mv -f playground.new playground; sudo -n /usr/local/sbin/playground-restart"; then
        ssh_admin "sudo -n journalctl -u playground.service -n 120 --no-pager" || true
        die "the playground service failed to start"
    fi
}

submit_payload() {
    cat > "$TMP_DIR/submit.json" <<'JSON'
{
  "outputType": 0,
  "files": [
    {"name": "main.ch", "content": "@extern\npublic func printf(format : *char, _ : any...)\npublic func main() : int {\n    printf(\"Hello World\");\n    return 0;\n}"},
    {"name": "chemical.mod", "content": "application main\nsource \"main.ch\"\n"}
  ],
  "settings": {"version": "511", "mode": "release", "use_tcc": true}
}
JSON
}

smoke_test() {
    log "Running smoke tests"
    submit_payload
    scp_admin "$TMP_DIR/submit.json" "$ADMIN_USER@$TARGET_HOST:/tmp/chemical-submit.json"

    ssh_admin "curl -fsS --max-time 5 http://127.0.0.1:8080/ | grep -q 'Chemical | Programming Language'" \
        || die "the app root page did not respond correctly"
    ssh_admin "curl -fsS --max-time 5 http://127.0.0.1:8080/playground | grep -q 'monaco-editor'" \
        || die "the playground page did not include the editor"
    [ "$(ssh_admin "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/Logo.png")" = "200" ] \
        || die "Logo.png is not served"
    [ "$(ssh_admin "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/Favicon.png")" = "200" ] \
        || die "Favicon.png is not served"

    local tls_enabled=0
    if ssh_admin "test -f /etc/letsencrypt/live/${DOMAIN%% *}/fullchain.pem" >/dev/null 2>&1; then
        tls_enabled=1
    fi

    local payload
    if [ "$tls_enabled" = "1" ]; then
        ssh_admin "curl -fsS --resolve '${DOMAIN%% *}:443:127.0.0.1' 'https://${DOMAIN%% *}/' | grep -q 'Chemical | Programming Language'" \
            || warn "nginx HTTPS is not yet reachable on loopback; check the certificate/nginx"
        payload="$(ssh_admin "curl -fsS --max-time 60 --resolve '${DOMAIN%% *}:443:127.0.0.1' -X POST -H 'Content-Type: application/json' --data-binary @/tmp/chemical-submit.json 'https://${DOMAIN%% *}/submit'")" || true
    else
        ssh_admin "curl -fsS -H 'Host: ${DOMAIN%% *}' http://127.0.0.1/ | grep -q 'Chemical | Programming Language'" \
            || die "nginx is not proxying the app correctly"
        payload="$(ssh_admin "curl -fsS --max-time 60 -H 'Host: ${DOMAIN%% *}' -X POST -H 'Content-Type: application/json' --data-binary @/tmp/chemical-submit.json http://127.0.0.1/submit")" || true
    fi

    if ! printf '%s' "$payload" | grep -q '"type" : "output"'; then
        printf '%s\n' "$payload" | head -c 4000
        ssh_admin "sudo -n journalctl -u playground.service -n 150 --no-pager" || true
        die "the /submit smoke test did not return a compiler result"
    fi
    if ! printf '%s' "$payload" | grep -q 'Hello World'; then
        printf '%s\n' "$payload" | head -c 4000
        die "the /submit smoke test compiled but did not produce the expected output (is the Docker image available?)"
    fi

    log "Docker compile round-trip succeeded"
    ssh_admin "sudo -n systemctl enable --now playground-health.timer" >/dev/null 2>&1 || true
    ssh_admin "rm -f /tmp/chemical-submit.json" >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------------
# local state
# ---------------------------------------------------------------------------

save_local_config() {
    install -d -m 0700 "$CONFIG_DIR"
    cat > "$CONFIG_FILE" <<EOF
SETUP_HOST=$(printf '%q' "$TARGET_HOST")
SETUP_USER=$(printf '%q' "$BOOTSTRAP_USER")
SETUP_PORT=$(printf '%q' "$SSH_PORT")
SETUP_ADMIN_USER=$(printf '%q' "$ADMIN_USER")
SETUP_DOMAIN=$(printf '%q' "$DOMAIN")
SETUP_EMAIL=$(printf '%q' "$EMAIL")
SETUP_TLS_MODE=$(printf '%q' "$TLS_MODE")
SETUP_IMAGE_TAGS=$(printf '%q' "$IMAGE_TAGS")
EOF
    chmod 600 "$CONFIG_FILE"
}

update_github_secrets() {
    [ "$DO_GITHUB" = "1" ] || { log "Skipping GitHub secrets (--no-github)"; return 0; }
    command -v gh >/dev/null 2>&1 || { warn "gh not found; GitHub secrets were not updated"; return 0; }
    gh auth status >/dev/null 2>&1 || { warn "gh is not authenticated; run 'gh auth login' and re-run the setup to update secrets"; return 0; }
    prompt_yes_no "Update GitHub Actions secrets for $REPO now?" "y" || return 0

    if ! (
        printf '%s' "$TARGET_HOST" | gh secret set DEPLOY_HOST -R "$REPO"
        printf '%s' "$SSH_PORT" | gh secret set DEPLOY_PORT -R "$REPO"
        printf '%s' "deploy" | gh secret set DEPLOY_USER -R "$REPO"
        printf '%s' "$APP_DIR" | gh secret set DEPLOY_PATH -R "$REPO"
        gh secret set DEPLOY_SSH_KEY -R "$REPO" < "$DEPLOY_KEY"
        printf '%s\n' "$SCAN_LINE" | gh secret set DEPLOY_KNOWN_HOSTS -R "$REPO"
        gh secret delete DEPLOY_PASSWORD -R "$REPO" >/dev/null 2>&1 || true
    ); then
        warn "could not update all GitHub secrets; set them manually with gh secret set"
        return 0
    fi
    log "GitHub Actions secrets updated (DEPLOY_PASSWORD removed)"
}

write_deploy_env() {
    [ "$DO_DEPLOY_ENV" = "1" ] || return 0
    local file="$SCRIPT_DIR/../deploy.env"
    if ! prompt_yes_no "Replace local deploy.env with the key-based configuration? (removes the old password)" "y"; then
        return 0
    fi
    cat > "$file" <<EOF
DEPLOY_USER=deploy
DEPLOY_HOST=$(printf '%q' "$TARGET_HOST")
DEPLOY_PORT=$(printf '%q' "$SSH_PORT")
DEPLOY_PATH=$(printf '%q' "$APP_DIR")
DEPLOY_SSH_KEY_FILE=$(printf '%q' "$DEPLOY_KEY")
DEPLOY_KNOWN_HOSTS_FILE=$(printf '%q' "$KNOWN_HOSTS")
EOF
    chmod 600 "$file"
    log "Wrote key-based configuration to $file"
}

write_ssh_config() {
    [ "$DO_SSH_CONFIG" = "1" ] || return 0
    local cfg="$HOME/.ssh/config" tmp
    if [ -f "$cfg" ] && grep -qE '^[[:space:]]*Host[[:space:]]+playground([[:space:]]|$)' "$cfg" \
        && ! grep -q '^# BEGIN chemical-playground$' "$cfg"; then
        warn "$cfg already has a Host playground block; not modifying it"
        return 0
    fi
    prompt_yes_no "Add/update the 'Host playground' SSH alias in $cfg?" "y" || return 0

    install -d -m 0700 "$HOME/.ssh"
    touch "$cfg"
    chmod 600 "$cfg"
    tmp="$(mktemp)"
    awk '
        /^# BEGIN chemical-playground$/ { skip=1; next }
        /^# END chemical-playground$/   { skip=0; next }
        !skip { print }
    ' "$cfg" > "$tmp"
    cat >> "$tmp" <<EOF
# BEGIN chemical-playground
Host playground
    HostName $TARGET_HOST
    User $ADMIN_USER
    Port $SSH_PORT
    IdentityFile "$OPS_KEY"
    IdentitiesOnly yes
    UserKnownHostsFile "$KNOWN_HOSTS"
    StrictHostKeyChecking yes
    ServerAliveInterval 30
# END chemical-playground
EOF
    mv "$tmp" "$cfg"
    chmod 600 "$cfg"
    SSH_ALIAS_WRITTEN=1
    log "SSH alias updated: ssh playground"
}

print_summary() {
    local apex="${DOMAIN%% *}"
    local tls=0
    local ssh_hint
    ssh_admin "rm -f /tmp/chemical-setup-remote.sh /tmp/chemical-setup.env /tmp/chemical-cloudflare.ini" >/dev/null 2>&1 || true
    ssh_admin "test -f /etc/letsencrypt/live/$apex/fullchain.pem" >/dev/null 2>&1 && tls=1

    if [ "$SSH_ALIAS_WRITTEN" = "1" ]; then
        ssh_hint="ssh playground"
    else
        ssh_hint="ssh -i $OPS_KEY -p $SSH_PORT $ADMIN_USER@$TARGET_HOST"
    fi

    cat <<EOF

$(printf '%b' "$GREEN")Setup complete$(printf '%b' "$NC")

  Server:      $TARGET_HOST:$SSH_PORT
  Admin:       $ADMIN_USER (key-only, passwordless sudo)
  Deploy:      deploy (key-only, narrow sudo: restart playground only)
  App dir:     $APP_DIR
  Service:     playground.service

  URL:         $( [ "$tls" = 1 ] && printf 'https://%s/' "$apex" || printf 'http://%s/' "$TARGET_HOST" )
  Playground:  $( [ "$tls" = 1 ] && printf 'https://%s/playground' "$apex" || printf 'http://%s/playground' "$TARGET_HOST" )

  SSH:         $ssh_hint
  Logs:        $ssh_hint 'sudo journalctl -u playground.service -f'
  Status:      $ssh_hint 'sudo systemctl status playground.service --no-pager'

Pre-cutover test (from this machine):
  $( [ "$tls" = 1 ] && printf "curl --connect-to %s:443:%s:443 https://%s/" "$apex" "$TARGET_HOST" "$apex" || printf "curl -H 'Host: %s' http://%s/" "$apex" "$TARGET_HOST" )

Next steps:
  1. Ensure the provider firewall allows TCP $SSH_PORT (SSH), 80 and 443.
  2. Point the Cloudflare A records for: $DOMAIN -> $TARGET_HOST (keep the old server running until tested).
  3. If TLS was skipped: ./scripts/setup-server.sh --tls-only
  4. Run the "Deploy Playground" GitHub Action. It now uses DEPLOY_SSH_KEY and
     handles a fresh server (no playground/playground.old yet).
  5. Open /playground and run one compile; the Docker round-trip is already tested.

Security notes:
  - The server password was only used by ssh-copy-id; this script never stored it.
  - The old password-based deploy path is gone. DEPLOY_PASSWORD is no longer used,
    and is deleted from GitHub when the secrets update succeeds.
  - The local deploy.env is rewritten without a password when you accept that prompt.
  - The deploy key is $DEPLOY_KEY. Protect it; it is also stored as a GitHub secret.
  - If Cloudflare DNS-01 was used, a root-only API token is stored at
    /etc/letsencrypt/cloudflare.ini so certbot can renew the certificate.
  - The playground runs untrusted code in Docker. The Docker socket is effectively
    root-equivalent, so keep this host dedicated to the playground.
  - Unattended security upgrades are enabled. Reboot if /var/run/reboot-required exists.

EOF
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

require_commands
ensure_keys

if [ -z "$TARGET_HOST" ]; then
    prompt_value TARGET_HOST "Server IP or hostname"
fi

if [ "$TLS_ONLY" != "1" ]; then
    prompt_value BOOTSTRAP_USER "Initial SSH user (root or the provider default)" "$BOOTSTRAP_USER"
    prompt_value SSH_PORT "SSH port" "$SSH_PORT"
    prompt_value ADMIN_USER "Non-root admin account to create/use" "$ADMIN_USER"
    prompt_value DOMAIN "Domain(s), space separated" "$DOMAIN"
    prompt_value EMAIL "Let's Encrypt email" "$EMAIL"
else
    # tls-only: only the settings needed to reach the server and issue a cert
    if [ -z "$ADMIN_USER" ]; then prompt_value ADMIN_USER "Non-root admin account" "admin"; fi
    if [ -z "$DOMAIN" ]; then prompt_value DOMAIN "Domain(s), space separated" "chemicallang.com www.chemicallang.com"; fi
    if [ -z "$EMAIL" ]; then prompt_value EMAIL "Let's Encrypt email" ""; fi
fi

if [ -z "$IMAGE_TAGS" ]; then
    IMAGE_TAGS="$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+-ubuntu' "$SCRIPT_DIR/../src/versions.ch" 2>/dev/null | sort -u | paste -sd ' ' - || true)"
    [ -n "$IMAGE_TAGS" ] || IMAGE_TAGS="v0.5.11-ubuntu v0.5.10-ubuntu v0.5.9-ubuntu"
fi

choose_tls_mode
validate_settings

init_ssh_opts
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

scan_host_key

if [ "$TLS_ONLY" = "1" ]; then
    ssh_admin true >/dev/null 2>&1 || die "admin key login failed; check the admin user and $OPS_KEY"
else
    install_operator_key
    detect_sudo_mode
fi

if [ "$TLS_MODE" = "cloudflare" ]; then
    # If a certificate already exists, the token is not needed.
    CERT_EXISTS=0
    if ssh_admin "test -f /etc/letsencrypt/live/${DOMAIN%% *}/fullchain.pem" >/dev/null 2>&1; then
        CERT_EXISTS=1
    fi
    if [ "$CERT_EXISTS" = "0" ]; then
        prompt_secret CF_TOKEN "Cloudflare API token (Zone:Zone:Read + Zone:DNS:Edit)"
        [ -n "$CF_TOKEN" ] || die "a Cloudflare API token is required for DNS-01 (use --tls-mode none to skip)"
    else
        note "A certificate already exists; no Cloudflare token is needed."
    fi
fi

if [ -n "${CF_TOKEN:-}" ]; then
    printf 'dns_cloudflare_api_token = %s\n' "$CF_TOKEN" > "$TMP_DIR/cloudflare.ini"
    chmod 600 "$TMP_DIR/cloudflare.ini"
    unset CF_TOKEN
fi

write_remote_config

if [ "$TLS_ONLY" = "1" ]; then
    log "Issuing/installing TLS certificate only"
    run_remote_phase tls "$ADMIN_USER" "$OPS_KEY" "nopasswd"
    save_local_config
    print_summary
    exit 0
fi

printf '\n'
printf '  Target:        %s@%s:%s\n' "$BOOTSTRAP_USER" "$TARGET_HOST" "$SSH_PORT"
printf '  Admin user:    %s\n' "$ADMIN_USER"
printf '  Domains:       %s\n' "$DOMAIN"
printf '  TLS mode:      %s\n' "$TLS_MODE"
printf '  App dir:       %s\n' "$APP_DIR"
printf '  Docker images: %s\n' "$IMAGE_TAGS"
printf '\n'
prompt_yes_no "Provision this server now?" "y" || die "aborted"

log "Phase 1/3: provisioning (packages, users, Docker, nginx, firewall)"
run_remote_phase provision "$BOOTSTRAP_USER" "$OPS_KEY" "$SUDO_MODE"

log "Verifying key-based login for admin and deploy"
ssh_admin true >/dev/null 2>&1 || die "admin key login failed; not hardening SSH"
ssh_deploy true >/dev/null 2>&1 || die "deploy key login failed; not hardening SSH"

log "Phase 2/3: hardening SSH (key-only, no root login)"
run_remote_phase harden "$ADMIN_USER" "$OPS_KEY" "nopasswd"

if ssh_admin true >/dev/null 2>&1 && ssh_deploy true >/dev/null 2>&1; then
    ssh_admin "sudo -n systemctl stop chemical-ssh-rollback.timer >/dev/null 2>&1 || true; sudo -n systemctl reset-failed chemical-ssh-rollback.service >/dev/null 2>&1 || true" >/dev/null 2>&1 || true
    log "SSH hardening verified"
else
    warn "key login failed after hardening. The server will restore password auth in ~10 minutes; use the provider console if you need in immediately."
fi

prepare_binary
log "Phase 3/3: deploying the playground"
upload_and_start
smoke_test

update_github_secrets
save_local_config
write_deploy_env
write_ssh_config
print_summary
