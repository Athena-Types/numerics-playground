# set -euxo pipefail
source ~/.shell

echo "Running for benchmark: $1"

## do not uncomment the below
# Setup
# racket deps/FPBench/export.rkt --lang g benchmarks-new/$1.fpcore benchmarks-new/$1.g
# racket deps/FPBench/export.rkt --lang fptaylor benchmarks-new/$1.fpcore benchmarks-new/$1.fptaylor
# racket deps/FPBench/export.rkt --lang py benchmarks-new/$1.fpcore benchmarks-new/$1.py
#
# Generate gappa files / questions
# python src/compute_bound.py benchmarks-new/$1.g

# Run Gappa
# gappa benchmarks-new/$1-abs.g &>benchmarks-new/$1-abs.g.out
# gappa benchmarks-new/$1-ideal.g &>benchmarks-new/$1-ideal.g.out
# gappa benchmarks-new/$1-real.g &>benchmarks-new/$1-real.g.out
# gappa benchmarks-new/$1-rel.g &>benchmarks-new/$1-rel.g.out
#
# # Run FPTaylor
# fptaylor --rel-error true --abs-error true benchmarks-new/$1.fptaylor &>benchmarks-new/$1.fptaylor.out

# Run FuzzRS
./fuzzrs/target/release/fuzzrs --input benchmarks-new/$1.fz &>benchmarks-new/$1.fz.out
./fuzzrs/target/release/fuzzrs --input benchmarks-new/$1-factor.fz &>benchmarks-new/$1-factor.fz.out

# RUNS=50
# WARMUP=5
# # Benchmarks
# hyperfine -N --export-json benchmarks-new/$1.fz.json --warmup $WARMUP --runs $RUNS "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$1.fz"
# hyperfine -N --export-json benchmarks-new/$1-factor.fz.json --warmup $WARMUP --runs $RUNS "./fuzzrs/target/release/fuzzrs --input benchmarks-new/$1-factor.fz"
# hyperfine --export-json benchmarks-new/$1-abs.g.json --warmup $WARMUP --runs $RUNS "gappa benchmarks-new/$1-abs.g"
# hyperfine --export-json benchmarks-new/$1-rel.g.json --warmup $WARMUP --runs $RUNS "gappa benchmarks-new/$1-rel.g"
# hyperfine --export-json benchmarks-new/$1-abs.fptaylor.json --warmup $WARMUP --runs $RUNS "fptaylor --rel-error true --abs-error false benchmarks-new/$1.fptaylor"
# hyperfine --export-json benchmarks-new/$1-rel.fptaylor.json --warmup $WARMUP --runs $RUNS "fptaylor --abs-error true --rel-error false benchmarks-new/$1.fptaylor"
