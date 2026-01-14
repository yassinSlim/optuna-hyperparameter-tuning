# TP6 - Optuna Hyperparameter Optimization pour YOLO

[![MLflow](https://img.shields.io/badge/MLflow-Tracking-blue)](http://localhost:5000)
[![Optuna](https://img.shields.io/badge/Optuna-HPO-orange)](https://optuna.org/)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-Detection-green)](https://github.com/ultralytics/ultralytics)

## 🎯 Objectif

Comparer **Grid Search** vs **Optuna** (recherche bayésienne) pour l'optimisation d'hyperparamètres dans l'entraînement de modèles YOLO.

## 📚 Documentation

- **[README.md](README.md)** - Vue d'ensemble et quick start
- **[GUIDE.md](GUIDE.md)** - Guide détaillé étape par étape
- **[reports/templates/optuna_decision.md](reports/templates/optuna_decision.md)** - Template de rapport à compléter

## ⚡ Quick Start

```powershell
# 1. Setup automatique (PowerShell)
.\setup.ps1

# 2. Activer l'environnement
.\.venv\Scripts\Activate.ps1

# 3. Lancer Optuna
.\scripts\run_optuna.ps1

# 4. Voir les résultats
start http://localhost:5000
```

## 📂 Structure du Projet

```
optuna-cv-yolo/
├── src/
│   ├── train_cv.py          # Entraînement YOLO avec MLflow
│   ├── optuna_yolo.py       # Optimisation Optuna
│   └── utils.py             # Utilitaires
├── scripts/
│   ├── run_optuna.ps1       # Lancer étude Optuna
│   ├── run_grid.ps1         # Lancer grid search
│   └── setup.ps1            # Setup automatique
├── data/
│   └── tiny_coco/           # Dataset minimal COCO
├── reports/
│   └── templates/           # Templates de rapports
├── docker-compose.yml       # MLflow + MinIO
└── requirements.txt         # Dépendances Python
```

## 🔬 Expériences

### 1. Baseline
```bash
python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna
```

### 2. Grid Search (8 runs)
```bash
.\scripts\run_grid.ps1
```

### 3. Optuna Study (5 trials)
```bash
.\scripts\run_optuna.ps1
```

## 📊 Résultats Attendus

| Méthode | Runs | Temps | Best mAP@50 |
|---------|------|-------|-------------|
| Baseline | 1 | ~5 min | Référence |
| Grid Search | 8 | ~25 min | À mesurer |
| Optuna | 5 | ~20 min | À mesurer |

## 🎓 Livrables

1. ✅ Code source complet (fork GitLab)
2. ✅ Screenshots MLflow UI
3. ✅ Rapport de décision complété
4. ✅ Comparaison Grid vs Optuna

## 🔗 Liens Utiles

- **MLflow UI**: http://localhost:5000
- **MinIO Console**: http://localhost:9001
- **Optuna Docs**: https://optuna.readthedocs.io/
- **YOLO Docs**: https://docs.ultralytics.com/

## 📝 Notes

- Dataset : 60 images (40 train / 10 val / 10 test)
- Classe : "person" uniquement
- Modèle : YOLOv8 nano (~6 MB)
- Temps CPU : ~5 min/epoch

## 🐛 Troubleshooting

Voir [GUIDE.md#troubleshooting](GUIDE.md#troubleshooting) pour résoudre les problèmes courants.

## 📧 Contact

Pour questions : voir votre enseignant ou le forum du cours.

---

**TP6 MLOps 2025-26** - Optimisation Hyperparamètres avec Optuna
