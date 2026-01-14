# Guide d'Utilisation Complet - TP6 Optuna

## 📖 Table des Matières

1. [Prérequis](#prérequis)
2. [Installation](#installation)
3. [Configuration Docker](#configuration-docker)
4. [Génération du Dataset](#génération-du-dataset)
5. [Exécution des Expériences](#exécution-des-expériences)
6. [Analyse des Résultats](#analyse-des-résultats)
7. [Troubleshooting](#troubleshooting)

---

## 🔧 Prérequis

- **Python** : 3.8+ (recommandé 3.10)
- **Docker** : 20.10+ avec docker-compose
- **Git** : pour cloner le dépôt
- **RAM** : minimum 4 GB
- **Espace disque** : ~2 GB (dataset + artifacts)

---

## 📦 Installation

### 1. Cloner le dépôt

```powershell
git clone https://github.com/VOTRE_USERNAME/optuna-cv-yolo.git
cd optuna-cv-yolo
```

### 2. Créer l'environnement virtuel

**Windows PowerShell** :
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

**Windows CMD** :
```cmd
python -m venv .venv
.\.venv\Scripts\activate.bat
```

**Linux/macOS** :
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Installer les dépendances

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

**Dépendances principales** :
- `mlflow` : tracking des expériences
- `ultralytics` : YOLO v8
- `optuna` : optimisation hyperparamètres
- `opencv-python`, `pandas`, `matplotlib` : utilitaires

---

## 🐳 Configuration Docker

### 1. Démarrer les services

```powershell
docker compose up -d
```

**Services lancés** :
- **MLflow** : http://localhost:5000
- **MinIO** : http://localhost:9001 (console S3)

### 2. Vérifier le statut

```powershell
docker compose ps
```

**Output attendu** :
```
NAME                     STATUS      PORTS
optuna-cv-yolo-mlflow-1  Up          0.0.0.0:5000->5000/tcp
optuna-cv-yolo-minio-1   Up          0.0.0.0:9000-9001->9000-9001/tcp
```

### 3. Voir les logs (optionnel)

```powershell
docker compose logs -f mlflow
# Ctrl+C pour quitter
```

### 4. Accéder aux interfaces

- **MLflow UI** : http://localhost:5000
- **MinIO Console** : http://localhost:9001
  - Username : `minio`
  - Password : `minio12345`

---

## 📊 Génération du Dataset

### 1. Générer tiny_coco

```powershell
python tools/make_tiny_person_from_coco128.py
```

**Ce script** :
1. Télécharge COCO128 (~6 MB)
2. Filtre uniquement la classe "person"
3. Crée 3 splits :
   - Train : 40 images
   - Val : 10 images
   - Test : 10 images
4. Redimensionne à 320×320 px

**Output attendu** :
```
Downloading COCO128...
Download complete.
Dataset created at data/tiny_coco (train/val/test).
Train: 40 images
Val: 10 images
Test: 10 images
```

### 2. Vérifier la structure

```powershell
tree data/tiny_coco /F
```

**Structure attendue** :
```
data/tiny_coco/
├── images/
│   ├── train/ (40 .jpg)
│   ├── val/   (10 .jpg)
│   └── test/  (10 .jpg)
└── labels/
    ├── train/ (40 .txt)
    ├── val/   (10 .txt)
    └── test/  (10 .txt)
```

### 3. (Optionnel) Initialiser DVC

```powershell
dvc init
dvc add data/tiny_coco -R
git add data/tiny_coco.dvc .gitignore .dvc/ .gitattributes
git commit -m "Track dataset tiny_coco with DVC (TP6)"
```

---

## 🚀 Exécution des Expériences

### 0. Configurer MLflow Tracking URI

**PowerShell** :
```powershell
$env:MLFLOW_TRACKING_URI = "http://localhost:5000"
```

**CMD** :
```cmd
set MLFLOW_TRACKING_URI=http://localhost:5000
```

**Linux/macOS** :
```bash
export MLFLOW_TRACKING_URI="http://localhost:5000"
```

### 1. Run Baseline

```powershell
python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna
```

**Output attendu** :
```
Ultralytics YOLOv8.x.x ...
Epochs: 3/3
mAP@50: 0.xxxx
Run logged to MLflow: http://localhost:5000
```

**Vérification** :
- Ouvrir http://localhost:5000
- Naviguer vers expérience `yolo_baseline_optuna`
- Vérifier présence du run avec métriques

### 2. Grid Search (comparaison)

**PowerShell** :
```powershell
.\scripts\run_grid.ps1
```

**Linux/macOS** :
```bash
bash scripts/run_grid.sh
```

**Durée** : ~15-30 min (8 runs × 3 epochs)

**Vérification** :
- MLflow UI : expérience `cv_yolo_tiny`
- 8 runs avec noms `yolov8n_e3_sz[320|416]_lr0.[005|010]_s[1|42]`

### 3. Optuna Study

**PowerShell** :
```powershell
.\scripts\run_optuna.ps1
```

**Linux/macOS** :
```bash
bash scripts/run_optuna.sh
```

**Output attendu** :
```
============================================================
Starting Optuna Study: yolo_optuna_study
Number of trials: 5
MLflow experiment: cv_yolo_tiny_optuna
Search space:
  - epochs: [3, 5]
  - imgsz: [320, 416]
  - lr0: [0.001, 0.01] (log scale)
============================================================

[I 2026-01-14 ...] Trial 0 finished with value: 0.xxxx
...
============================================================
Optuna Study Completed!
============================================================
Best trial: X
Best value (mAP50): 0.xxxx
Best hyperparameters:
  - epochs: X
  - imgsz: XXX
  - lr0: 0.xxxx
============================================================

Study results saved to: reports/yolo_optuna_study_results.csv
```

**Durée** : ~20-40 min (5 trials × 3-5 epochs)

**Vérification** :
- MLflow UI : expérience `cv_yolo_tiny_optuna`
- 5 runs avec noms `optuna_yolo_trial_X_eY_szZZZ_lr0.XXXX`
- Fichier CSV : `reports/yolo_optuna_study_results.csv`

---

## 📈 Analyse des Résultats

### 1. Ouvrir MLflow UI

http://localhost:5000

### 2. Comparer les runs

#### Grid Search
1. Naviguer vers expérience `cv_yolo_tiny`
2. Sélectionner tous les runs (checkbox)
3. Cliquer sur **"Compare"**
4. Observer colonnes :
   - `params.epochs`, `params.imgsz`, `params.lr0`
   - `metrics.mAP50`, `metrics.precision`, `metrics.recall`

#### Optuna
1. Naviguer vers expérience `cv_yolo_tiny_optuna`
2. Sélectionner tous les runs
3. Cliquer sur **"Compare"**
4. Trier par `metrics.mAP50` (descending)
5. Identifier le meilleur trial

### 3. Examiner les artifacts

Pour chaque run :
1. Cliquer sur le run
2. Onglet **"Artifacts"** :
   - `yolo_plots/results.png` : courbes train/val
   - `yolo_plots/confusion_matrix.png`
   - `yolo_plots/PR_curve.png`
   - `weights/best.pt` : meilleur checkpoint

### 4. Télécharger le CSV de comparaison

Dans l'écran "Compare" :
1. Cliquer sur icône **"Download CSV"**
2. Sauvegarder dans `reports/mlflow_comparison.csv`

### 5. Visualiser les résultats Optuna

```powershell
# Optionnel : lancer Optuna Dashboard
optuna-dashboard sqlite:///optuna_study.db
# Ouvrir http://localhost:8080
```

**Note** : Le dashboard nécessite que l'étude soit sauvegardée dans une DB SQLite (à configurer dans `optuna_yolo.py` si souhaité).

---

## 📝 Remplir le Rapport de Décision

### 1. Copier le template

```powershell
copy reports\templates\optuna_decision.md reports\OPTUNA_DECISION.md
```

### 2. Compléter les sections

Éditer `reports/OPTUNA_DECISION.md` :

1. **Baseline Run** : copier métriques depuis MLflow
2. **Grid Search** : identifier meilleur run, remplir tableau
3. **Optuna Study** : remplir tableau avec tous les trials
4. **Analyse Comparative** : comparer mAP50 Grid vs Optuna
5. **Décision Finale** : choisir hyperparamètres à promouvoir
6. **Justification** : expliquer le choix

### 3. Ajouter les screenshots

Dans `images/` :
- `mlflow_grid_comparison.png`
- `mlflow_optuna_comparison.png`
- `mlflow_best_run_artifacts.png`
- `optuna_dashboard.png` (optionnel)

Référencer dans le rapport :
```markdown
![Comparaison Grid](../images/mlflow_grid_comparison.png)
```

---

## 🛠️ Troubleshooting

### Problème : Docker ne démarre pas

**Erreur** : `Error response from daemon: driver failed`

**Solution** :
```powershell
docker compose down
docker system prune -a
docker compose up -d
```

### Problème : MLflow inaccessible

**Erreur** : `Connection refused on http://localhost:5000`

**Vérifications** :
1. Docker container running :
   ```powershell
   docker compose ps
   ```
2. Logs MLflow :
   ```powershell
   docker compose logs mlflow
   ```
3. Port 5000 libre :
   ```powershell
   netstat -ano | findstr :5000
   ```

**Solution** : changer le port dans `docker-compose.yml` (ex: 5001:5000)

### Problème : Ultralytics installation failed

**Erreur** : `No module named 'ultralytics'`

**Solution** :
```powershell
pip install --upgrade ultralytics
```

### Problème : Out of memory

**Erreur** : `CUDA out of memory` ou process killed

**Solutions** :
1. Réduire batch size :
   ```powershell
   python -m src.train_cv --batch 4
   ```
2. Réduire image size :
   ```powershell
   python -m src.train_cv --imgsz 256
   ```
3. Utiliser CPU (plus lent) :
   ```powershell
   $env:CUDA_VISIBLE_DEVICES = ""
   ```

### Problème : Dataset not found

**Erreur** : `FileNotFoundError: data/tiny_coco.yaml`

**Solution** :
1. Vérifier existence :
   ```powershell
   dir data\tiny_coco.yaml
   ```
2. Regénérer dataset :
   ```powershell
   python tools/make_tiny_person_from_coco128.py
   ```

### Problème : Optuna trial failed

**Erreur** : `optuna.exceptions.TrialPruned`

**Cause** : Normal si pruning activé (early stopping)

**Solution** : ignorer, Optuna continue avec d'autres trials

### Problème : Permissions Docker (Linux)

**Erreur** : `permission denied while trying to connect to the Docker daemon`

**Solution** :
```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 📚 Commandes Utiles

### Docker

```powershell
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Nettoyer volumes (⚠️ perte de données)
docker compose down -v

# Logs temps réel
docker compose logs -f mlflow
```

### Python/MLflow

```powershell
# Lister expériences
mlflow experiments list --tracking-uri http://localhost:5000

# Lister runs d'une expérience
mlflow runs list --experiment-name cv_yolo_tiny_optuna

# Servir un modèle
mlflow models serve -m runs:/<RUN_ID>/model -p 5001
```

### Optuna

```powershell
# Lancer dashboard (si DB SQLite configurée)
optuna-dashboard sqlite:///optuna_study.db

# Créer graphiques depuis CSV
python -c "
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv('reports/yolo_optuna_study_results.csv')
df.plot(x='number', y='value', kind='line')
plt.savefig('reports/optuna_history.png')
"
```

---

## 🎓 Prochaines Étapes

1. ✅ Compléter `reports/OPTUNA_DECISION.md`
2. ✅ Prendre screenshots MLflow UI
3. ✅ Commiter sur GitLab :
   ```powershell
   git add .
   git commit -m "Complete TP6: Optuna hyperparameter optimization"
   git push
   ```
4. ✅ Préparer présentation (slides optionnels)

---

**Bon courage ! 🚀**
