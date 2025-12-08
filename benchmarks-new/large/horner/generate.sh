generate() {
    python3 generate_horner_fptaylor.py $i > Horner$i.fptaylor
    python3 generate_horner_fz.py $i > Horner$i.fz
    python3 generate_horner_g.py $i > Horner$i.g
}

generate 5
generate 10
generate 20
generate 50

for i in {100..2000..100}; do
    generate i
done
