
### Lowering, i.e. FPCore (unpaired) -> FPCore (paired)
paired/_build/default/bin/main.exe: paired/bin/main.ml
	cd paired && opam exec -- dune build

benchmarks/%-paired.fpcore: paired/_build/default/bin/main.exe
	./paired/_build/default/bin/main.exe benchmarks/$*.fpcore > benchmarks/$*-paired.fpcore

### FPCore -> Gappa
benchmarks/%.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --lang g benchmarks/$*.fpcore benchmarks/$*.g 
	python benchmark.py benchmarks/$*.g 

benchmarks/%-relative.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --rel-error --lang g benchmarks/$*.fpcore benchmarks/$*-relative.g 
	python benchmark.py benchmarks/$*-relative.g 

### Running Gappa
benchmarks/%.g.out: benchmarks/%.g
	gappa benchmarks/$*.g &> benchmarks/$*.g.out

################################################################################

### Defining phony stages
UNPAIRED_FPCORE_FILES = $(filter-out $(wildcard benchmarks/*-paired.fpcore), $(wildcard benchmarks/*.fpcore))
FPCORE_FILES=$(wildcard benchmarks/*.fpcore)

PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(UNPAIRED_FPCORE_FILES))

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

all: .WAIT gappa gappa-run

clean:
	rm -f benchmarks/*-paired.fpcore
	rm -f benchmarks/*.g
	cd paired && opam exec dune clean

.PHONY: fpcore gappa gappa-run all clean $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2)
.NOTINTERMEDIATE: $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2) $(PAIRED_FILES) benchmarks/%-paired.fpcore benchmarks/%.g benchmarks/%.out
