#!/usr/bin/env bash
# Build and run @test-annotated tests for the Playground.
# Usage: ./lang/compiled/playground/scripts/test.sh
#        ./lang/compiled/playground/scripts/test.sh --test-names "test_valid_simple_name"
#        ./lang/compiled/playground/scripts/test.sh --no-build

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
APP_DIR="$ROOT_DIR/lang/compiled/playground"
BUILD_DIR="$APP_DIR/build"
EXE="$BUILD_DIR/tests.exe"
MOD="$APP_DIR/chemical.mod"

NO_BUILD=false
TEST_NAMES=""
TEST_IDS=""
VERBOSE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build) NO_BUILD=true; shift ;;
        --test-names) TEST_NAMES="$2"; shift 2 ;;
        --test-ids) TEST_IDS="$2"; shift 2 ;;
        -v|--verbose) VERBOSE="-v"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Playground Test Runner ==="

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

# 2. Build (test mode)
if [ "$NO_BUILD" = false ]; then
    echo "[1/2] Building tests.exe with --test..."
    mkdir -p "$BUILD_DIR"
    cd "$ROOT_DIR"
    "$COMPILER" "lang/compiled/playground/chemical.mod" -o "$EXE" --test --no-cache $VERBOSE
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

# 3. Run tests
echo "[2/2] Running tests..."
RUN_ARGS=()
if [ -n "$TEST_NAMES" ]; then RUN_ARGS+=(--test-names "$TEST_NAMES"); fi
if [ -n "$TEST_IDS" ]; then RUN_ARGS+=(--test-ids "$TEST_IDS"); fi

cd "$APP_DIR"
"$EXE" "${RUN_ARGS[@]}"
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "[playground] All tests passed"
else
    echo "[playground] Some tests failed (exit code $EXIT_CODE)"
fi
exit $EXIT_CODE
