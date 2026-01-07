generate() {
    python3 generate_dotprod.py $1 dotprod$1.fz
    python3 generate_mat_mul.py $1 matmul$1.fz
    python3 generate_matmul_fptaylor.py $1 matmul$1.fptaylor
    python3 generate_matmul_g.py $1 matmul$1.g
}

generate 4
generate 8
generate 16
generate 32
generate 64
generate 128
generate 256
