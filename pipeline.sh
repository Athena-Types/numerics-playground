set -euxo pipefail
# PATH=$PATH:/home/user/git/gappa/src:/home/user/git/FPTaylor:/home/user/.opam/cs6115/bin:/home/user/.pyenv/plugins/pyenv-virtualenv/shims:/home/user/.pyenv/shims:/home/user/.pyenv/bin:/home/user/.nvm/versions/node/v23.2.0/bin:/home/user/.pyenv/plugins/pyenv-virtualenv/shims:/home/user/.pyenv/bin:/home/user/.atuin/bin:/home/user/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/user/.cabal/bin:/home/user/.ghcup/bin:/usr/local/go/bin:/home/user/.config/emacs/bin:/home/user/git/diff-so-fancy:/opt/nvim-linux64/bin:/usr/local/go/bin:/home/user/.config/emacs/bin:/home/user/git/diff-so-fancy:/opt/nvim-linux64/bin

# Configuration: phase to run (generate, analyze, time, or all)
# - generate: only generate benchmark files
# - analyze: only run analysis tools (Gappa, FPTaylor, FuzzRS)
# - time: only run hyperfine benchmarks
# - all: run all phases (generate + analyze + time)
BENCH_PHASE=${BENCH_PHASE:-all} # default to "all" if not set

# build everything
cd fuzzrs
cargo build --release
cd ..

BASH=$(which bash)
PARALLEL_JOBS=1

# TODO: Note that we exclude the shoelace formula from the small benchmarks for now.
parallel -j $PARALLEL_JOBS $BASH bench_small.sh {1} {2} {3} $BENCH_PHASE ::: $(cat small.txt) ::: binary32 binary64 ::: nearestEven toZero toPositive toNegative
parallel -j $PARALLEL_JOBS $BASH bench.sh {1} $BENCH_PHASE ::: $(cat large.txt)
