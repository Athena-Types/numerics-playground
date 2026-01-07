# set -euxo pipefail
source ~/.shell

BENCHMARK=$1
ROUNDING_MODE=$2

if [ -z "$BENCHMARK" ] || [ -z "$ROUNDING_MODE" ]; then
    echo "Usage: $0 <benchmark> <rounding_mode>"
    echo "Rounding modes: nearestEven, toZero, toPositive, toNegative"
    exit 1
fi

echo "Running for benchmark: $BENCHMARK with rounding mode: $ROUNDING_MODE"

# Generate FPCore from template
FPCORE_FILE="benchmarks-new/${BENCHMARK}-${ROUNDING_MODE}.fpcore"
export ROUNDING_MODE
envsubst < "benchmarks-new/${BENCHMARK}.fpcore.template" > "$FPCORE_FILE"
echo "Generated ${FPCORE_FILE}"
BASE_NAME="${BENCHMARK}-${ROUNDING_MODE}"

# Source common functionality
source bench.sh
