# Instructions Manuelles - TP6

## 🎯 Ce que vous devez faire manuellement

Bien que le projet soit entièrement configuré, certaines étapes nécessitent votre action directe pour compléter le TP6.

---

## 📋 Étapes Obligatoires

### 1. Fork et Clone du Projet ⚠️ IMPORTANT

**Action requise :**
```bash
# 1. Aller sur GitLab et créer un fork de ce projet
# 2. Cloner VOTRE fork (pas l'original)
git clone https://gitlab.com/VOTRE_USERNAME/optuna-cv-yolo.git
cd optuna-cv-yolo
```

**Pourquoi ?** Vous devez avoir votre propre copie pour pouvoir commit et push vos résultats.

---

### 2. Installation et Setup

**Action requise :**

**Option A - Setup Automatique (Recommandé)** :
```powershell
.\setup.ps1
```

**Option B - Setup Manuel** :
```powershell
# 1. Créer environnement virtuel
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 2. Installer dépendances
pip install -r requirements.txt

# 3. Démarrer Docker
docker compose up -d

# 4. Générer dataset
python tools/make_tiny_person_from_coco128.py

# 5. Configurer MLflow
$env:MLFLOW_TRACKING_URI = "http://localhost:5000"
```

---

### 3. Exécution des Expériences

#### A. Baseline Run (OBLIGATOIRE)

**Action requise :**
```powershell
python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna
```

**Vérification :**
- Ouvrir http://localhost:5000
- Voir le run dans l'expérience `yolo_baseline_optuna`
- Noter les métriques (mAP50, precision, recall)

#### B. Grid Search (OBLIGATOIRE)

**Action requise :**
```powershell
.\scripts\run_grid.ps1
```

**Durée attendue :** ~25 minutes (8 runs)

**Vérification :**
- Voir 8 runs dans MLflow expérience `cv_yolo_tiny`
- Comparer les résultats dans l'UI

#### C. Optuna Study (OBLIGATOIRE)

**Action requise :**
```powershell
.\scripts\run_optuna.ps1
```

**Durée attendue :** ~20-40 minutes (5 trials)

**Vérification :**
- Voir 5 runs dans MLflow expérience `cv_yolo_tiny_optuna`
- Noter les meilleurs hyperparamètres affichés dans la console
- Vérifier le fichier CSV généré : `reports/yolo_optuna_study_results.csv`

---

### 4. Analyse dans MLflow UI

**Actions requises :**

1. **Ouvrir MLflow** : http://localhost:5000

2. **Comparer Grid Search** :
   - Aller dans expérience `cv_yolo_tiny`
   - Sélectionner tous les runs (checkboxes)
   - Cliquer "Compare"
   - Identifier le meilleur run (tri par mAP50)
   - **Prendre un screenshot** → `images/grid_comparison.png`

3. **Comparer Optuna** :
   - Aller dans expérience `cv_yolo_tiny_optuna`
   - Sélectionner tous les runs
   - Cliquer "Compare"
   - Identifier le meilleur trial
   - **Prendre un screenshot** → `images/optuna_comparison.png`

4. **Examiner le meilleur run** :
   - Cliquer sur le best run Optuna
   - Onglet "Artifacts"
   - Voir `yolo_plots/results.png` (courbes train/val)
   - **Prendre un screenshot** → `images/best_run_artifacts.png`

---

### 5. Compléter le Rapport de Décision

**Action requise :**

1. **Copier le template** :
   ```powershell
   copy reports\templates\optuna_decision.md reports\OPTUNA_DECISION.md
   ```

2. **Remplir toutes les sections "À remplir"** :
   - Section 1 : Baseline (métriques)
   - Section 2 : Grid Search (tableau avec 8 runs)
   - Section 3 : Optuna Study (tableau avec 5 trials)
   - Section 4 : Analyse Comparative (qui gagne ?)
   - Section 5 : Décision Finale (hyperparamètres retenus)
   - Section 6 : Justification (pourquoi ces params ?)

3. **Insérer les screenshots** :
   ```markdown
   ![Comparaison Grid](../images/grid_comparison.png)
   ![Comparaison Optuna](../images/optuna_comparison.png)
   ```

**Aide pour remplir** :
- Copiez-collez les valeurs depuis MLflow UI
- Pour les tableaux, utilisez les runs affichés dans "Compare"
- Pour la décision, choisissez le run avec le meilleur mAP50

---

### 6. Screenshots Obligatoires

**Actions requises :**

Créer le dossier `images/` et prendre ces screenshots :

