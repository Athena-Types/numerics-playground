
### Lowering, i.e. FPCore (unpaired) -> FPCore (paired)
src/_build/default/bin/paired.exe: src/bin/paired.ml
	cd src && opam exec -- dune build

./fuzzrs/target/release/fuzzrs: # ./fuzzrs/src/%.rs
	cd fuzzrs && cargo build --release

# benchmarks-new/%-paired.fpcore: src/_build/default/bin/paired.exe
# 	racket deps/FPBench/transform.rkt --precondition-ranges benchmarks-new/$*.fpcore benchmarks-new/$*.simple.fpcore
# 	./src/_build/default/bin/paired.exe benchmarks-new/$*.simple.fpcore > benchmarks-new/$*-paired.fpcore
#
### FPCore -> Gappa
benchmarks-new/%.g: fpcore benchmarks-new/%.fpcore
	racket deps/FPBench/export.rkt --lang g benchmarks-new/$*.fpcore benchmarks-new/$*.g 
	python src/compute_bound.py benchmarks-new/$*.g 

benchmarks-new/%-relative.g: fpcore benchmarks-new/%.fpcore
	racket deps/FPBench/export.rkt --rel-error --lang g benchmarks-new/$*.fpcore benchmarks-new/$*-relative.g 
	python src/compute_bound.py benchmarks-new/$*-relative.g 

### Running Gappa
benchmarks-new/%.g.out: benchmarks-new/%.g
	gappa benchmarks-new/$*.g &> benchmarks-new/$*.g.out

### Running NumFuzz
./deps/NumFuzz/_build/install/default/bin/nfuzz: 
	cd deps/NumFuzz && opam exec -- dune build
 
benchmarks-new/%.fz: benchmarks-new/%.g.out # ./deps/NumFuzz/_build/install/default/bin/nfuzz
	cd fuzzrs && cargo build --release && ./target/release/fuzzrs --input ../benchmarks-new/$*.fz &> ../benchmarks-new/$*.fz.out
	cd fuzzrs && cargo build --release && ./target/release/fuzzrs --input ../benchmarks-new/$*-factor.fz &> ../benchmarks-new/$*-factor.fz.out
	# cp benchmarks-new/$*.fz deps/NumFuzz/examples/NumFuzz/
	# cd deps/NumFuzz && ./_build/install/default/bin/nfuzz examples/NumFuzz/$*.fz &> ../../benchmarks-new/$*.fz.out


### Defining phony stages
# UNPAIRED_FPCORE_FILES = $(filter-out $(wildcard benchmarks-new/*-paired.fpcore), $(wildcard benchmarks-new/*.fpcore))
FPCORE_FILES=$(wildcard benchmarks-new/*.fpcore)

# PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(UNPAIRED_FPCORE_FILES))

################################################################################
### Abstract Testing
benchmarks-new/%.scala: fpcore benchmarks-new/%.fpcore
	racket deps/FPBench/export.rkt --lang scala benchmarks-new/$*.fpcore benchmarks-new/$*.scala

SCALA =$(patsubst benchmarks-new/%.fpcore, benchmarks-new/%.scala, $(UNPAIRED_FPCORE_FILES))

scala: $(SCALA)

################################################################################

## NumFuzz (extended) analysis

# Stage 1: Generate FPCore
BENCHMARK_NAMES_STAGE_1 =$(patsubst benchmarks-new/%.fpcore, %-fpcore, $(UNPAIRED_FPCORE_FILES))

# $(BENCHMARK_NAMES_STAGE_1): %-fpcore: benchmarks-new/%-paired.fpcore 
$(BENCHMARK_NAMES_STAGE_1): %-fpcore: benchmarks-new/%.fpcore 

fpcore: $(BENCHMARK_NAMES_STAGE_1)

# Stage 2: Generate Gappa
BENCHMARK_NAMES_STAGE_2 =$(patsubst benchmarks-new/%.fpcore, %-gappa, $(UNPAIRED_FPCORE_FILES))

$(BENCHMARK_NAMES_STAGE_2): %-gappa: benchmarks-new/%.g benchmarks-new/%-relative.g 

gappa: $(BENCHMARK_NAMES_STAGE_2)

# Stage 3: Run Gappa
BENCHMARK_NAMES_STAGE_3 = $(patsubst %, %.out, $(wildcard benchmarks-new/*.g))
gappa-run: $(BENCHMARK_NAMES_STAGE_3)

# Stage 4: Run NumFuzz
BENCHMARK_NAMES_STAGE_4 = $(wildcard benchmarks-new/*.fz) 

################################################################################
## Paper stuff

paper/main.pdf: paper/citations.bib paper/main.tex $(wildcard paper/sections/*.tex) 
	cd paper && latexmk -pdf -halt-on-error main.tex

################################################################################
## Meta stuff

all: .WAIT gappa gappa-run numfuzz

build:
	cd src && opam exec -- dune build

clean:
	rm -f benchmarks-new/*-paired.fpcore
	rm -f benchmarks-new/*.simple.fpcore
	rm -f benchmarks-new/*.g
	rm -f benchmarks-new/*.out
	cd src && opam exec dune clean

numfuzz: $(BENCHMARK_NAMES_STAGE_4)

paper: paper/main.pdf

abstest: scala

.PHONY: scala abstest build fpcore gappa gappa-run all clean $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2)
.NOTINTERMEDIATE: $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2) benchmarks-new/%.g benchmarks-new/%.out
