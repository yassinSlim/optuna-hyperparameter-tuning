# scripts/run_optuna.ps1

# Set MLflow tracking URI
$env:MLFLOW_TRACKING_URI = "http://localhost:5000"

Write-Host "Starting Optuna hyperparameter optimization..." -ForegroundColor Green
Write-Host ""

# Run Optuna study with default parameters
python -m src.optuna_yolo `
    --data data/tiny_coco.yaml `
    --model yolov8n.pt `
    --n-trials 5 `
    --study-name yolo_optuna_study `
    --exp-name cv_yolo_tiny_optuna `
    --min-epochs 3 `
    --max-epochs 5 `
    --imgsz-choices 320 416 `
    --min-lr 0.001 `
    --max-lr 0.01 `
    --batch 8 `
    --seed 42

Write-Host ""
Write-Host "Optuna study completed!" -ForegroundColor Green
Write-Host "View results in MLflow UI: http://localhost:5000" -ForegroundColor Cyan
