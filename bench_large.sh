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
        python3 generate_horner_fz.py "$SIZE" "Horner${SIZE}-factor.fz"
        python3 generate_horner_g.py "$SIZE" "Horner${SIZE}.g"
        python3 generate_horner_satire.py "$SIZE" "Horner${SIZE}.txt"
        BASE_NAME="large/horner/Horner${SIZE}"
        ;;
    matmul)
        python3 generate_dotprod.py "$SIZE" "dotprod${SIZE}.fz"
        python3 generate_mat_mul.py "$SIZE" "matmul${SIZE}-factor.fz"
        python3 generate_matmul_fptaylor.py "$SIZE" "matmul${SIZE}.fptaylor"
        python3 generate_matmul_g.py "$SIZE" "matmul${SIZE}.g"
        python3 generate_mat_mul_satire.py "$SIZE" "matmul${SIZE}.txt"
        BASE_NAME="large/matmul/matmul${SIZE}"
        ;;
    serialsum)
        python3 generate_serial_sum_fptaylor.py "$SIZE" "serial_sum_${SIZE}.fptaylor"
        python3 generate_serial_sum_fz.py "$SIZE" "serial_sum_${SIZE}-factor.fz"
        python3 generate_serial_sum_g.py "$SIZE" "serial_sum_${SIZE}.g"
        python3 generate_serial_sum_satire.py "$SIZE" "serial_sum_${SIZE}.txt"
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

# Generate all Gappa questions
python src/compute_bound.py "benchmarks-new/${BASE_NAME}.g"

# Run the benchmark pipeline
PHASE=${3:-all}

# If only generation is requested, stop here; otherwise continue to analysis/timing
if [ "$PHASE" = "generate" ]; then
  exit 0
fi

echo "Running non-Satire (fptaylor, gappa, NegFuzz) tools"
source bench.sh "$BASE_NAME" "$PHASE"

echo "Now running Satire tools"

# Satire input file path
SATIRE_FILE="benchmarks-new/$BASE_NAME.txt"

# No abstraction - with dynamic LD_LIBRARY_PATH
docker run --rm \
  -v "$SCRIPT_DIR:/numerics-playground" \
  -w /numerics-playground \
  negfuzz \
  bash -c 'RUST_SYSROOT=$(rustc --print sysroot); \
    export LD_LIBRARY_PATH=/usr/local/lib:/numerics-playground/deps/gelpia/target/release/deps:$RUST_SYSROOT/lib/rustlib/x86_64-unknown-linux-gnu/lib; \
    python3 deps/Satire/src/satire.py --std --file '"$SATIRE_FILE"' \
    --logfile benchmarks-new/'"$BASE_NAME"'_sat_abs-serial_noAbs.pylog \
    --outfile benchmarks-new/'"$BASE_NAME"'_sat_abs-serial_noAbs.out'

# Abstraction windows: (10,20), (15,25), (20,40)
for mindepth maxdepth in "10 20" "15 25" "20 40"; do
  docker run --rm \
    -v "$SCRIPT_DIR:/numerics-playground" \
    -w /numerics-playground \
    negfuzz \
    bash -c 'RUST_SYSROOT=$(rustc --print sysroot); \
      export LD_LIBRARY_PATH=/usr/local/lib:/numerics-playground/deps/gelpia/target/release/deps:$RUST_SYSROOT/lib/rustlib/x86_64-unknown-linux-gnu/lib; \
      python3 deps/Satire/src/satire.py --std --file '"$SATIRE_FILE"' \
      --enable-abstraction --mindepth '"$mindepth"' --maxdepth '"$maxdepth"' \
      --logfile benchmarks-new/'"$BASE_NAME"'_sat_abs-serial_'"${mindepth}"'_'"${maxdepth}"'.pylog \
      --outfile benchmarks-new/'"$BASE_NAME"'_sat_abs-serial_'"${mindepth}"'_'"${maxdepth}"'.out'
done
