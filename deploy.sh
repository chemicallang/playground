#!/bin/bash

# Configuration
ENV_FILE="./deploy.env"
REPO="chemicallang/playground"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function error {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

function info {
    echo -e "${GREEN}Info: $1${NC}"
}

function warn {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# --- Argument Parsing ---
USE_RELEASE=false
VERSION="latest"
USE_TCC=true
INPUT_PATH="./playground"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --use-release) USE_RELEASE=true ;;
        --version) VERSION="$2"; shift ;;
        --no-tcc) USE_TCC=false ;;
        -i) INPUT_PATH="$2"; shift ;;
        *) error "Unknown parameter: $1" ;;
    esac
    shift
done

# --- Environment Loading ---
if [ -f "$ENV_FILE" ]; then
    info "Loading environment from $ENV_FILE"
    source "$ENV_FILE"
else
    warn "$ENV_FILE not found, checking system environment variables..."
fi

# Check required variables
[ -z "$DEPLOY_USER" ] && error "DEPLOY_USER is not set"
[ -z "$DEPLOY_HOST" ] && error "DEPLOY_HOST is not set"
[ -z "$DEPLOY_PATH" ] && error "DEPLOY_PATH is not set"
[ -z "$DEPLOY_PASSWORD" ] && warn "DEPLOY_PASSWORD is not set, SSH might prompt for password"

# --- Release Harvesting ---
if [ "$USE_RELEASE" = true ]; then
    info "Fetching release information for $VERSION..."
    
    if [ "$VERSION" = "latest" ]; then
        RELEASE_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
    else
        RELEASE_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/tags/$VERSION")
    fi

    if [[ "$RELEASE_JSON" == *"Not Found"* ]]; then
        error "Release $VERSION not found on GitHub."
    fi

    # Determine asset name
    if [ "$USE_TCC" = true ]; then
        ASSET_NAME="pg-linux-x64-tcc"
    else
        ASSET_NAME="pg-linux-x64"
    fi

    DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -o "\"browser_download_url\":\s*\"[^\"]*$ASSET_NAME\"" | head -n 1 | cut -d '"' -f 4)
    
    if [ -z "$DOWNLOAD_URL" ]; then
        error "Asset $ASSET_NAME not found in release $VERSION."
    fi

    info "Downloading $ASSET_NAME from $DOWNLOAD_URL..."
    curl -L "$DOWNLOAD_URL" -o "./playground.downloaded" || error "Failed to download asset"
    chmod +x "./playground.downloaded"
    INPUT_PATH="./playground.downloaded"
fi

# --- Deployment ---
REMOTE="${DEPLOY_USER}@${DEPLOY_HOST}"

# Check if input path exists
if [ ! -f "$INPUT_PATH" ]; then
    # Auto-check build folder if not specified otherwise
    if [ "$INPUT_PATH" = "./playground" ] && [ -f "./build/playground" ]; then
        INPUT_PATH="./build/playground"
    else
        error "Input file $INPUT_PATH not found."
    fi
fi

info "Starting deployment to ${REMOTE} (using $INPUT_PATH)..."

# Prepare SSH/SCP commands with password support
CMD_PREFIX=""
if [ -n "$DEPLOY_PASSWORD" ]; then
    if ! command -v sshpass &> /dev/null; then
        error "sshpass is required for password-based deployment. Please install it."
    fi
    CMD_PREFIX="sshpass -p $DEPLOY_PASSWORD"
fi

# 1. Upload the new executable
info "Uploading new executable..."
$CMD_PREFIX scp -o StrictHostKeyChecking=no "$INPUT_PATH" "${REMOTE}:${DEPLOY_PATH}/playground.new" || error "Failed to upload executable"

# 2. Perform remote update steps
info "Updating executable and restarting service..."
$CMD_PREFIX ssh -t -o StrictHostKeyChecking=no "$REMOTE" << EOF
    set -e
    cd ${DEPLOY_PATH}
    
    # Set permissions
    sudo chown playground:playground playground.new
    sudo chmod +x playground.new
    
    # Rotate versions
    if [ -f playground ]; then
        sudo mv playground playground.old
    fi
    sudo mv playground.new playground
    
    # Restart service
    echo "Restarting service..."
    sudo systemctl restart playground.service
    
    # Verify status
    sudo systemctl status playground.service --no-pager
EOF

if [ $? -eq 0 ]; then
    info "Deployment successful!"
    # Clean up downloaded file
    [ -f "./playground.downloaded" ] && rm "./playground.downloaded"
else
    error "Deployment failed at remote execution step."
fi
