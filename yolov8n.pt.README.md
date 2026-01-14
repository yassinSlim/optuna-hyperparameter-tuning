# YOLOv8n Pre-trained Model Placeholder

This file is a placeholder. The actual YOLOv8n model (`yolov8n.pt`) will be downloaded automatically by Ultralytics when you first run training.

## How to get the model

1. **Automatic download (recommended):**
   When you run training for the first time, Ultralytics will automatically download the model:
   ```bash
   python -m src.train_cv --epochs 3 --imgsz 320
   ```

2. **Manual download:**
   ```bash
   wget https://github.com/ultralytics/assets/releases/download/v8.1.0/yolov8n.pt
   ```
   
   Or with curl:
   ```bash
   curl -L https://github.com/ultralytics/assets/releases/download/v8.1.0/yolov8n.pt -o yolov8n.pt
   ```

3. **Using Python:**
   ```python
   from ultralytics import YOLO
   model = YOLO('yolov8n.pt')  # Downloads automatically if not present
   ```

## Model Details

- **Name:** YOLOv8 Nano
- **Size:** ~6 MB
- **Parameters:** ~3.2M
- **Speed:** Fast
- **Accuracy:** Good for lightweight applications

## Alternative Models

You can also use other YOLO models:
- `yolov8s.pt` - Small (11M params)
- `yolov8m.pt` - Medium (25M params)
- `yolov8l.pt` - Large (43M params)
- `yolov8x.pt` - Extra Large (68M params)

Or YOLOv11:
- `yolo11n.pt`, `yolo11s.pt`, etc.
