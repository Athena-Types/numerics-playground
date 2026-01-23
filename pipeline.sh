set -uxo pipefail

# Configuration: phase to run (generate, analyze, time, or all)
# - generate: only generate benchmark files
# - analyze: only run analysis tools (Gappa, FPTaylor, FuzzRS)
# - time: only run hyperfine benchmarks
# - all: run all phases (generate + analyze + time)
BENCH_PHASE=${BENCH_PHASE:-all}
TIMEOUT=${TIMEOUT:-1800}
MEMORY_LIMIT=${MEMORY_LIMIT:-64}
CPU_LIMIT=${CPU_LIMIT:-1}
PARALLEL_JOBS=24

export TIMEOUT MEMORY_LIMIT CPU_LIMIT

# build everything
cd fuzzrs
#: cargo build --release
cd ..

BASH=$(which bash)

# TODO: Note that we exclude the shoelace formula from the small benchmarks for now.
parallel -j $PARALLEL_JOBS $BASH bench_small.sh {1} {2} {3} $BENCH_PHASE $TIMEOUT $MEMORY_LIMIT $CPU_LIMIT ::: $(cat small.txt) ::: binary32 binary64 ::: nearestEven toZero toPositive toNegative

# Large benchmarks (note that each benchmark is generated a little differently)
parallel -j $PARALLEL_JOBS $BASH bench_large.sh {1} {2} $BENCH_PHASE $TIMEOUT $MEMORY_LIMIT $CPU_LIMIT ::: horner serialsum poly ::: 4 8 16 32 64 128 256 512 1024 2048

parallel -j $PARALLEL_JOBS $BASH bench_large.sh {1} {2} $BENCH_PHASE $TIMEOUT $MEMORY_LIMIT $CPU_LIMIT ::: matmul ::: 4 8 16 32 64 128 256 512

