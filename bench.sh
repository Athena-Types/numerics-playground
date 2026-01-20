# set -euxo pipefail

BENCHMARK=$1
PHASE=${2:-all}
TIMEOUT=${3:-3600}
MEMORY_LIMIT=${4:-10g}
CPU_LIMIT=${5:-1}

if [ -z "$BENCHMARK" ]; then
    echo "Error: BENCHMARK argument is required"
    echo "Usage: $0 <benchmark> [phase] [timeout] [memory_limit] [cpu_limit]"
    exit 1
fi

RUNS=5
WARMUP=1

# FZ_BENCHMARK should be set by the caller (bench_small.sh or bench_large.sh)
# Fall back to BENCHMARK if not set
FZ_BENCHMARK="${FZ_BENCHMARK:-$BENCHMARK}"

export TIMEOUT MEMORY_LIMIT CPU_LIMIT
source "$(dirname "${BASH_SOURCE[0]}")/docker/run.sh"

# Validate phase argument (generation happens upstream)
if [ "$PHASE" != "analyze" ] && [ "$PHASE" != "time" ] && [ "$PHASE" != "all" ]; then
  echo "Error: Invalid phase '$PHASE'"
  echo "Phase must be: analyze, time, or all"
  exit 1
fi

echo "Running for benchmark: $BENCHMARK (phase: $PHASE, memory: $MEMORY_LIMIT, cpus: $CPU_LIMIT)"

# Note: Generation is performed prior to calling this script (small via bench_small.sh, large via bench_large.sh)

# Analyze phase
if [ "$PHASE" = "analyze" ] || [ "$PHASE" = "all" ]; then
  # Run Gappa
  run_in_docker "gappa benchmarks-new/$BENCHMARK-abs.g" &>benchmarks-new/$BENCHMARK-abs.g.out
  run_in_docker "gappa benchmarks-new/$BENCHMARK-ideal.g" &>benchmarks-new/$BENCHMARK-ideal.g.out
  run_in_docker "gappa benchmarks-new/$BENCHMARK-real.g" &>benchmarks-new/$BENCHMARK-real.g.out
  run_in_docker "gappa benchmarks-new/$BENCHMARK-rel.g" &>benchmarks-new/$BENCHMARK-rel.g.out

  # Run FPTaylor
  run_in_docker "fptaylor --rel-error true --abs-error true benchmarks-new/$BENCHMARK.fptaylor" &>benchmarks-new/$BENCHMARK.fptaylor.out

  # Run NegFuzz (uses base benchmark name without precision/rounding)
  if [ -f "benchmarks-new/$FZ_BENCHMARK.fz" ]; then
    run_in_docker "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$FZ_BENCHMARK.fz" &>benchmarks-new/$FZ_BENCHMARK.fz.out
  fi
  if [ -f "benchmarks-new/$FZ_BENCHMARK-factor.fz" ]; then
    run_in_docker "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$FZ_BENCHMARK-factor.fz" &>benchmarks-new/$FZ_BENCHMARK-factor.fz.out
  fi
fi

# Time phase (hyperfine benchmarks)
if [ "$PHASE" = "time" ] || [ "$PHASE" = "all" ]; then
  # Benchmarks (uses base benchmark name without precision/rounding for .fz files)
  if [ -f "benchmarks-new/$FZ_BENCHMARK.fz" ]; then
    run_in_docker "hyperfine -N --export-json benchmarks-new/$FZ_BENCHMARK.fz.json --warmup $WARMUP --runs $RUNS './fuzzrs/target/release/fuzzrs --input benchmarks-new/$FZ_BENCHMARK.fz'"
  fi
  if [ -f "benchmarks-new/$FZ_BENCHMARK-factor.fz" ]; then
    run_in_docker "hyperfine -N --export-json benchmarks-new/$FZ_BENCHMARK-factor.fz.json --warmup $WARMUP --runs $RUNS './fuzzrs/target/release/fuzzrs --input benchmarks-new/$FZ_BENCHMARK-factor.fz'"
  fi
  run_in_docker "hyperfine --export-json benchmarks-new/$BENCHMARK-abs.g.json --warmup $WARMUP --runs $RUNS 'gappa benchmarks-new/$BENCHMARK-abs.g'"
  run_in_docker "hyperfine --export-json benchmarks-new/$BENCHMARK-rel.g.json --warmup $WARMUP --runs $RUNS 'gappa benchmarks-new/$BENCHMARK-rel.g'"
  run_in_docker "hyperfine --export-json benchmarks-new/$BENCHMARK-abs.fptaylor.json --warmup $WARMUP --runs $RUNS 'fptaylor --rel-error true --abs-error false benchmarks-new/$BENCHMARK.fptaylor'"
  run_in_docker "hyperfine --export-json benchmarks-new/$BENCHMARK-rel.fptaylor.json --warmup $WARMUP --runs $RUNS 'fptaylor --abs-error true --rel-error false benchmarks-new/$BENCHMARK.fptaylor'"
fi
