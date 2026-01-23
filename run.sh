set -euxo pipefail
ulimit -s unlimited
source .venv/bin/activate
bash pipeline.sh | tee log/pipeline.$(date -Im).out
sudo shutdown -h now
