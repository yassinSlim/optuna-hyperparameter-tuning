# Setup Script for TP6 - Optuna YOLO
# This script automates the initial setup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TP6 - Optuna YOLO Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python version
Write-Host "[1/7] Checking Python version..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($pythonVersion -match "Python 3\.(8|9|10|11|12)") {
    Write-Host "✓ Python version OK: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Python 3.8+ required. Current: $pythonVersion" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Check Docker
Write-Host "[2/7] Checking Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Create virtual environment
Write-Host "[3/7] Creating virtual environment..." -ForegroundColor Yellow
if (Test-Path ".venv") {
    Write-Host "✓ Virtual environment already exists" -ForegroundColor Green
} else {
    python -m venv .venv
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
}
Write-Host ""

# Step 4: Activate and install dependencies
Write-Host "[4/7] Installing dependencies..." -ForegroundColor Yellow
& .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 5: Start Docker services
Write-Host "[5/7] Starting Docker services (MLflow + MinIO)..." -ForegroundColor Yellow
docker compose up -d
Start-Sleep -Seconds 5
$containers = docker compose ps --format json | ConvertFrom-Json
if ($containers.Count -ge 2) {
    Write-Host "✓ Docker services started" -ForegroundColor Green
    Write-Host "  - MLflow UI: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "  - MinIO Console: http://localhost:9001" -ForegroundColor Cyan
} else {
    Write-Host "⚠ Docker services may not be fully started. Check with 'docker compose ps'" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Generate dataset
Write-Host "[6/7] Generating tiny_coco dataset..." -ForegroundColor Yellow
if (Test-Path "data\tiny_coco\images\train") {
    Write-Host "✓ Dataset already exists" -ForegroundColor Green
} else {
    python tools\make_tiny_person_from_coco128.py
    Write-Host "✓ Dataset generated" -ForegroundColor Green
}
Write-Host ""

# Step 7: Set environment variables
Write-Host "[7/7] Setting environment variables..." -ForegroundColor Yellow
$env:MLFLOW_TRACKING_URI = "http://localhost:5000"
Write-Host "✓ MLFLOW_TRACKING_URI set to http://localhost:5000" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete! ✓" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Activate virtual environment:" -ForegroundColor White
Write-Host "   .\.venv\Scripts\Activate.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Run baseline:" -ForegroundColor White
Write-Host "   python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Run grid search:" -ForegroundColor White
Write-Host "   .\scripts\run_grid.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Run Optuna study:" -ForegroundColor White
Write-Host "   .\scripts\run_optuna.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "5. View results in MLflow UI:" -ForegroundColor White
Write-Host "   http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "For detailed instructions, see GUIDE.md" -ForegroundColor Yellow
Write-Host ""
