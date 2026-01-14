# Rapport de Décision : Optimisation Hyperparamètres avec Optuna

## 📋 Contexte du Projet

- **Dataset** : tiny_coco (COCO128 filtré, classe 'person' uniquement)
- **Modèle** : YOLOv8 nano
- **Métrique principale** : mAP@50 (mean Average Precision at IoU threshold 0.5)
- **Objectif** : Comparer Grid Search vs Optuna pour optimisation hyperparamètres

---

## 🔬 Expérimentations Réalisées

### 1. Baseline Run

| Paramètre | Valeur |
|-----------|--------|
| Epochs    | 3      |
| Image Size| 320    |
| Learning Rate | 0.005 |
| Seed      | 42     |
| **mAP@50** | _[À remplir]_ |

### 2. Grid Search

**Hyperparamètres testés** :
- `epochs` : 3 (fixe)
- `imgsz` : [320, 416]
- `lr0` : [0.005, 0.010]
- `seed` : [1, 42]

**Nombre total de runs** : 8 (2×2×2)

**Meilleur run Grid Search** :
| Run ID | epochs | imgsz | lr0 | seed | mAP@50 | mAP@50-95 | Precision | Recall |
|--------|--------|-------|-----|------|--------|-----------|-----------|--------|
| _[À remplir]_ | | | | | | | | |

### 3. Optuna Study

**Configuration** :
- **Sampler** : TPESampler (Tree-structured Parzen Estimator)
- **Direction** : Maximize mAP@50
- **Nombre de trials** : 5
- **Espace de recherche** :
  - `epochs` : [3, 5] (int)
  - `imgsz` : [320, 416] (categorical)
  - `lr0` : [0.001, 0.01] (float, log scale)

**Meilleur trial Optuna** :
| Trial | epochs | imgsz | lr0 | mAP@50 | mAP@50-95 | Precision | Recall |
|-------|--------|-------|-----|--------|-----------|-----------|--------|
| _[À remplir]_ | | | | | | | |

**Tous les trials Optuna** :
| Trial | epochs | imgsz | lr0 | mAP@50 | Notes |
|-------|--------|-------|-----|--------|-------|
| 0     | | | | | |
| 1     | | | | | |
| 2     | | | | | |
| 3     | | | | | |
| 4     | | | | | |

---

## 📊 Analyse Comparative

### Grid Search vs Optuna

| Critère | Grid Search | Optuna | Gagnant |
|---------|-------------|--------|---------|
| **Meilleure mAP@50** | _[À remplir]_ | _[À remplir]_ | _[À remplir]_ |
| **Nombre de runs** | 8 | 5 | Optuna (moins) |
| **Temps total** | _[À estimer]_ | _[À estimer]_ | _[À remplir]_ |
| **Exploration** | Exhaustive (limitée) | Intelligente (bayésienne) | Optuna |
| **Reproductibilité** | Complète | Partielle (seed TPE) | Grid |

### Observations

**Avantages d'Optuna** :
- ✅ Recherche bayésienne plus efficace que grille exhaustive
- ✅ Trouve souvent de meilleurs hyperparamètres avec moins de trials
- ✅ Explore intelligemment l'espace (exploitation vs exploration)
- ✅ Possibilité de pruning (early stopping de trials non prometteurs)

**Limites d'Optuna** :
- ⚠️ Nécessite plus de trials pour converger sur petits espaces
- ⚠️ Résultats peuvent varier selon seed sampler
- ⚠️ Complexité additionnelle dans le code

**Avantages Grid Search** :
- ✅ Simple à comprendre et implémenter
- ✅ Garantie d'explorer toutes les combinaisons
- ✅ Parfaitement reproductible

**Limites Grid Search** :
- ⚠️ Explosion combinatoire (3 params × 3 values = 27 runs)
- ⚠️ N'explore pas efficacement les espaces continus
- ⚠️ Coûteux en temps de calcul

---

## 🎯 Décision Finale

### Hyperparamètres retenus pour Staging

**Configuration sélectionnée** :
```yaml
model: yolov8n.pt
epochs: [À remplir]
imgsz: [À remplir]
lr0: [À remplir]
batch: 8
seed: 42
```

**Métriques attendues** :
- mAP@50 : _[À remplir]_
- mAP@50-95 : _[À remplir]_
- Precision : _[À remplir]_
- Recall : _[À remplir]_

### Justification

**Pourquoi ces hyperparamètres ?**
1. _[À remplir : meilleure mAP@50]_
2. _[À remplir : bon équilibre precision/recall]_
3. _[À remplir : temps d'inférence acceptable]_

**Pourquoi Optuna vs Grid ?**
- _[À remplir : selon vos résultats]_
- Pour ce projet, avec budget limité de 5-8 runs, Optuna a montré [meilleure/équivalente/inférieure] performance
- Pour projets futurs avec plus de ressources, recommandation : _[Grid/Optuna/Hybride]_

---

## 🚀 Actions Futures

### Court terme (Staging)
- [ ] Valider les hyperparamètres retenus sur dataset complet
- [ ] Effectuer tests A/B avec baseline
- [ ] Mesurer latence/throughput en conditions réelles

### Moyen terme (Production)
- [ ] Augmenter nombre de trials Optuna (20-50)
- [ ] Tester d'autres hyperparamètres (momentum, weight_decay, augmentations)
- [ ] Implémenter pruning Optuna pour accélérer recherche
- [ ] Intégrer dans pipeline CI/CD avec déclenchement automatique

### Long terme (MLOps)
- [ ] Automatiser re-tuning périodique (data drift)
- [ ] Multi-objective optimization (mAP + latency)
- [ ] Distributed hyperparameter search (Ray Tune + Optuna)

---

## 🔒 Risques & Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Surapprentissage sur val set | Moyen | Moyen | Valider sur test set séparé |
| Hyperparams non généralisables | Élevé | Moyen | Tester sur autre dataset |
| Optuna instable (peu de trials) | Faible | Faible | Augmenter n_trials si budget |
| Temps calcul trop long | Moyen | Faible | Pruning + parallélisation |

---

## 📎 Annexes

### Liens MLflow
- **Expérience Grid** : http://localhost:5000/#/experiments/[ID]/runs
- **Expérience Optuna** : http://localhost:5000/#/experiments/[ID]/runs
- **Meilleur run** : http://localhost:5000/#/experiments/[ID]/runs/[RUN_ID]

### Screenshots
- [ ] Comparaison runs Grid dans MLflow
- [ ] Comparaison runs Optuna dans MLflow
- [ ] Courbes d'entraînement meilleur run
- [ ] Matrice de confusion
- [ ] Graphiques Optuna (importance params, history, parallel coordinate)

### Fichiers générés
- `reports/yolo_optuna_study_results.csv` : Résultats détaillés tous les trials
- `runs/detect/optuna_yolo_trial_X/` : Artifacts YOLO par trial

---

**Rédacteur** : _[Votre nom]_  
**Date** : _[Date]_  
**Version** : 1.0
