generate() {
    python3 generate_serial_sum_fptaylor.py $1 serial_sum_$1.fptaylor
    python3 generate_serial_sum_fz.py $1 serial_sum_$1.fz
    python3 generate_serial_sum_g.py $1 serial_sum_$1.g
}

# Generate for various sizes
generate 4
generate 8
generate 16
generate 32
generate 64
generate 128
generate 256
generate 512
generate 1024
