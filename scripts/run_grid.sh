#!/bin/bash
# scripts/run_grid.sh

# Set MLflow tracking URI
export MLFLOW_TRACKING_URI="http://localhost:5000"

SIZES=(320 416)
LRS=(0.005 0.010)
SEEDS=(1 42)

echo "Starting grid search for YOLO hyperparameters..."
echo ""

for size in "${SIZES[@]}"; do
  for lr in "${LRS[@]}"; do
    for seed in "${SEEDS[@]}"; do
      echo "Running: epochs=3, imgsz=$size, lr0=$lr, seed=$seed"
      python -u -m src.train_cv \
        --data data/tiny_coco.yaml \
        --model yolov8n.pt \
        --epochs 3 \
        --imgsz $size \
        --lr0 $lr \
        --seed $seed \
        --exp-name cv_yolo_tiny
      echo ""
    done
  done
done

echo "Grid search completed!"
echo "View results in MLflow UI: http://localhost:5000"
