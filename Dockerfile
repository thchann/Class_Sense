FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    TF_CPP_MIN_LOG_LEVEL=2 \
    OPENCV_VIDEOIO_PRIORITY_MSMF=0

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    git \
    build-essential \
    pkg-config \
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.docker.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY . /app

# Reasonable defaults; override via env or .env
ENV MARLIN_MODEL_PATH=/app/models/marlin/marlin_vit_base_ytf.encoder.pt \
    CHECKPOINT_PATH=/app/checkpoints/fusion_best.keras \
    MARLIN_DIR=/app/data/marlin_embeddings \
    OPENFACE_DIR=/app/data/openface_output \
    LABELS_CSV=/app/data/final_labels.csv

CMD ["python", "-c", "print('EngageNet container ready. Override CMD to run a script.')"]


