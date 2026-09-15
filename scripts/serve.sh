#!/usr/bin/env bash
# Build and run the Playground server (not tests).
# Usage: ./lang/compiled/playground/scripts/serve.sh
#        ./lang/compiled/playground/scripts/serve.sh --no-build
#        ./lang/compiled/playground/scripts/serve.sh -v

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
APP_DIR="$ROOT_DIR/lang/compiled/playground"
BUILD_DIR="$APP_DIR/build"
EXE="$APP_DIR/playground.exe"
MOD="$APP_DIR/chemical.mod"

NO_BUILD=false
VERBOSE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build) NO_BUILD=true; shift ;;
        -v|--verbose) VERBOSE="-v -bm-modules"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Playground Server ==="

# 1. Locate the compiler
COMPILER=""
for candidate in "$ROOT_DIR/cmake-build-debug/TCCCompiler" "$ROOT_DIR/build/TCCCompiler" "$ROOT_DIR/cmake-build-debug/Compiler" "$ROOT_DIR/build/Compiler"; do
    if [ -f "$candidate" ] || [ -L "$candidate" ]; then
        COMPILER="$candidate"
        break
    fi
done
if [ -z "$COMPILER" ]; then
    echo "[ERROR] Chemical compiler not found under $ROOT_DIR (looked in cmake-build-debug/ and build/)"
    exit 1
fi

# 2. Build
if [ "$NO_BUILD" = false ]; then
    echo "[1/2] Building server..."
    mkdir -p "$BUILD_DIR"
    cd "$ROOT_DIR"
    "$COMPILER" "lang/compiled/playground/chemical.mod" --no-cache -o "$EXE" $VERBOSE
    if [ $? -ne 0 ]; then
        echo "[BUILD FAILED]"
        exit 1
    fi
    echo "  Build OK: $EXE"
else
    echo "[1/2] Skipping build (--no-build)"
fi

if [ ! -f "$EXE" ]; then
    echo "[ERROR] Cannot find $EXE"
    exit 1
fi

# 3. Run — the app serves on port 8080 by default and resolves dev assets
# relative to the repo root, so run from there.
echo "[2/2] Starting server (Ctrl+C to stop)..."
cd "$ROOT_DIR"
"$EXE"
