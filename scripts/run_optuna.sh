#!/bin/bash
# scripts/run_optuna.sh

# Set MLflow tracking URI
export MLFLOW_TRACKING_URI="http://localhost:5000"

# Run Optuna study with default parameters
python -m src.optuna_yolo \
  --data data/tiny_coco.yaml \
  --model yolov8n.pt \
  --n-trials 5 \
  --study-name yolo_optuna_study \
  --exp-name cv_yolo_tiny_optuna \
  --min-epochs 3 \
  --max-epochs 5 \
  --imgsz-choices 320 416 \
  --min-lr 0.001 \
  --max-lr 0.01 \
  --batch 8 \
  --seed 42

echo ""
echo "Optuna study completed!"
echo "View results in MLflow UI: http://localhost:5000"
