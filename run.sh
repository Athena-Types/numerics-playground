source .venv/bin/activate
bash pipeline.sh | tee log/pipeline.$(date -Im).out
