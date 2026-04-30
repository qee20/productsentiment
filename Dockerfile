#FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime
#FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime
#FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

# 1. Use the Blackwell-ready base
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

# 2. Setup environment and install Python 3.11
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y --no-install-recommends \
    software-properties-common wget curl git build-essential \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt update \
    && apt install -y python3.11 python3.11-venv python3.11-dev \
    && apt clean && rm -rf /var/lib/apt/lists/*

# 3. Set Python 3.11 as default and install Pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm get-pip.py

# 4. Install PyTorch Nightly with CUDA 12.8 support (Critical for RTX 5050)
RUN pip install --no-cache-dir --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu128/

# 5. Install your Project dependencies
WORKDIR /workspace
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir notebook transformers

# 6. Pre-download your BERT model (To avoid slow runtime downloads)
RUN python3 -c "from transformers import AutoTokenizer, AutoModelForSequenceClassification; \
    model_name = 'mdhugol/indonesia-bert-sentiment-classification'; \
    AutoTokenizer.from_pretrained(model_name); \
    AutoModelForSequenceClassification.from_pretrained(model_name)"

# 7. Final setup
COPY . .
EXPOSE 8888

# Use the Jupyter command you're familiar with
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
