# TP6 - Checklist de Réalisation

## ✅ Phase 1 : Setup Initial (15 min)

- [ ] **1.1** Forker le dépôt `optuna-cv-yolo` sur GitLab
- [ ] **1.2** Cloner votre fork localement
  ```bash
  git clone <URL_DE_VOTRE_FORK>
  cd optuna-cv-yolo
  ```
- [ ] **1.3** Exécuter le setup automatique
  ```powershell
  .\setup.ps1
  ```
  OU manuellement :
  - [ ] Créer venv et installer dépendances
  - [ ] Démarrer Docker (MLflow + MinIO)
  - [ ] Générer le dataset tiny_coco

## ✅ Phase 2 : Vérifications Infrastructure (10 min)

- [ ] **2.1** Vérifier Docker
  ```bash
  docker compose ps
  ```
  Attendu : 2-3 containers running

- [ ] **2.2** Accéder à MLflow UI
  - [ ] Ouvrir http://localhost:5000
  - [ ] Vérifier que la page charge
  - [ ] Screenshot : `images/mlflow_ui_initial.png`

- [ ] **2.3** Accéder à MinIO Console
  - [ ] Ouvrir http://localhost:9001
  - [ ] Login : minio / minio12345
  - [ ] Vérifier bucket `mlflow-artifacts`
  - [ ] Screenshot : `images/minio_console.png`

- [ ] **2.4** Vérifier le dataset
  ```bash
  dir data\tiny_coco\images\train
  ```
  Attendu : 40 images .jpg

## ✅ Phase 3 : Baseline Run (10 min)

- [ ] **3.1** Configurer MLflow URI
  ```powershell
  $env:MLFLOW_TRACKING_URI = "http://localhost:5000"
  ```

- [ ] **3.2** Lancer baseline
  ```bash
  python -m src.train_cv --epochs 3 --imgsz 320 --exp-name yolo_baseline_optuna
  ```

- [ ] **3.3** Vérifier dans MLflow
  - [ ] Rafraîchir http://localhost:5000
  - [ ] Trouver expérience `yolo_baseline_optuna`
  - [ ] Cliquer sur le run
  - [ ] Vérifier métriques : mAP50, precision, recall
  - [ ] Noter les valeurs dans `reports/OPTUNA_DECISION.md`
  - [ ] Screenshot : `images/baseline_run.png`

## ✅ Phase 4 : Grid Search (30 min)

- [ ] **4.1** Lancer grid search
  ```bash
  .\scripts\run_grid.ps1
  ```
  Attendu : 8 runs (2 imgsz × 2 lr × 2 seeds)

- [ ] **4.2** Analyser dans MLflow
  - [ ] Aller à expérience `cv_yolo_tiny`
  - [ ] Sélectionner tous les 8 runs
  - [ ] Cliquer "Compare"
  - [ ] Trier par mAP50 (descending)
  - [ ] Identifier le meilleur run
  - [ ] Screenshot : `images/grid_comparison.png`

- [ ] **4.3** Remplir tableau Grid dans rapport
  - [ ] Copier params : epochs, imgsz, lr0, seed
  - [ ] Copier metrics : mAP50, mAP50-95, precision, recall
  - [ ] Fichier : `reports/OPTUNA_DECISION.md` section 2

- [ ] **4.4** Exporter CSV (optionnel)
  - [ ] Dans "Compare" → Download CSV
  - [ ] Sauvegarder : `reports/grid_results.csv`

## ✅ Phase 5 : Optuna Study (40 min)

- [ ] **5.1** Lancer Optuna
  ```bash
  .\scripts\run_optuna.ps1
  ```
  Attendu : 5 trials

- [ ] **5.2** Noter les résultats console
  - [ ] Best trial number : _____
  - [ ] Best mAP50 : _____
  - [ ] Best params : epochs=___, imgsz=___, lr0=_____

- [ ] **5.3** Analyser dans MLflow
  - [ ] Aller à expérience `cv_yolo_tiny_optuna`
  - [ ] Sélectionner tous les 5 runs
  - [ ] Cliquer "Compare"
  - [ ] Trier par mAP50
  - [ ] Screenshot : `images/optuna_comparison.png`

- [ ] **5.4** Examiner meilleur trial
  - [ ] Cliquer sur best run
  - [ ] Onglet "Artifacts" → voir plots
  - [ ] Screenshot results.png : `images/optuna_best_results.png`
  - [ ] Screenshot confusion_matrix.png : `images/optuna_best_confusion.png`

- [ ] **5.5** Remplir tableau Optuna dans rapport
  - [ ] Copier params/metrics pour les 5 trials
  - [ ] Fichier : `reports/OPTUNA_DECISION.md` section 3

- [ ] **5.6** Vérifier CSV généré
  - [ ] Fichier existe : `reports/yolo_optuna_study_results.csv`
  - [ ] Ouvrir et vérifier 5 lignes

