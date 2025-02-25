FPCORE_FILES = $(filter-out $(wildcard benchmarks/*-paired.fpcore), $(wildcard benchmarks/*.fpcore))

PAIRED_FILES=$(patsubst %.fpcore, %-paired.fpcore, $(FPCORE_FILES))

BENCHMARK_NAMES =$(patsubst benchmarks/%.fpcore, %, $(FPCORE_FILES))

paired/_build/default/bin/main.exe: paired/bin/main.ml
	cd paired && opam exec -- dune build

$(BENCHMARK_NAMES): paired/_build/default/bin/main.exe
	./paired/_build/default/bin/main.exe benchmarks/$@.fpcore > benchmarks/$@-paired.fpcore

all: $(BENCHMARK_NAMES)

clean:
	rm -f benchmarks/*-paired.fpcore
	cd paired && opam exec dune clean

.PHONY: all clean $(BENCHMARK_NAMES)
