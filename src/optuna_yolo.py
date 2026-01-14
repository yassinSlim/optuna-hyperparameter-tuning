# src/optuna_yolo.py
"""
Optuna hyperparameter optimization for YOLO with MLflow logging.
"""
import os
import argparse
from pathlib import Path
import optuna
import mlflow
from ultralytics import YOLO
import pandas as pd

# Import utilities
try:
    from .utils import set_global_seed
except ImportError:
    import importlib.util
    utils_path = Path(__file__).resolve().parent / "utils.py"
    spec = importlib.util.spec_from_file_location("utils_local", utils_path)
    mod = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(mod)  # type: ignore
    set_global_seed = getattr(mod, "set_global_seed")

# Configure MLflow
mlflow.set_tracking_uri(os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000"))


def latest_run_dir(base="runs/detect"):
    """Get the latest YOLO run directory."""
    paths = sorted(Path(base).glob("*"), key=lambda p: p.stat().st_mtime)
    return paths[-1] if paths else None


def get_yolo_metrics(run_dir: Path):
    """Extract final metrics from YOLO results.csv."""
    csv_path = run_dir / "results.csv"
    if not csv_path.exists():
        return {}
    
    df = pd.read_csv(csv_path)
    last = df.iloc[-1].to_dict()
    
    # Compat multi-versions Ultralytics
    metrics = {}
    candidates = {
        "precision":   ["metrics/precision(B)", "metrics/precision"],
        "recall":      ["metrics/recall(B)", "metrics/recall"],
        "mAP50":       ["metrics/mAP50(B)", "metrics/mAP50"],
        "mAP50-95":    ["metrics/mAP50-95(B)", "metrics/mAP50-95", "metrics/mAP50-95(M)"],
    }
    
    for metric_name, col_candidates in candidates.items():
        for col in col_candidates:
            if col in last:
                try:
                    metrics[metric_name] = float(last[col])
                    break
                except Exception:
                    pass
    
    return metrics


def log_yolo_artifacts(run_dir: Path):
    """Log YOLO artifacts to MLflow."""
    for f in ["results.png", "confusion_matrix.png", "PR_curve.png", "labels_correlogram.jpg"]:
        p = run_dir / f
        if p.exists():
            mlflow.log_artifact(str(p), artifact_path="yolo_plots")
    
    best = run_dir / "weights" / "best.pt"
    if best.exists():
        mlflow.log_artifact(str(best), artifact_path="weights")


def objective(trial: optuna.Trial, args):
    """Optuna objective function for YOLO hyperparameter optimization."""
    
    # Suggest hyperparameters
    epochs = trial.suggest_int("epochs", args.min_epochs, args.max_epochs)
    imgsz = trial.suggest_categorical("imgsz", args.imgsz_choices)
    lr0 = trial.suggest_float("lr0", args.min_lr, args.max_lr, log=True)
    
    # Fixed seed for reproducibility within trial
    seed = args.seed
    set_global_seed(seed)
    
    # Create run name
    run_name = f"optuna_yolo_trial_{trial.number}_e{epochs}_sz{imgsz}_lr{lr0:.4f}"
    
    # Start MLflow run
    mlflow.set_experiment(args.exp_name)
    with mlflow.start_run(run_name=run_name):
        # Log parameters
        mlflow.log_params({
            "model": args.model,
            "epochs": epochs,
            "imgsz": imgsz,
            "lr0": lr0,
            "batch": args.batch,
            "seed": seed,
            "data": args.data,
            "optuna_trial": trial.number,
        })
        mlflow.set_tags({
            "task": "object-detection",
            "dataset": "tiny_coco_person",
            "optimizer": "optuna",
            "study_name": args.study_name,
        })
        
        # Train YOLO model
        print(f"\n{'='*60}")
        print(f"Trial {trial.number}: epochs={epochs}, imgsz={imgsz}, lr0={lr0:.4f}")
        print(f"{'='*60}\n")
        
        model = YOLO(args.model)
        model.train(
            data=args.data,
            epochs=epochs,
            imgsz=imgsz,
            lr0=lr0,
            batch=args.batch,
            seed=seed,
            project="runs",
            name=run_name,
            verbose=False
        )
        
        # Get run directory
        run_dir = Path("runs/detect") / run_name
        if not run_dir.exists():
            run_dir = latest_run_dir()
        
        # Extract and log metrics
        metrics = {}
        if run_dir:
            metrics = get_yolo_metrics(run_dir)
            
            # Log metrics to MLflow
            for metric_name, value in metrics.items():
                mlflow.log_metric(metric_name, value)
            
            # Log artifacts
            log_yolo_artifacts(run_dir)
            mlflow.log_param("yolo_run_dir", str(run_dir))
        
        # Return objective value (maximize mAP50)
        objective_value = metrics.get("mAP50", 0.0)
        
        print(f"\nTrial {trial.number} completed: mAP50={objective_value:.4f}")
        print(f"Metrics: {metrics}\n")
        
        return objective_value


def main():
    parser = argparse.ArgumentParser(description="Optuna HPO for YOLO")
    parser.add_argument("--data", default="data/tiny_coco.yaml", help="Dataset YAML path")
    parser.add_argument("--model", default="yolov8n.pt", help="YOLO model")
    parser.add_argument("--n-trials", type=int, default=5, help="Number of Optuna trials")
    parser.add_argument("--study-name", default="yolo_optuna_study", help="Optuna study name")
    parser.add_argument("--exp-name", default="cv_yolo_tiny_optuna", help="MLflow experiment name")
    parser.add_argument("--batch", type=int, default=8, help="Batch size")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    
    # Hyperparameter search space
    parser.add_argument("--min-epochs", type=int, default=3, help="Minimum epochs")
    parser.add_argument("--max-epochs", type=int, default=5, help="Maximum epochs")
    parser.add_argument("--imgsz-choices", nargs="+", type=int, default=[320, 416], 
                        help="Image size choices")
    parser.add_argument("--min-lr", type=float, default=0.001, help="Minimum learning rate")
    parser.add_argument("--max-lr", type=float, default=0.01, help="Maximum learning rate")
    
    args = parser.parse_args()
    
    print(f"\n{'='*60}")
    print(f"Starting Optuna Study: {args.study_name}")
    print(f"Number of trials: {args.n_trials}")
    print(f"MLflow experiment: {args.exp_name}")
    print(f"Search space:")
    print(f"  - epochs: [{args.min_epochs}, {args.max_epochs}]")
    print(f"  - imgsz: {args.imgsz_choices}")
    print(f"  - lr0: [{args.min_lr}, {args.max_lr}] (log scale)")
    print(f"{'='*60}\n")
    
    # Create Optuna study (maximize mAP50)
    study = optuna.create_study(
        study_name=args.study_name,
        direction="maximize",
        sampler=optuna.samplers.TPESampler(seed=args.seed),
    )
    
    # Run optimization
    study.optimize(
        lambda trial: objective(trial, args),
        n_trials=args.n_trials,
        show_progress_bar=True,
    )
    
    # Print results
    print(f"\n{'='*60}")
    print(f"Optuna Study Completed!")
    print(f"{'='*60}")
    print(f"Best trial: {study.best_trial.number}")
    print(f"Best value (mAP50): {study.best_value:.4f}")
    print(f"Best hyperparameters:")
    for key, value in study.best_params.items():
        print(f"  - {key}: {value}")
    print(f"{'='*60}\n")
    
    # Save study results
    results_df = study.trials_dataframe()
    results_path = Path("reports") / f"{args.study_name}_results.csv"
    results_path.parent.mkdir(parents=True, exist_ok=True)
    results_df.to_csv(results_path, index=False)
    print(f"Study results saved to: {results_path}")


if __name__ == "__main__":
    main()
