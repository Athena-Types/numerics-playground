UNPAIRED_FPCORE_FILES = $(filter-out $(wildcard benchmarks/*-paired.fpcore), $(wildcard benchmarks/*.fpcore))
FPCORE_FILES=$(wildcard benchmarks/*.fpcore)

PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(UNPAIRED_FPCORE_FILES))

BENCHMARK_NAMES =$(patsubst benchmarks/%.fpcore, %, $(UNPAIRED_FPCORE_FILES))

### Lowering, i.e. FPCore (unpaired) -> FPCore (paired)
paired/_build/default/bin/main.exe: paired/bin/main.ml
	cd paired && opam exec -- dune build


### FPCore -> Gappa
benchmarks/%.g: benchmarks/%.fpcore
	racket deps/FPBench/export.rkt --lang g benchmarks/$*.fpcore benchmarks/$*.g 

gappa: $(patsubst %.fpcore, %.g, $(FPCORE_FILES))

benchmarks/%-paired.fpcore: paired/_build/default/bin/main.exe
	./paired/_build/default/bin/main.exe benchmarks/$*.fpcore > benchmarks/$*-paired.fpcore

$(BENCHMARK_NAMES): %: benchmarks/%-paired.fpcore benchmarks/%.g benchmarks/%-paired.g

all: $(BENCHMARK_NAMES)

clean:
	rm -f benchmarks/*-paired.fpcore
	cd paired && opam exec dune clean

.PHONY: gappa all clean $(BENCHMARK_NAMES)
