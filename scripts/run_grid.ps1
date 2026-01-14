# scripts/run_grid.ps1

# Set MLflow tracking URI
$env:MLFLOW_TRACKING_URI = "http://localhost:5000"

$Sizes = @(320, 416)
$LRs   = @(0.005, 0.010)
$Seeds = @(1, 42)

Write-Host "Starting grid search for YOLO hyperparameters..." -ForegroundColor Green
Write-Host ""

foreach ($size in $Sizes) {
  foreach ($lr in $LRs) {
    foreach ($seed in $Seeds) {
      Write-Host "Running: epochs=3, imgsz=$size, lr0=$lr, seed=$seed" -ForegroundColor Cyan
      python -u -m src.train_cv `
        --data data/tiny_coco.yaml `
        --model yolov8n.pt `
        --epochs 3 `
        --imgsz $size `
        --lr0 $lr `
        --seed $seed `
        --exp-name cv_yolo_tiny
      Write-Host ""
    }
  }
}

Write-Host "Grid search completed!" -ForegroundColor Green
Write-Host "View results in MLflow UI: http://localhost:5000" -ForegroundColor Cyan