## ✅ Phase 6 : Analyse Comparative (20 min)

- [ ] **6.1** Comparer Grid vs Optuna
  - [ ] Meilleur mAP50 Grid : _____
  - [ ] Meilleur mAP50 Optuna : _____
  - [ ] Qui gagne ? _____

- [ ] **6.2** Compléter tableau comparatif
  - [ ] Fichier : `reports/OPTUNA_DECISION.md` section "Analyse Comparative"
  - [ ] Remplir les valeurs "À remplir"

- [ ] **6.3** Justifier le choix
  - [ ] Écrire 3-5 lignes sur pourquoi Grid/Optuna est meilleur
  - [ ] Mentionner : efficacité, mAP50, temps calcul

## ✅ Phase 7 : Rapport Final (30 min)

- [ ] **7.1** Copier template
  ```bash
  copy reports\templates\optuna_decision.md reports\OPTUNA_DECISION.md
  ```

- [ ] **7.2** Remplir toutes les sections
  - [ ] Section 1 : Baseline
  - [ ] Section 2 : Grid Search
  - [ ] Section 3 : Optuna Study
  - [ ] Section 4 : Analyse Comparative
  - [ ] Section 5 : Décision Finale
  - [ ] Section 6 : Actions Futures

- [ ] **7.3** Ajouter screenshots
  - [ ] Vérifier tous les PNG dans `images/`
  - [ ] Référencer dans le rapport avec chemins relatifs

- [ ] **7.4** Relecture
  - [ ] Pas de "À remplir" restants
  - [ ] Markdown valide
  - [ ] Tableaux bien formatés

## ✅ Phase 8 : Livrables GitLab (10 min)

- [ ] **8.1** Ajouter tous les fichiers
  ```bash
  git add .
  git status
  ```

- [ ] **8.2** Commit
  ```bash
  git commit -m "Complete TP6: Optuna hyperparameter optimization

  - Implemented Optuna study with 5 trials
  - Compared Grid Search vs Optuna
  - Best mAP50: [VALEUR]
  - Decision: [Grid/Optuna]
  "
  ```

- [ ] **8.3** Push vers GitLab
  ```bash
  git push origin main
  ```

- [ ] **8.4** Vérifier sur GitLab
  - [ ] Code source visible
  - [ ] README.md s'affiche
  - [ ] Images dans `images/` uploadées
  - [ ] Rapport dans `reports/`

## ✅ Phase 9 : Tests Finaux (10 min)

- [ ] **9.1** Relancer un trial Optuna
  ```bash
  python -m src.optuna_yolo --n-trials 1
  ```
  Attendu : 1 nouveau run dans MLflow

- [ ] **9.2** Vérifier artifacts S3
  - [ ] Ouvrir MinIO : http://localhost:9001
  - [ ] Bucket `mlflow-artifacts`
  - [ ] Voir les dossiers par run ID

- [ ] **9.3** Nettoyer (optionnel)
  ```bash
  docker compose down
  ```

## ✅ Phase 10 : Soumission (5 min)

- [ ] **10.1** Préparer lien GitLab
  - [ ] Copier URL : https://gitlab.com/VOTRE_USERNAME/optuna-cv-yolo

- [ ] **10.2** Vérifier checklist livrables
  - [ ] ✅ Fork GitLab public
  - [ ] ✅ Code source complet
  - [ ] ✅ `reports/OPTUNA_DECISION.md` complété
  - [ ] ✅ Screenshots dans `images/`
  - [ ] ✅ README.md à jour

- [ ] **10.3** Soumettre
  - [ ] Déposer lien sur plateforme du cours
  - [ ] Mentionner : "TP6 - Optuna YOLO - [Votre Nom]"

---

## 📊 Récapitulatif Temps Estimé

| Phase | Durée | Cumul |
|-------|-------|-------|
| 1. Setup | 15 min | 15 min |
| 2. Vérifications | 10 min | 25 min |
| 3. Baseline | 10 min | 35 min |
| 4. Grid Search | 30 min | 65 min |
| 5. Optuna | 40 min | 105 min |
| 6. Analyse | 20 min | 125 min |
| 7. Rapport | 30 min | 155 min |
| 8. GitLab | 10 min | 165 min |
| 9. Tests | 10 min | 175 min |
| 10. Soumission | 5 min | **180 min** |

**Total : ~3 heures** (dont ~70 min de calcul GPU/CPU en background)

---

## 🆘 En cas de problème

1. **Docker ne démarre pas** → Voir [GUIDE.md#troubleshooting](GUIDE.md#troubleshooting)
2. **MLflow inaccessible** → Vérifier `docker compose ps` et port 5000
3. **Optuna fails** → Vérifier logs console, réduire n-trials
4. **Out of memory** → Réduire batch size ou imgsz

---

**Bon courage ! 🚀**

Cochez chaque item au fur et à mesure. Gardez cette checklist ouverte pendant tout le TP.
