# set -euxo pipefail
source ~/.shell

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BENCHMARK=$1
SIZE=$2

if [ -z "$BENCHMARK" ] || [ -z "$SIZE" ]; then
    echo "Usage: $0 <benchmark> <size> [phase]"
    echo "Benchmarks: horner, matmul, serialsum"
    echo "Size: integer (e.g., 5, 10, 64, 128)"
    exit 1
fi

echo "Generating large benchmark: $BENCHMARK with size: $SIZE"

# Change to the benchmark directory and generate files based on type
cd "benchmarks-new/large/$BENCHMARK"

case "$BENCHMARK" in
    horner)
        python3 generate_horner_fptaylor.py "$SIZE" "Horner${SIZE}.fptaylor"
        python3 generate_horner_fz.py "$SIZE" "Horner${SIZE}.fz"
        python3 generate_horner_g.py "$SIZE" "Horner${SIZE}.g"
        BASE_NAME="large/horner/Horner${SIZE}"
        ;;
    matmul)
        python3 generate_dotprod.py "$SIZE" "dotprod${SIZE}.fz"
        python3 generate_mat_mul.py "$SIZE" "matmul${SIZE}.fz"
        BASE_NAME="large/matmul/matmul${SIZE}"
        ;;
    serialsum)
        python3 generate_serial_sum_fptaylor.py "$SIZE" "serial_sum_${SIZE}.fptaylor"
        python3 generate_serial_sum_fz.py "$SIZE" "serial_sum_${SIZE}.fz"
        python3 generate_serial_sum_g.py "$SIZE" "serial_sum_${SIZE}.g"
        BASE_NAME="large/serialsum/serial_sum_${SIZE}"
        ;;
    *)
        echo "Error: Invalid benchmark '$BENCHMARK'"
        echo "Benchmarks must be: horner, matmul, or serialsum"
        exit 1
        ;;
esac

# Return to project root
cd "$SCRIPT_DIR"

# Run the benchmark pipeline
PHASE=${3:-all}

# If only generation is requested, stop here; otherwise continue to analysis/timing
if [ "$PHASE" = "generate" ]; then
  exit 0
fi

source bench.sh "$BASE_NAME" "$PHASE"
