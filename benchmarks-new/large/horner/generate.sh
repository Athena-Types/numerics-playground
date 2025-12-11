generate() {
    python3 generate_horner_fptaylor.py $1 Horner$1.fptaylor
    python3 generate_horner_fz.py $1 Horner$1.fz
    python3 generate_horner_g.py $1 Horner$1.g
}

generate 5
generate 10
generate 20
generate 50

for i in {100..2000..100}; do
    generate $i
done
