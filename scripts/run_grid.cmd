@echo off
REM scripts/run_grid.cmd

REM Set MLflow tracking URI
set MLFLOW_TRACKING_URI=http://localhost:5000

echo Starting grid search for YOLO hyperparameters...
echo.

REM Grid parameters
set SIZES=320 416
set LRS=0.005 0.010
set SEEDS=1 42

for %%s in (%SIZES%) do (
  for %%l in (%LRS%) do (
    for %%d in (%SEEDS%) do (
      echo Running: epochs=3, imgsz=%%s, lr0=%%l, seed=%%d
      python -u -m src.train_cv ^
        --data data/tiny_coco.yaml ^
        --model yolov8n.pt ^
        --epochs 3 ^
        --imgsz %%s ^
        --lr0 %%l ^
        --seed %%d ^
        --exp-name cv_yolo_tiny
      echo.
    )
  )
)

echo Grid search completed!
echo View results in MLflow UI: http://localhost:5000
