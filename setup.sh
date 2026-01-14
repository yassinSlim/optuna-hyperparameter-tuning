#!/bin/bash
# Setup Script for TP6 - Optuna YOLO
# This script automates the initial setup

echo "========================================"
echo "TP6 - Optuna YOLO Setup Script"
echo "========================================"
echo ""

# Step 1: Check Python version
echo "[1/7] Checking Python version..."
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
if [[ $PYTHON_VERSION =~ Python\ 3\.(8|9|10|11|12) ]]; then
    echo "✓ Python version OK: $PYTHON_VERSION"
else
    echo "✗ Python 3.8+ required. Current: $PYTHON_VERSION"
    exit 1
fi
echo ""

# Step 2: Check Docker
echo "[2/7] Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "✓ Docker found: $DOCKER_VERSION"
else
    echo "✗ Docker not found. Please install Docker."
    exit 1
fi
echo ""

# Step 3: Create virtual environment
echo "[3/7] Creating virtual environment..."
if [ -d ".venv" ]; then
    echo "✓ Virtual environment already exists"
else
    $PYTHON_CMD -m venv .venv
    echo "✓ Virtual environment created"
fi
echo ""

# Step 4: Activate and install dependencies
echo "[4/7] Installing dependencies..."
source .venv/bin/activate
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
echo "✓ Dependencies installed"
echo ""

# Step 5: Start Docker services
echo "[5/7] Starting Docker services (MLflow + MinIO)..."
docker compose up -d
sleep 5
CONTAINERS=$(docker compose ps --format json | jq -s 'length')
if [ "$CONTAINERS" -ge 2 ]; then
    echo "✓ Docker services started"
    echo "  - MLflow UI: http://localhost:5000"
    echo "  - MinIO Console: http://localhost:9001"
else
    echo "⚠ Docker services may not be fully started. Check with 'docker compose ps'"
fi
echo ""

# Step 6: Generate dataset
echo "[6/7] Generating tiny_coco dataset..."
if [ -d "data/tiny_coco/images/train" ]; then
    echo "✓ Dataset already exists"
else
    python tools/make_tiny_person_from_coco128.py
    echo "✓ Dataset generated"
fi
echo ""

# Step 7: Set environment variables
echo "[7/7] Setting environment variables..."
export MLFLOW_TRACKING_URI="http://localhost:5000"
echo "✓ MLFLOW_TRACKING_URI set to http://localhost:5000"
echo ""

# Summary
echo "========================================"
echo "Setup Complete! ✓"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Activate virtual environment:"
echo "   source .venv/bin/activate"
echo ""
echo "2. Run baseline:"
echo "   python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna"
echo ""
echo "3. Run grid search:"
echo "   bash scripts/run_grid.sh"
echo ""
echo "4. Run Optuna study:"
echo "   bash scripts/run_optuna.sh"
echo ""
echo "5. View results in MLflow UI:"
echo "   http://localhost:5000"
echo ""
echo "For detailed instructions, see GUIDE.md"
echo ""
