#!/bin/bash
set -exuo pipefail

[ ! -d ".venv" ] && uv venv .venv
source .venv/bin/activate
uv pip install -e fpcodgen/
git submodule update --init --recursive
cd fuzzrs && cargo build --release && cd ..

echo "To get started, first run: source .venv/bin/activate"
