#!/bin/bash

generate() {
    python3 generate_poly_fptaylor.py $1 Poly$1.fptaylor
    python3 generate_poly_fz.py $1 Poly$1.fz
    python3 generate_poly_g.py $1 Poly$1.g
}

generate 5
generate 10
generate 20
generate 50

for i in {100..2000..100}; do
    generate $i
done
