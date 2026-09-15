#!/usr/bin/env pwsh
# Build and run @test-annotated tests for the Playground.
# Usage: pwsh lang/compiled/playground/scripts/test.ps1
#        pwsh lang/compiled/playground/scripts/test.ps1 -TestNames "test_valid_simple_name"
#        pwsh lang/compiled/playground/scripts/test.ps1 -NoBuild

param(
    [string]$TestNames = "",
    [string]$TestIds = "",
    [switch]$NoBuild,
    [switch]$VerboseTest
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$appDir = Join-Path $root "lang\compiled\playground"
$buildDir = Join-Path $appDir "build"
$exe = Join-Path $buildDir "tests.exe"
$mod = Join-Path $appDir "chemical.mod"

Write-Host "=== Playground Test Runner ==="

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

# 2. Build (test mode)
if (-not $NoBuild) {
    Write-Host "[1/2] Building tests.exe with --test..."
    if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Path $buildDir -Force | Out-Null }

    $flags = @("lang\compiled\playground\chemical.mod", "-o", $exe, "--test", "--no-cache")
    if ($VerboseTest) { $flags += "-v" }

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

# 3. Run tests
Write-Host "[2/2] Running tests..."
$runArgs = @()
if ($TestNames) { $runArgs += "--test-names"; $runArgs += $TestNames }
if ($TestIds) { $runArgs += "--test-ids"; $runArgs += $TestIds }

Push-Location $appDir
try {
    & $exe @runArgs
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "[playground] All tests passed"
} else {
    Write-Host "[playground] Some tests failed (exit code $exitCode)"
}
exit $exitCode
