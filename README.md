## numerics-playground
This repository contains various assorted experiments for reasoning about
numerical programs.

Directory layout:
- `src/` contains various utilities to parse, transform, and analyze fpcore
programs; in particular,

  * `bin/absint.ml` contains code to perform a basic abstract interpretation
  over fpcore programs,

  * `bin/abstest.ml` contains code to abstractly test a fpcore program (see
  [project proposal](https://github.com/sampsyo/cs6120/issues/510) for more
  details),

  * `bin/paired.ml` contains code to transform a fpcore program into its paired
  representation (to avoid needing to reason about catastrophic cancellation in
  a compositional fashion),

  * `bin/parse.ml` contains example code to parse and reparse a fpcore
  program (for testing / demo purposes), and,

  * `lib/fpcore.ml` is a somewhat messy library to help parse fpcore programs;

- `paper/` contains a writeup of the technical details regarding how to extend
NumFuzz in various ways; in particular,

  * `sections/*.tex` splits up the portions of the paper into logical sections,
    and

  * `main.tex` collates the sections and adds title and metadata and whatnot;

- `plots/` contains preliminary results and some plotting code;

- `deps/` contains the project dependencies as git submodules;

- `benchmarks/` contains the fpcore and NumFuzz benchmarks that are being
evaluated against;

- `fpcodegen/` contains helpful code generation utilities for generating benchmarks;

- `run.sh` contains a script to run everything; and

- `error.v` contains a self-contained mechanized proof of *error simulation*; in
particular, it shows that the paired translation of a program can simulate all
error present in the original program;

- `test.sh` contains a script to test everything.

A (partial, currently on-hold) Coq mechanization effort of NumFuzz sits in a
separate repo because Coq dependencies are very annoying.

NB: The Makefile is a bit buggy right now, need to figure out what's going on.
The test / run scripts are a hacky workaround until I fix the Makefile. Also
beware that the code in this repository is quite ugly. Read at your own peril.

## Dependencies
Main deps:
- zarith
- base 
- re2 
- re_parser

Ppx rewriters used:
- ppx_deriving
- ppx_sexp_conv 
