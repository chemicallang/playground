#!/usr/bin/env bash
# Build the Playground server (app mode, not tests).
# Usage: ./lang/compiled/playground/scripts/build.sh
#        ./lang/compiled/playground/scripts/build.sh -v
#
# Requires the Chemical compiler at the repo root (cmake-build-debug/ or build/).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
APP_DIR="$ROOT_DIR/lang/compiled/playground"
BUILD_DIR="$APP_DIR/build"
EXE="$APP_DIR/playground.exe"
MOD="$APP_DIR/chemical.mod"

VERBOSE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE="-v -bm-modules"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Playground Build ==="

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
echo "  Compiler: $COMPILER"

# 2. Build
mkdir -p "$BUILD_DIR"
cd "$ROOT_DIR"
echo "[1/2] Compiling $MOD ..."
"$COMPILER" "lang/compiled/playground/chemical.mod" --no-cache -o "$EXE" $VERBOSE
if [ $? -ne 0 ]; then
    echo "[BUILD FAILED]"
    exit 1
fi
echo "  Build OK: $EXE"

# 3. Done
echo "[2/2] Done"
echo ""
echo "Run the server:  ./lang/compiled/playground/scripts/serve.sh --no-build"
exit 0
