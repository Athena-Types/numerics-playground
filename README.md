## numerics-playground
Directory layout:
- `src/` contains various utilities to parse, transform, and analyze fpcore
programs; in particular,

  * `lib/fpcore.ml` is a library to parse fpcore programs,

  * `bin/absint.ml` contains code to perform a basic abstract interpretation
  over fpcore programs,

  * `bin/abstest.ml` contains code to abstractly test a fpcore program (see
  [project proposal](https://github.com/sampsyo/cs6120/issues/510) for more
  details),

  * `bin/parse.ml` contains example code to parse and reparse a fpcore
  program (for testing / demo purposes), and,

  * `lib/fpcore.ml` is a library to help parse fpcore programs;

- `plots/` contains preliminary results and some plotting code;

- `deps/` contains the project dependencies as git submodules; and

- `benchmarks/` contains the fpcore and NumFuzz benchmarks that are being
evaluated against.

- `run.sh` contains a script to run everything 

- `test.sh` contains a script to test everything

NB: The Makefile is a bit buggy right now, need to figure out what's going on.
The test / run scripts are a hacky workaround until I fix the Makefile.
