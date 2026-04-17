# Optimized Flutter APK Build Script for Glomea
# This script generates 3 separate APKs (Split by ABI) with code obfuscation.

$projectDir = "c:\Projects\renal_app\kidneytrack\mobile"
Set-Location $projectDir

Write-Host "🚀 Starting Optimized Build..." -ForegroundColor Cyan

flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --split-per-abi

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Build Successful!" -ForegroundColor Green
    Write-Host "You can find your APKs in: build\app\outputs\flutter-apk\" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Build Failed!" -ForegroundColor Red
}
