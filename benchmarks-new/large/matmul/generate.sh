generate() {
    python3 generate_dotprod.py $1 dotprod$1.fz
    python3 generate_mat_mul.py $1 matmul$1.fz
}

generate 4
generate 8
generate 16
generate 32
generate 64
generate 128
