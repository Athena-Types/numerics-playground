UNPAIRED_FPCORE_FILES = $(filter-out $(wildcard benchmarks/*-paired.fpcore), $(wildcard benchmarks/*.fpcore))
FPCORE_FILES=$(wildcard benchmarks/*.fpcore)

PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(UNPAIRED_FPCORE_FILES))

# Stage 1: Generate FPCore
BENCHMARK_NAMES_STAGE_1 =$(patsubst benchmarks/%.fpcore, %-fpcore, $(UNPAIRED_FPCORE_FILES))

# Stage 2: Generate Gappa
BENCHMARK_NAMES_STAGE_2 =$(patsubst benchmarks/%.fpcore, %-gappa, $(UNPAIRED_FPCORE_FILES))

# Final stage: 
BENCHMARK_NAMES =$(patsubst benchmarks/%.fpcore, %, $(UNPAIRED_FPCORE_FILES))

### Lowering, i.e. FPCore (unpaired) -> FPCore (paired)
paired/_build/default/bin/main.exe: paired/bin/main.ml
	cd paired && opam exec -- dune build

### FPCore -> Gappa
benchmarks/%.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --lang g benchmarks/$*.fpcore benchmarks/$*.g 

benchmarks/%-relative.g: fpcore benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --rel-error --lang g benchmarks/$*.fpcore benchmarks/$*-relative.g 

gappa: $(patsubst %.fpcore, %.g, $(FPCORE_FILES))

benchmarks/%-paired.fpcore: paired/_build/default/bin/main.exe
	./paired/_build/default/bin/main.exe benchmarks/$*.fpcore > benchmarks/$*-paired.fpcore

$(BENCHMARK_NAMES_STAGE_1): %-fpcore: benchmarks/%-paired.fpcore 

fpcore: $(BENCHMARK_NAMES_STAGE_1)

$(BENCHMARK_NAMES_STAGE_2): %-gappa: benchmarks/%.g benchmarks/%-relative.g benchmarks/%-paired.g benchmarks/%-paired-relative.g 

gappa: $(BENCHMARK_NAMES_STAGE_2)

$(BENCHMARK_NAMES): $(BENCHMARK_NAMES_STAGE_2)

all: $(BENCHMARK_NAMES)

clean:
	rm -f benchmarks/*-paired.fpcore
	cd paired && opam exec dune clean

.PHONY: fpcore gappa all clean $(BENCHMARK_NAMES) $(BENCHMARK_NAMES_STAGE_1) $(BENCHMARK_NAMES_STAGE_2)
