set -euxo pipefail
# PATH=$PATH:/home/user/git/gappa/src:/home/user/git/FPTaylor:/home/user/.opam/cs6115/bin:/home/user/.pyenv/plugins/pyenv-virtualenv/shims:/home/user/.pyenv/shims:/home/user/.pyenv/bin:/home/user/.nvm/versions/node/v23.2.0/bin:/home/user/.pyenv/plugins/pyenv-virtualenv/shims:/home/user/.pyenv/bin:/home/user/.atuin/bin:/home/user/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/user/.cabal/bin:/home/user/.ghcup/bin:/usr/local/go/bin:/home/user/.config/emacs/bin:/home/user/git/diff-so-fancy:/opt/nvim-linux64/bin:/usr/local/go/bin:/home/user/.config/emacs/bin:/home/user/git/diff-so-fancy:/opt/nvim-linux64/bin

# Configuration: phase to run (generate, analyze, time, or all)
# - generate: only generate benchmark files
# - analyze: only run analysis tools (Gappa, FPTaylor, FuzzRS)
# - time: only run hyperfine benchmarks
# - all: run all phases (generate + analyze + time)
BENCH_PHASE=${BENCH_PHASE:-generate} # default to "all" if not set
TIMEOUT=${TIMEOUT:-3600} # default to 3600 seconds if not set

# build everything
cd fuzzrs
#: cargo build --release
cd ..

BASH=$(which bash)
PARALLEL_JOBS=1

# TODO: Note that we exclude the shoelace formula from the small benchmarks for now.
parallel -j $PARALLEL_JOBS $BASH bench_small.sh {1} {2} {3} $BENCH_PHASE $TIMEOUT ::: $(cat small.txt) ::: binary32 binary64 ::: nearestEven toZero toPositive toNegative

# Large benchmarks (note that each benchmark is generated a little differently)
parallel -j $PARALLEL_JOBS $BASH bench_large.sh {1} {2} $BENCH_PHASE $TIMEOUT ::: horner matmul serialsum poly ::: 4 8 16 32 64 128 256 512 1024 2048
