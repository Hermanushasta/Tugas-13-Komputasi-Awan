# build.ps1 - PowerShell Build Script Alternative to Makefile
# Implementasi Build, Release, Run untuk Windows PowerShell

param(
    [string]$Command = "help"
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host ""
    Write-Host "=== Simple Task Manager - Build Script ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1 <command>"
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Yellow
    Write-Host "  install    - Install dependencies (Build stage)" -ForegroundColor White
    Write-Host "  build      - Build application artifacts" -ForegroundColor White
    Write-Host "  release    - Create release package with config" -ForegroundColor White
    Write-Host "  run        - Run the application (Run stage)" -ForegroundColor White
    Write-Host "  dev        - Run in development mode" -ForegroundColor White
    Write-Host "  clean      - Clean build artifacts" -ForegroundColor White
    Write-Host "  test       - Test API endpoints" -ForegroundColor White
    Write-Host "  deploy     - Complete workflow (clean + build + release)" -ForegroundColor White
    Write-Host ""
    Write-Host "=== Twelve-Factor App Principles Implemented ===" -ForegroundColor Cyan
    Write-Host "1. Codebase      - Git repository" -ForegroundColor Green
    Write-Host "2. Dependencies  - requirements.txt" -ForegroundColor Green
    Write-Host "3. Config        - .env file" -ForegroundColor Green
    Write-Host "4. Concurrency   - Modular services" -ForegroundColor Green
    Write-Host "5. Logs          - Structured logging to stdout" -ForegroundColor Green
    Write-Host "6. Build/Release - This script (equivalent to Makefile)" -ForegroundColor Green
    Write-Host ""
}

function Invoke-Install {
    Write-Host ""
    Write-Host "=== BUILD STAGE: Installing dependencies ===" -ForegroundColor Green
    Write-Host ""
    
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    
    Write-Host ""
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
}

