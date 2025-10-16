## Tracking outstanding tasks

Paper tasks (big):
- [ ] Finish defining interface for iop

- [ ] Prove language instantiation we care about satisfies interface spec; final
error soundness for the instantiated langauge we care about.

- [ ] Complete soundness proof w bound polymorphism.

- [ ] Soundness of polymorphic type inference; maybe relative completeness
proof?

- [ ] Prove that bounds are "no looser" in the paired setup.

Implementation tasks:

- [ ] Polymorphism, type inference (blocked on actual type inference algo) 

- [ ] Rust impl? Might be much easier than hacking stuff into the OCaml impl.

Misc. tasks (med - small):

- [ ] Do I even need the syntactic lemmas for type soundness? I don't really

seem to use them anymore.
- [ ] Double-check if r-sensitive sub works with polymorphism (something seems
off).

