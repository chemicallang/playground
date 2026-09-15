#!/usr/bin/env bash
# Build the playground server, boot it, probe every route over HTTP, stop it.
# Usage: bash lang/compiled/playground/scripts/playground-build-test.sh
# This script ALWAYS exits cleanly — never blocks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
APP_DIR="$ROOT/lang/compiled/playground"
BUILD_DIR="$APP_DIR/build"
PORT="${PLAYGROUND_TEST_PORT:-8080}"
URL="http://localhost:$PORT"

pass=0
fail=0

test_url() {
    local label="$1" path="$2" expect="$3"
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 5 "$URL$path" 2>/dev/null || echo "000")
    if [ "$status" = "$expect" ]; then
        echo "  [OK]   $label  $path  ($status)"
        pass=$((pass + 1))
    else
        echo "  [FAIL] $label  $path  (got $status, want $expect)"
        fail=$((fail + 1))
    fi
}

echo "=== Playground Build + Endpoint Test ==="

# 1. Locate the compiler
COMPILER=""
for candidate in "$ROOT/cmake-build-debug/TCCCompiler" "$ROOT/build/TCCCompiler" "$ROOT/cmake-build-debug/Compiler" "$ROOT/build/Compiler"; do
    if [ -f "$candidate" ] || [ -L "$candidate" ]; then
        COMPILER="$candidate"
        break
    fi
done
if [ -z "$COMPILER" ]; then
    echo "[ERROR] Chemical compiler not found under $ROOT (looked in cmake-build-debug/ and build/)"
    exit 1
fi

# 2. Build
echo "[1/3] Building..."
mkdir -p "$BUILD_DIR"
BUILD_LOG="$BUILD_DIR/build_test.txt"
(cd "$ROOT" && "$COMPILER" "lang/compiled/playground/chemical.mod" --no-cache -o "$APP_DIR/playground.exe" >"$BUILD_LOG" 2>&1) || {
    echo "[BUILD FAILED] See $BUILD_LOG"
    grep -i "error" "$BUILD_LOG" | head -10
    exit 1
}
echo "  Build OK"

EXE="$APP_DIR/playground.exe"
if [ ! -f "$EXE" ]; then
    echo "[ERROR] Cannot find playground executable"
    exit 1
fi
echo "  Using exe: $EXE"

# 3. Kill anything already on the port
if command -v lsof >/dev/null 2>&1; then
    old_pids=$(lsof -ti :$PORT 2>/dev/null || true)
elif command -v netstat >/dev/null 2>&1; then
    old_pids=$(netstat -ano 2>/dev/null | grep ":$PORT " | grep LISTENING | awk '{print $NF}' | sort -u || true)
else
    old_pids=""
fi
if [ -n "$old_pids" ]; then
    for pid in $old_pids; do
        kill -9 $pid 2>/dev/null || true
    done
    sleep 2
    echo "  Killed old process on port $PORT"
fi

# 4. Start server (repo root so dev asset paths resolve)
(cd "$ROOT" && "$EXE") &
SERVER_PID=$!
echo "[2/3] Server started (PID $SERVER_PID), waiting up to 10s..."

ready=0
for _ in $(seq 1 50); do
    if ! kill -0 $SERVER_PID 2>/dev/null; then
        echo "[ERROR] Server process exited early"
        exit 1
    fi
    code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 1 --max-time 2 "$URL/" 2>/dev/null || echo "000")
    if [ "$code" != "000" ]; then ready=1; break; fi
    sleep 0.2
done
if [ $ready -ne 1 ]; then
    echo "[ERROR] Server never became reachable on port $PORT"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
fi
echo "  Server ready"

# 5. Probe endpoints
echo "[3/3] Probing endpoints..."
test_url "home"          "/"                 200
test_url "playground"    "/playground"       200
test_url "favicon"       "/Favicon.png"      200
test_url "logo"          "/Logo.png"         200
test_url "install.sh"    "/install.sh"       302
test_url "install.ps1"   "/install.ps1"      302
test_url "test.sh"       "/test.sh"          302
test_url "test.ps1"      "/test.ps1"         302

# HEAD probe: curl -I sends HEAD; the route must answer 200 (domain ownership check)
head_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 --max-time 5 -I "$URL/" 2>/dev/null || echo "000")
if [ "$head_code" = "200" ]; then
    echo "  [OK]   HEAD /  (domain check)"
    pass=$((pass + 1))
else
    echo "  [FAIL] HEAD /  (got $head_code, want 200)"
    fail=$((fail + 1))
fi

# POST /submit with invalid JSON must yield a JSON error envelope (HTTP 200 with error body)
submit_body=$(curl -s --connect-timeout 3 --max-time 5 -X POST -d 'not json' "$URL/submit" 2>/dev/null || echo "")
if echo "$submit_body" | grep -q '"type" : "error"'; then
    echo "  [OK]   POST /submit (invalid json) → error envelope"
    pass=$((pass + 1))
else
    echo "  [FAIL] POST /submit (invalid json) → unexpected body: $(echo "$submit_body" | head -c 120)"
    fail=$((fail + 1))
fi

# 6. Stop server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Summary
total=$((pass + fail))
echo ""
if [ $fail -eq 0 ]; then
    echo "[playground] All $total endpoint checks OK"
    exit 0
else
    echo "[playground] $fail of $total endpoint checks FAILED"
    exit 1
fi