function Invoke-Build {
    Write-Host ""
    Write-Host "=== BUILD STAGE: Building application ===" -ForegroundColor Green
    Write-Host ""
    
    # Create build directory
    if (-not (Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" | Out-Null
    }
    
    # Create build info
    $buildInfo = @"
Build timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Git commit: $(try { git rev-parse HEAD 2>$null } catch { "Not a git repository" })
Python version: $(python --version)
"@
    
    $buildInfo | Out-File -FilePath "build\build-info.txt" -Encoding UTF8
    
    Write-Host "✓ Build completed" -ForegroundColor Green
    Write-Host "  Build info saved to: build\build-info.txt" -ForegroundColor Gray
}

function Invoke-Release {
    Write-Host ""
    Write-Host "=== RELEASE STAGE: Creating release package ===" -ForegroundColor Green
    Write-Host ""
    
    # Create release directory
    if (-not (Test-Path "release")) {
        New-Item -ItemType Directory -Path "release" | Out-Null
    }
    
    Write-Host "Copying application files..." -ForegroundColor Gray
    
    # Copy Python files
    Copy-Item "*.py" "release\" -Force
    
    # Copy requirements and other files
    Copy-Item "requirements.txt" "release\" -Force
    Copy-Item "Makefile" "release\" -Force
    Copy-Item "build.ps1" "release\" -Force
    
    # Copy .env file
    if (Test-Path ".env") {
        Copy-Item ".env" "release\" -Force
    } else {
        Write-Host "  .env not found, copying .env.example..." -ForegroundColor Yellow
        Copy-Item ".env.example" "release\.env" -Force
    }
    
    # Copy services directory
    if (-not (Test-Path "release\services")) {
        New-Item -ItemType Directory -Path "release\services" | Out-Null
    }
    Copy-Item "services\*.py" "release\services\" -Force
    
    # Copy build info
    if (Test-Path "build\build-info.txt") {
        Copy-Item "build\build-info.txt" "release\" -Force
    }
    
    # Create release info
    $releaseInfo = @"
Release version: 1.0.0
Release date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Environment: production-ready
Build stage: completed
Release stage: completed
"@
    
    $releaseInfo | Out-File -FilePath "release\RELEASE-INFO.txt" -Encoding UTF8
    
    Write-Host ""
    Write-Host "✓ Release package created in 'release' directory" -ForegroundColor Green
    Write-Host "  Package contents:" -ForegroundColor Gray
    Get-ChildItem "release" -Recurse | ForEach-Object {
        Write-Host "    $($_.FullName.Replace((Get-Location).Path, '.'))" -ForegroundColor Gray
    }
}

function Invoke-Run {
    Write-Host ""
    Write-Host "=== RUN STAGE: Starting application ===" -ForegroundColor Green
    Write-Host ""
    
    if (-not (Test-Path ".env")) {
        Write-Host "WARNING: .env file not found, using defaults" -ForegroundColor Yellow
    }
    
    Write-Host "Starting Flask application..." -ForegroundColor Gray
    Write-Host ""
    
    python app.py
}

function Invoke-Dev {
    Write-Host ""
    Write-Host "=== DEVELOPMENT MODE ===" -ForegroundColor Green
    Write-Host ""
    
    $env:FLASK_ENV = "development"
    $env:FLASK_DEBUG = "1"
    
    python app.py
}

function Invoke-Clean {
    Write-Host ""
    Write-Host "=== Cleaning build artifacts ===" -ForegroundColor Green
    Write-Host ""
    
    $itemsToClean = @(
        "build",
        "release",
        "__pycache__",
        "services\__pycache__"
    )
    
    foreach ($item in $itemsToClean) {
        if (Test-Path $item) {
            Remove-Item -Recurse -Force $item
            Write-Host "  Removed: $item" -ForegroundColor Gray
        }
    }
    
    # Clean .egg-info directories
    Get-ChildItem -Directory -Filter "*.egg-info" -Recurse | ForEach-Object {
        Remove-Item -Recurse -Force $_.FullName
        Write-Host "  Removed: $($_.FullName)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "✓ Clean completed" -ForegroundColor Green
}

function Invoke-Test {
    Write-Host ""
    Write-Host "=== Running tests ===" -ForegroundColor Green
    Write-Host ""
    
    try {
        Write-Host "Testing health endpoint..." -ForegroundColor Gray
        $health = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing
        Write-Host "✓ Health check passed" -ForegroundColor Green
        Write-Host $health.Content -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "Testing task creation..." -ForegroundColor Gray
        $body = @{
            title = "Test Task"
            description = "Test Description"
        } | ConvertTo-Json
        
        $task = Invoke-WebRequest -Uri "http://localhost:5000/api/tasks" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -UseBasicParsing
            
        Write-Host "✓ Task creation passed" -ForegroundColor Green
        Write-Host $task.Content -ForegroundColor Cyan
        
    } catch {
        Write-Host ""
        Write-Host "✗ Tests failed - is the app running?" -ForegroundColor Red
        Write-Host "  Start the app first with: .\build.ps1 run" -ForegroundColor Yellow
    }
}

function Invoke-Deploy {
    Write-Host ""
    Write-Host "=== DEPLOYMENT WORKFLOW ===" -ForegroundColor Cyan
    Write-Host ""
    
    Invoke-Clean
    Invoke-Build
    Invoke-Release
    
    Write-Host ""
    Write-Host "=== DEPLOYMENT READY ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Release package created in 'release' directory" -ForegroundColor White
    Write-Host ""
    Write-Host "To run:" -ForegroundColor Yellow
    Write-Host "  cd release" -ForegroundColor White
    Write-Host "  python app.py" -ForegroundColor White
    Write-Host ""
    Write-Host "Or:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1 run" -ForegroundColor White
    Write-Host ""
}

# Main script execution
switch ($Command.ToLower()) {
    "install" { Invoke-Install }
    "build" { Invoke-Build }
    "release" { Invoke-Release }
    "run" { Invoke-Run }
    "dev" { Invoke-Dev }
    "clean" { Invoke-Clean }
    "test" { Invoke-Test }
    "deploy" { Invoke-Deploy }
    "help" { Show-Help }
    default {
        Write-Host ""
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
