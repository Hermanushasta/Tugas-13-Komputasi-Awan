# Makefile untuk Build, Release, Run
# Prinsip 6: Build, Release, Run - Strict separation of build and run stages

.PHONY: help install build release run clean test dev

# Default target
help:
	@echo "=== Simple Task Manager - Makefile Commands ==="
	@echo "make install    - Install dependencies (Build stage)"
	@echo "make build      - Build application artifacts"
	@echo "make release    - Create release package with config"
	@echo "make run        - Run the application (Run stage)"
	@echo "make dev        - Run in development mode"
	@echo "make clean      - Clean build artifacts"
	@echo "make test       - Run tests"
	@echo ""
	@echo "=== Twelve-Factor App Principles Implemented ==="
	@echo "1. Codebase      - Git repository"
	@echo "2. Dependencies  - requirements.txt"
	@echo "3. Config        - .env file"
	@echo "4. Concurrency   - Modular services"
	@echo "5. Logs          - Structured logging to stdout"
	@echo "6. Build/Release - This Makefile"

# Build stage - Install dependencies
install:
	@echo "=== BUILD STAGE: Installing dependencies ==="
	python -m pip install --upgrade pip
	pip install -r requirements.txt
	@echo "✓ Dependencies installed"

# Build stage - Create virtual environment and install
build: install
	@echo "=== BUILD STAGE: Building application ==="
	@if not exist "build" mkdir build
	@echo Build timestamp: > build\build-info.txt
	@echo %date% %time% >> build\build-info.txt
	@echo Git commit: >> build\build-info.txt
	@git rev-parse HEAD >> build\build-info.txt 2>nul || echo "Not a git repository" >> build\build-info.txt
	@echo ✓ Build completed

# Release stage - Package application with configuration
release: build
	@echo "=== RELEASE STAGE: Creating release package ==="
	@if not exist "release" mkdir release
	@echo Copying application files...
	@xcopy /Y /Q *.py release\ >nul
	@xcopy /Y /Q requirements.txt release\ >nul
	@xcopy /Y /Q Makefile release\ >nul
	@if not exist "release\services" mkdir release\services
	@xcopy /Y /Q services\*.py release\services\ >nul
	@if exist ".env" (xcopy /Y /Q .env release\ >nul) else (xcopy /Y /Q .env.example release\.env >nul)
	@xcopy /Y /Q build\build-info.txt release\ >nul
	@echo Release version: 1.0.0 > release\RELEASE-INFO.txt
	@echo Release date: %date% %time% >> release\RELEASE-INFO.txt
	@echo ✓ Release package created in 'release' directory

# Run stage - Execute the application
run:
	@echo "=== RUN STAGE: Starting application ==="
	@if not exist ".env" (echo WARNING: .env file not found, using defaults)
	python app.py

# Development mode with auto-reload
dev:
	@echo "=== DEVELOPMENT MODE ==="
	@set FLASK_ENV=development
	@set FLASK_DEBUG=1
	python app.py

# Run with gunicorn (production-like)
run-prod:
	@echo "=== RUN STAGE: Starting with Gunicorn ==="
	gunicorn -w 4 -b 0.0.0.0:5000 app:app --log-level info

# Clean build artifacts
clean:
	@echo "=== Cleaning build artifacts ==="
	@if exist "build" rmdir /S /Q build
	@if exist "release" rmdir /S /Q release
	@if exist "__pycache__" rmdir /S /Q __pycache__
	@if exist "services\__pycache__" rmdir /S /Q services\__pycache__
	@for /d /r %%d in (*.egg-info) do @if exist "%%d" rmdir /S /Q "%%d"
	@echo ✓ Clean completed

# Test the application
test:
	@echo "=== Running tests ==="
	@echo Testing health endpoint...
	@curl -s http://localhost:5000/health || echo "App not running. Start with 'make run' first"
	@echo ""
	@echo Testing task creation...
	@curl -s -X POST http://localhost:5000/api/tasks -H "Content-Type: application/json" -d "{\"title\":\"Test Task\",\"description\":\"Test Description\"}" || echo "App not running"

# Complete workflow: build -> release -> run
deploy: clean build release
	@echo ""
	@echo "=== DEPLOYMENT READY ==="
	@echo "Release package created in 'release' directory"
	@echo "To run: cd release && python app.py"
	@echo "Or: make run"
