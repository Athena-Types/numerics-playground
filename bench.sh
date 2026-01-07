# set -euxo pipefail
source ~/.shell

BENCHMARK=$1
PHASE=${2:-all} # default to "all"

RUNS=50
WARMUP=5

# Validate phase argument (generation happens upstream)
if [ "$PHASE" != "analyze" ] && [ "$PHASE" != "time" ] && [ "$PHASE" != "all" ]; then
  echo "Error: Invalid phase '$PHASE'"
  echo "Phase must be: analyze, time, or all"
  exit 1
fi

echo "Running for benchmark: $BENCHMARK (phase: $PHASE)"

# Note: Generation is performed prior to calling this script (small via bench_small.sh, large via Python generators)

# Analyze phase
if [ "$PHASE" = "analyze" ] || [ "$PHASE" = "all" ]; then
  # Run Gappa
  gappa benchmarks-new/$BENCHMARK-abs.g &>benchmarks-new/$BENCHMARK-abs.g.out
  gappa benchmarks-new/$BENCHMARK-ideal.g &>benchmarks-new/$BENCHMARK-ideal.g.out
  gappa benchmarks-new/$BENCHMARK-real.g &>benchmarks-new/$BENCHMARK-real.g.out
  gappa benchmarks-new/$BENCHMARK-rel.g &>benchmarks-new/$BENCHMARK-rel.g.out

  # Run FPTaylor
  fptaylor --rel-error true --abs-error true benchmarks-new/$BENCHMARK.fptaylor &>benchmarks-new/$BENCHMARK.fptaylor.out

  # Run FuzzRS
  ./fuzzrs/target/release/fuzzrs --input benchmarks-new/$BENCHMARK.fz &>benchmarks-new/$BENCHMARK.fz.out
  ./fuzzrs/target/release/fuzzrs --input benchmarks-new/$BENCHMARK-factor.fz &>benchmarks-new/$BENCHMARK-factor.fz.out
fi

# Time phase (hyperfine benchmarks)
if [ "$PHASE" = "time" ] || [ "$PHASE" = "all" ]; then
  # Benchmarks
  hyperfine -N --export-json benchmarks-new/$BENCHMARK.fz.json --warmup $WARMUP --runs $RUNS "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$BENCHMARK.fz"
  hyperfine -N --export-json benchmarks-new/$BENCHMARK-factor.fz.json --warmup $WARMUP --runs $RUNS "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$BENCHMARK-factor.fz"
  hyperfine --export-json benchmarks-new/$BENCHMARK-abs.g.json --warmup $WARMUP --runs $RUNS "gappa benchmarks-new/$BENCHMARK-abs.g"
  hyperfine --export-json benchmarks-new/$BENCHMARK-rel.g.json --warmup $WARMUP --runs $RUNS "gappa benchmarks-new/$BENCHMARK-rel.g"
  hyperfine --export-json benchmarks-new/$BENCHMARK-abs.fptaylor.json --warmup $WARMUP --runs $RUNS "fptaylor --rel-error true --abs-error false benchmarks-new/$BENCHMARK.fptaylor"
  hyperfine --export-json benchmarks-new/$BENCHMARK-rel.fptaylor.json --warmup $WARMUP --runs $RUNS "fptaylor --abs-error true --rel-error false benchmarks-new/$BENCHMARK.fptaylor"
fi
