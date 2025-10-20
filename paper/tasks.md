## Tracking outstanding tasks

Paper tasks (big):
- [ ] Prove language instantiation we care about satisfies interface spec; final
error soundness for the instantiated langauge we care about.

- [ ] Soundness of polymorphic type inference; maybe relative completeness
proof?

- [ ] Prove that bounds are "no looser" in the paired setup.

- [x] Finish defining interface for iop

- [x] Complete soundness proof w bound polymorphism.

Implementation tasks:

- [ ] Polymorphism, type inference (blocked on actual type inference algo) 

- [ ] Rust impl? Might be much easier than hacking stuff into the OCaml impl.

Misc. tasks (med - small):

- [ ] Do I even need the syntactic lemmas for type soundness? I don't really

seem to use them anymore.
- [ ] Double-check if r-sensitive sub works with polymorphism (something seems
off).

- [ ] Chelesky decomp inner loop?
