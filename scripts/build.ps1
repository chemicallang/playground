#!/usr/bin/env pwsh
# Build the Playground server (app mode, not tests).
# Usage: pwsh lang/compiled/playground/scripts/build.ps1
#        pwsh lang/compiled/playground/scripts/build.ps1 -Verbose

param(
    [switch]$VerboseBuild
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$appDir = Join-Path $root "lang\compiled\playground"
$buildDir = Join-Path $appDir "build"
$exe = Join-Path $appDir "playground.exe"
$mod = Join-Path $appDir "chemical.mod"

Write-Host "=== Playground Build ==="

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
Write-Host "  Compiler: $compiler"

# 2. Build
if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir -Force | Out-Null }

$flags = @("lang\compiled\playground\chemical.mod", "--no-cache", "-o", $exe)
if ($VerboseBuild) { $flags += "-v"; $flags += "-bm-modules" }

Push-Location $root
try {
    Write-Host "[1/2] Compiling $mod ..."
    & $compiler @flags
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[BUILD FAILED]"
        exit 1
    }
    Write-Host "  Build OK: $exe"
} finally {
    Pop-Location
}

Write-Host "[2/2] Done"
Write-Host ""
Write-Host "Run the server:  pwsh lang/compiled/playground/scripts/serve.ps1 -NoBuild"
exit 0
