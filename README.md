# Optuna Hyperparameter Tuning for YOLO

[![MLflow](https://img.shields.io/badge/MLflow-Tracking-blue)](http://localhost:5000)
[![Optuna](https://img.shields.io/badge/Optuna-HPO-orange)](https://optuna.org/)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-Detection-green)](https://github.com/ultralytics/ultralytics)
[![Python](https://img.shields.io/badge/Python-3.8+-blue)](https://www.python.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED)](https://www.docker.com/)

A complete MLOps project implementing **hyperparameter optimization** with Optuna for YOLO object detection models. Compare Grid Search vs Bayesian Optimization (Optuna TPE) with comprehensive MLflow tracking.

## 🎯 Project Overview

This project demonstrates modern MLOps practices for hyperparameter tuning:

- **Grid Search**: Exhaustive search over 8 hyperparameter combinations
- **Optuna**: Intelligent Bayesian optimization (TPE Sampler)
- **MLflow**: Complete experiment tracking and artifact management
- **Docker**: Reproducible infrastructure (MLflow + MinIO S3)
- **YOLO**: State-of-the-art object detection on COCO dataset


## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Docker & Docker Compose
- 4GB RAM minimum
- ~2GB disk space

### One-Command Setup

**Windows:**
```powershell
.\setup.ps1
```

**Linux/macOS:**
```bash
bash setup.sh
```

This automatically:
- Creates Python virtual environment
- Installs dependencies (MLflow, Optuna, Ultralytics)
- Starts Docker services (MLflow + MinIO)
- Generates dataset (60 images: 40 train / 10 val / 10 test)

### Manual Setup

```bash
# 1. Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .\.venv\Scripts\Activate.ps1  # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Start services
docker compose up -d

# 4. Generate dataset
python tools/make_tiny_person_from_coco128.py

# 5. Set MLflow URI
export MLFLOW_TRACKING_URI="http://localhost:5000"
```

---

## 📊 Running Experiments

### 1. Baseline Run
```bash
python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline
```

### 2. Grid Search (8 runs)
```bash
.\scripts\run_grid.ps1      # Windows
bash scripts/run_grid.sh    # Linux/macOS
```

Tests all combinations:
- `imgsz`: [320, 416]
- `lr0`: [0.005, 0.01]
- `seed`: [1, 42]

### 3. Optuna Study (5 trials)
```bash
.\scripts\run_optuna.ps1    # Windows
bash scripts/run_optuna.sh  # Linux/macOS
```

Optimizes:
- `epochs`: [3, 5] (int)
- `imgsz`: [320, 416] (categorical)
- `lr0`: [0.001, 0.01] (float, log scale)

---

## 🎯 Key Features

### Hyperparameter Optimization
- **Grid Search**: Exhaustive exploration (8 combinations)
- **Optuna TPE**: Bayesian optimization (intelligent exploration)
- **Automatic logging**: All trials tracked in MLflow

### MLflow Integration
- **Parameters**: Model, epochs, imgsz, lr0, batch, seed
- **Metrics**: mAP@50, mAP@50-95, Precision, Recall
- **Artifacts**: Training plots, confusion matrices, model weights

### Infrastructure
- **MLflow Server**: Experiment tracking (http://localhost:5000)
- **MinIO S3**: Artifact storage (http://localhost:9001)
- **Docker Compose**: Reproducible environment

---

## 📁 Project Structure

```
optuna-hyperparameter-tuning/
├── src/
│   ├── train_cv.py          # YOLO training with MLflow
│   ├── optuna_yolo.py       # Optuna optimization
│   └── utils.py             # Utilities (seed management)
├── scripts/
│   ├── run_grid.ps1/sh/cmd  # Grid search launchers
│   └── run_optuna.ps1/sh/cmd # Optuna launchers
├── data/
│   └── tiny_coco.yaml       # Dataset configuration
├── tools/
│   └── make_tiny_person_from_coco128.py  # Dataset generator
├── reports/
│   └── templates/
│       └── optuna_decision.md  # Decision report template
├── docker-compose.yml       # Services (MLflow + MinIO)
├── requirements.txt         # Python dependencies
└── setup.ps1/sh            # Automated setup
```

---

## 📈 Results Analysis

### View in MLflow UI

Open http://localhost:5000 and:

1. Navigate to experiment `cv_yolo_tiny_optuna`
2. Select all runs → Click **"Compare"**
3. Sort by `metrics.mAP50` (descending)
4. Examine artifacts (plots, confusion matrix)

### Expected Results

| Method | Runs | Time | Typical Best mAP@50 |
|--------|------|------|---------------------|
| Baseline | 1 | ~5 min | 0.50-0.65 |
| Grid Search | 8 | ~25 min | 0.55-0.70 |
| Optuna | 5 | ~30 min | 0.60-0.75 |

**Key Finding**: Optuna often finds better hyperparameters with fewer trials due to intelligent exploration.

---

## 🔬 Technical Details

### Search Space

```python
# Optuna configuration
epochs:  suggest_int(3, 5)
imgsz:   suggest_categorical([320, 416])
lr0:     suggest_float(0.001, 0.01, log=True)
```

### Metrics

- **mAP@50**: Mean Average Precision at IoU threshold 0.5 (primary metric)
- **mAP@50-95**: mAP averaged over IoU 0.5-0.95 (stricter)
- **Precision**: True Positives / (True Positives + False Positives)
- **Recall**: True Positives / (True Positives + False Negatives)

### Dataset

- **Source**: COCO128 (filtered for "person" class)
- **Size**: 60 images total
  - Train: 40 images
  - Validation: 10 images
  - Test: 10 images
- **Resolution**: 320×320 pixels

---

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[GUIDE.md](GUIDE.md)** - Comprehensive guide with troubleshooting
- **[CHECKLIST.md](CHECKLIST.md)** - Step-by-step task list
- **[TP6_COMPLETION.md](TP6_COMPLETION.md)** - Project completion status

---

## 🛠️ Troubleshooting

### Docker won't start
```bash
docker compose down
docker compose up -d
```

### MLflow UI inaccessible
Check if services are running:
```bash
docker compose ps
docker compose logs mlflow
```

### Out of memory
Reduce batch size or image size:
```bash
python -m src.train_cv --batch 4 --imgsz 256
```

### Dataset not found
Generate the dataset:
```bash
python tools/make_tiny_person_from_coco128.py
```

See [GUIDE.md#troubleshooting](GUIDE.md#troubleshooting) for more solutions.

---

## 🎓 Learning Objectives

This project demonstrates:

1. **Hyperparameter Optimization**: Grid vs Bayesian methods
2. **Experiment Tracking**: MLflow for reproducibility
3. **Infrastructure as Code**: Docker Compose for services
4. **Object Detection**: YOLO model training and evaluation
5. **MLOps Best Practices**: Automation, documentation, version control

---

## 📊 Technologies Used

- **[Optuna](https://optuna.org/)**: Bayesian hyperparameter optimization
- **[MLflow](https://mlflow.org/)**: Experiment tracking and model registry
- **[Ultralytics YOLO](https://github.com/ultralytics/ultralytics)**: Object detection
- **[MinIO](https://min.io/)**: S3-compatible object storage
- **[Docker](https://www.docker.com/)**: Containerization
- **Python 3.8+**: Programming language

---

## 📝 License

This project is for educational purposes (MLOps course TP6).

---

## 🤝 Contributing

This is an educational project. For improvements:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📧 Contact

For questions about this project, please contact your course instructor.

---

**Built with ❤️ for MLOps education**
