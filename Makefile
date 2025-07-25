
### Lowering, i.e. FPCore (unpaired) -> FPCore (paired)
src/_build/default/bin/paired.exe: src/bin/paired.ml
	cd src && opam exec -- dune build

benchmarks/%-paired.fpcore: src/_build/default/bin/paired.exe
	racket deps/FPBench/transform.rkt --precondition-ranges benchmarks/$*.fpcore benchmarks/$*.simple.fpcore
	./src/_build/default/bin/paired.exe benchmarks/$*.simple.fpcore > benchmarks/$*-paired.fpcore

### FPCore -> Gappa
benchmarks/%.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --lang g benchmarks/$*.fpcore benchmarks/$*.g 
	python src/compute_bound.py benchmarks/$*.g 

benchmarks/%-relative.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --rel-error --lang g benchmarks/$*.fpcore benchmarks/$*-relative.g 
	python src/benchmark.py benchmarks/$*-relative.g 

### Running Gappa
benchmarks/%.g.out: benchmarks/%.g
	gappa benchmarks/$*.g &> benchmarks/$*.g.out

### Running NumFuzz
./deps/NumFuzz/_build/install/default/bin/nfuzz: 
	cd deps/NumFuzz && opam exec -- dune build
 
benchmarks/%.fz: benchmarks/%.g.out ./deps/NumFuzz/_build/install/default/bin/nfuzz
	cp benchmarks/$*.fz deps/NumFuzz/examples/NumFuzz/
	cd deps/NumFuzz && ./_build/install/default/bin/nfuzz examples/NumFuzz/$*.fz &> ../../benchmarks/$*.fz.out


### Defining phony stages
UNPAIRED_FPCORE_FILES = $(filter-out $(wildcard benchmarks/*-paired.fpcore), $(wildcard benchmarks/*.fpcore))
FPCORE_FILES=$(wildcard benchmarks/*.fpcore)

PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(UNPAIRED_FPCORE_FILES))

################################################################################
### Abstract Testing
benchmarks/%.scala: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --lang scala benchmarks/$*.fpcore benchmarks/$*.scala

SCALA =$(patsubst benchmarks/%.fpcore, benchmarks/%.scala, $(UNPAIRED_FPCORE_FILES))

scala: $(SCALA)

################################################################################

## NumFuzz (extended) analysis

# Stage 1: Generate FPCore
BENCHMARK_NAMES_STAGE_1 =$(patsubst benchmarks/%.fpcore, %-fpcore, $(UNPAIRED_FPCORE_FILES))

$(BENCHMARK_NAMES_STAGE_1): %-fpcore: benchmarks/%-paired.fpcore 

fpcore: $(BENCHMARK_NAMES_STAGE_1)

# Stage 2: Generate Gappa
BENCHMARK_NAMES_STAGE_2 =$(patsubst benchmarks/%.fpcore, %-gappa, $(UNPAIRED_FPCORE_FILES))

$(BENCHMARK_NAMES_STAGE_2): %-gappa: benchmarks/%.g benchmarks/%-relative.g benchmarks/%-paired.g benchmarks/%-paired-relative.g 

gappa: $(BENCHMARK_NAMES_STAGE_2)

# Stage 3: Run Gappa
BENCHMARK_NAMES_STAGE_3 = $(patsubst %, %.out, $(wildcard benchmarks/*.g))
gappa-run: $(BENCHMARK_NAMES_STAGE_3)

# Stage 4: Run NumFuzz
BENCHMARK_NAMES_STAGE_4 = $(wildcard benchmarks/*.fz)

################################################################################
## Paper stuff

paper/main.pdf: paper/main.tex $(wildcard paper/sections/*.tex)
	cd paper && pdflatex -halt-on-error main.tex

################################################################################
## Meta stuff

all: .WAIT gappa gappa-run numfuzz

build:
	cd src && opam exec -- dune build

clean:
	rm -f benchmarks/*-paired.fpcore
	rm -f benchmarks/*.simple.fpcore
	rm -f benchmarks/*.g
	rm -f benchmarks/*.out
	cd src && opam exec dune clean

numfuzz: $(BENCHMARK_NAMES_STAGE_4)

paper: paper/main.pdf

abstest: scala

.PHONY: scala abstest build fpcore gappa gappa-run all clean $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2)
.NOTINTERMEDIATE: $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2) $(PAIRED_FILES) benchmarks/%-paired.fpcore benchmarks/%.g benchmarks/%.out
