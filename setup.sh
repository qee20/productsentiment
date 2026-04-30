#!/bin/bash

# create venv
python -m venv venv

# activate it
source venv/bin/activate

# upgrade pip (recommended)
pip install --upgrade pip

# install dependencies
pip install -r requirements.txt --index-url https://download.pytorch.org/whl/cu128

# setup jupyter kernel
pip install ipykernel
python -m ipykernel install --user --name myenv

echo "Setup complete. Activate with: source venv/bin/activate"