1. ✅ `mlflow_ui_initial.png` - Page d'accueil MLflow
2. ✅ `baseline_run.png` - Détails du run baseline
3. ✅ `grid_comparison.png` - Comparaison des 8 runs Grid
4. ✅ `optuna_comparison.png` - Comparaison des 5 trials Optuna
5. ✅ `best_run_artifacts.png` - Artifacts du meilleur run
6. ✅ `minio_console.png` (optionnel) - Console MinIO avec bucket

**Comment prendre un screenshot Windows** :
- `Win + Shift + S` : sélectionner zone
- Sauvegarder dans `images/`

---

### 7. Commit et Push sur GitLab

**Actions requises :**

```bash
# 1. Vérifier les fichiers modifiés
git status

# 2. Ajouter tous les fichiers
git add .

# 3. Commit avec message descriptif
git commit -m "Complete TP6: Optuna hyperparameter optimization

- Ran baseline, grid search, and Optuna study
- Compared Grid vs Optuna (best mAP50: X.XXXX)
- Completed decision report
- Added screenshots
"

# 4. Push vers votre fork GitLab
git push origin main
```

**Vérification :**
- Ouvrir votre fork sur GitLab
- Vérifier que tous les fichiers sont là
- Vérifier que les screenshots s'affichent dans le README

---

## 📊 Résumé : Qu'est-ce qui est automatisé vs manuel ?

| Tâche | Automatisé | Manuel |
|-------|------------|--------|
| Structure du projet | ✅ | |
| Code source (train_cv.py, optuna_yolo.py) | ✅ | |
| Scripts de lancement | ✅ | |
| Docker compose config | ✅ | |
| Templates de rapport | ✅ | |
| **Fork GitLab** | | ✅ |
| **Setup (venv, docker, dataset)** | ✅ (via setup.ps1) | ✅ (optionnel manuel) |
| **Lancer baseline** | | ✅ |
| **Lancer grid search** | | ✅ |
| **Lancer Optuna study** | | ✅ |
| **Analyser dans MLflow** | | ✅ |
| **Prendre screenshots** | | ✅ |
| **Remplir rapport** | | ✅ |
| **Commit et push** | | ✅ |

---

## ⏱️ Temps Estimé par Étape Manuelle

| Étape | Temps |
|-------|-------|
| Fork & clone | 2 min |
| Setup (automatique) | 5 min |
| Baseline run | 5 min |
| Grid search | 25 min (attente GPU) |
| Optuna study | 30 min (attente GPU) |
| Analyse MLflow | 15 min |
| Screenshots | 5 min |
| Remplir rapport | 30 min |
| Commit & push | 3 min |
| **TOTAL** | **~2h** |

---

## 🆘 Aide : Que faire si...

### ❓ "Je ne sais pas quoi mettre dans le rapport"

**Réponse :**
- Copiez les valeurs EXACTES depuis MLflow UI
- Pour "À remplir", remplacez par les chiffres de vos runs
- Exemple : `mAP50 : 0.6234` (pas de texte, juste la valeur)

### ❓ "Grid Search prend trop de temps"

**Réponse :**
- C'est normal (~25 minutes)
- Vous pouvez réduire le nombre de runs en éditant `scripts/run_grid.ps1`
- Ou augmenter la vitesse en réduisant epochs à 2

### ❓ "Optuna ne trouve pas de meilleurs hyperparamètres"

**Réponse :**
- Normal avec seulement 5 trials sur petit dataset
- Documentez cette observation dans votre rapport
- Expliquez que plus de trials seraient nécessaires

### ❓ "Je n'ai pas de GPU"

**Réponse :**
- Le code fonctionne sur CPU (juste plus lent)
- Attendu : ~10 min/epoch au lieu de ~2 min
- Réduisez epochs à 2 pour accélérer

---

## 📝 Checklist Finale Avant Soumission

- [ ] Fork GitLab créé et cloné
- [ ] Docker démarre correctement
- [ ] MLflow UI accessible (http://localhost:5000)
- [ ] Dataset tiny_coco généré (60 images)
- [ ] Baseline run visible dans MLflow
- [ ] 8 runs Grid Search terminés
- [ ] 5 trials Optuna terminés
- [ ] Rapport `reports/OPTUNA_DECISION.md` complété (aucun "À remplir")
- [ ] 5-6 screenshots dans `images/`
- [ ] Commit et push effectués
- [ ] Projet visible sur votre GitLab

---

## 🎓 Conseils Finaux

1. **Suivez la checklist** : [CHECKLIST.md](CHECKLIST.md) pour ne rien oublier
2. **Documentez tout** : prenez des notes pendant les exécutions
3. **Sauvegardez souvent** : commit réguliers sur Git
4. **Testez votre rapport** : relisez avant de soumettre
5. **Gardez les logs** : ils peuvent être utiles pour le rapport

**Bon travail ! 🚀**
