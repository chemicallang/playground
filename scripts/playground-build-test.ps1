#!/usr/bin/env pwsh
# Build the playground server, boot it, probe every route over HTTP, stop it.
# Usage: pwsh lang/compiled/playground/scripts/playground-build-test.ps1
# This script ALWAYS exits cleanly — never blocks.

param(
    [int]$Port = 8099
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$appDir = Join-Path $root "lang\compiled\playground"
$buildDir = Join-Path $appDir "build"
$exe = Join-Path $appDir "playground.exe"
$mod = Join-Path $appDir "chemical.mod"
$buildLog = Join-Path $buildDir "build_test.txt"
$url = "http://localhost:$Port"

$script:pass = 0
$script:fail = 0

function Test-Url {
    param([string]$Label, [string]$Path, [string]$Expect)
    $status = "000"
    try {
        $resp = curl.exe -s -o NUL -w "%{http_code}" --connect-timeout 3 --max-time 5 "$url$Path" 2>$null
        if ($resp) { $status = $resp }
    } catch { $status = "000" }
    if ($status -eq $Expect) {
        Write-Host "  [OK]   $Label  $Path  ($status)"
        $script:pass++
    } else {
        Write-Host "  [FAIL] $Label  $Path  (got $status, want $Expect)"
        $script:fail++
    }
}

Write-Host "=== Playground Build + Endpoint Test ==="

# 1. Locate the compiler
$compiler = $null
foreach ($candidate in @(
    (Join-Path $root "cmake-build-debug\TCCCompiler.exe"),
    (Join-Path $root "build\TCCCompiler.exe"),
    (Join-Path $root "cmake-build-debug\Compiler.exe"),
    (Join-Path $root "build\Compiler.exe"))) {
    if (Test-Path $candidate) { $compiler = $candidate; break }
}
if (-not $compiler) {
    Write-Host "[ERROR] Chemical compiler not found under $root (looked in cmake-build-debug\ and build\)"
    exit 1
}

# 2. Build
Write-Host "[1/3] Building..."
if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir -Force | Out-Null }

Push-Location $root
try {
    & $compiler "lang\compiled\playground\chemical.mod" --no-cache -o $exe 1> $buildLog 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[BUILD FAILED] See $buildLog"
        Select-String -Path $buildLog -Pattern "error" | Select-Object -First 10
        exit 1
    }
} finally {
    Pop-Location
}
Write-Host "  Build OK"

if (-not (Test-Path $exe)) {
    Write-Host "[ERROR] Cannot find playground executable"
    exit 1
}
Write-Host "  Using exe: $exe"

# 3. Start server (repo root so dev asset paths resolve)
Write-Host "[2/3] Starting server on port $Port..."
$serverProc = Start-Process -FilePath $exe -WorkingDirectory $root -ArgumentList "-p", "$Port" -PassThru -NoNewWindow
try {
    $ready = $false
    for ($i = 0; $i -lt 50; $i++) {
        if ($serverProc.HasExited) {
            Write-Host "[ERROR] Server process exited early"
            exit 1
        }
        $code = "000"
        try {
            $r = curl.exe -s -o NUL -w "%{http_code}" --connect-timeout 1 --max-time 2 "$url/" 2>$null
            if ($r) { $code = $r }
        } catch { $code = "000" }
        if ($code -ne "000") { $ready = $true; break }
        Start-Sleep -Milliseconds 200
    }
    if (-not $ready) {
        Write-Host "[ERROR] Server never became reachable on port $Port"
        exit 1
    }
    Write-Host "  Server ready"

    # 4. Probe endpoints
    Write-Host "[3/3] Probing endpoints..."
    Test-Url "home"        "/"             "200"
    Test-Url "playground"  "/playground"   "200"
    Test-Url "favicon"     "/Favicon.png"  "200"
    Test-Url "logo"        "/Logo.png"     "200"
    Test-Url "install.sh"  "/install.sh"   "302"
    Test-Url "install.ps1" "/install.ps1"  "302"
    Test-Url "test.sh"     "/test.sh"      "302"
    Test-Url "test.ps1"    "/test.ps1"     "302"

    # HEAD / must answer 200 (domain ownership check)
    $headCode = "000"
    try {
        $r = curl.exe -s -o NUL -w "%{http_code}" --connect-timeout 3 --max-time 5 -I "$url/" 2>$null
        if ($r) { $headCode = $r }
    } catch { $headCode = "000" }
    if ($headCode -eq "200") {
        Write-Host "  [OK]   HEAD /  (domain check)"
        $script:pass++
    } else {
        Write-Host "  [FAIL] HEAD /  (got $headCode, want 200)"
        $script:fail++
    }

    # POST /submit with invalid JSON must yield a JSON error envelope
    $submitBody = ""
    try {
        $submitBody = curl.exe -s --connect-timeout 3 --max-time 5 -X POST -d "not json" "$url/submit" 2>$null
    } catch { $submitBody = "" }
    if ($submitBody -match '"type" : "error"') {
        Write-Host "  [OK]   POST /submit (invalid json) -> error envelope"
        $script:pass++
    } else {
        Write-Host "  [FAIL] POST /submit (invalid json) -> unexpected body: $submitBody"
        $script:fail++
    }
} finally {
    # 5. Stop server
    if (-not $serverProc.HasExited) {
        Stop-Process -Id $serverProc.Id -Force -ErrorAction SilentlyContinue
    }
    Wait-Process -Id $serverProc.Id -ErrorAction SilentlyContinue
}

# Summary
$total = $script:pass + $script:fail
Write-Host ""
if ($script:fail -eq 0) {
    Write-Host "[playground] All $total endpoint checks OK"
    exit 0
} else {
    Write-Host "[playground] $($script:fail) of $total endpoint checks FAILED"
    exit 1
}
