#!/bin/bash
set -exuo pipefail

[ ! -d ".venv" ] && uv venv .venv
source .venv/bin/activate
uv pip install -e fpcodgen/
uv pip install numpy pandas seaborn tqdm
git submodule update --init --recursive
cd fuzzrs && cargo build --release && cd ..
sudo docker build -f docker/Dockerfile -t negfuzz .

echo "To get started, first run: source .venv/bin/activate"
