# set -euxo pipefail

BENCHMARK=$1
PRECISION=$2
ROUNDING_MODE=$3
PHASE=${4:-all}
TIMEOUT=${5:-3600}
MEMORY_LIMIT=${6:-10g}
CPU_LIMIT=${7:-1}

if [ -z "$BENCHMARK" ] || [ -z "$PRECISION" ] || [ -z "$ROUNDING_MODE" ]; then
    echo "Usage: $0 <benchmark> <precision> <rounding_mode> [phase] [timeout] [memory_limit] [cpu_limit]"
    echo "Precisions: binary32, binary64"
    echo "Rounding modes: nearestEven, toZero, toPositive, toNegative"
    exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/timeout.sh"

if [ "$PRECISION" != "binary32" ] && [ "$PRECISION" != "binary64" ]; then
    echo "Error: Invalid precision '$PRECISION'"
    echo "Precisions must be: binary32 or binary64"
    exit 1
fi

echo "Running for benchmark: $BENCHMARK with precision: $PRECISION and rounding mode: $ROUNDING_MODE"

# Generate FPCore from template
BASE_NAME="${BENCHMARK}-${PRECISION}-${ROUNDING_MODE}"
FPCORE_FILE="benchmarks-new/${BASE_NAME}.fpcore"
export PRECISION
export ROUNDING_MODE
envsubst < "benchmarks-new/${BENCHMARK}.fpcore.template" > "$FPCORE_FILE"
echo "Generated ${FPCORE_FILE}"

# Export generated artifacts from FPCore
# - Generate .g and .fptaylor using FPBench
run_with_timeout racket deps/FPBench/export.rkt --lang g "$FPCORE_FILE" "benchmarks-new/${BASE_NAME}.g"
run_with_timeout racket deps/FPBench/export.rkt --lang fptaylor "$FPCORE_FILE" "benchmarks-new/${BASE_NAME}.fptaylor"

# Generate gappa question files from the .g file
run_with_timeout python src/compute_bound.py "benchmarks-new/${BASE_NAME}.g"

# Run the benchmark pipeline

# If only generation is requested, stop here; otherwise continue to analysis/timing
if [ "$PHASE" = "generate" ]; then
  exit 0
fi

# .fz files use the base benchmark name (without precision/rounding)
export FZ_BENCHMARK="$BENCHMARK"
source bench.sh "$BASE_NAME" "$PHASE" "$TIMEOUT" "$MEMORY_LIMIT" "$CPU_LIMIT"
