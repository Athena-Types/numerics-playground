set -euxo pipefail

SEED=$RANDOM
BENCHMARK=$(realpath $1)

./src/_build/default/bin/abstest.exe $BENCHMARK $SEED
