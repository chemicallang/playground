#!/usr/bin/env pwsh
# Build and run the Playground server (not tests).
# Usage: pwsh lang/compiled/playground/scripts/serve.ps1
#        pwsh lang/compiled/playground/scripts/serve.ps1 -NoBuild
#        pwsh lang/compiled/playground/scripts/serve.ps1 -VerboseBuild

param(
    [switch]$NoBuild,
    [switch]$VerboseBuild
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$appDir = Join-Path $root "lang\compiled\playground"
$buildDir = Join-Path $appDir "build"
$exe = Join-Path $appDir "playground.exe"
$mod = Join-Path $appDir "chemical.mod"

Write-Host "=== Playground Server ==="

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
if (-not $NoBuild) {
    Write-Host "[1/2] Building server..."
    if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir -Force | Out-Null }

    $flags = @("lang\compiled\playground\chemical.mod", "--no-cache", "-o", $exe)
    if ($VerboseBuild) { $flags += "-v"; $flags += "-bm-modules" }

    Push-Location $root
    try {
        & $compiler @flags
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[BUILD FAILED]"
            exit 1
        }
    } finally {
        Pop-Location
    }
    Write-Host "  Build OK: $exe"
} else {
    Write-Host "[1/2] Skipping build (-NoBuild)"
}

if (-not (Test-Path $exe)) {
    Write-Host "[ERROR] Cannot find $exe"
    exit 1
}

# 3. Run — the app serves on port 8080 by default and resolves dev assets
# relative to the repo root, so run from there.
Write-Host "[2/2] Starting server (Ctrl+C to stop)..."
Push-Location $root
try {
    & $exe
} finally {
    Pop-Location
}
