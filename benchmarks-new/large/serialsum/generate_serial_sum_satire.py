#!/usr/bin/env python3
import sys
import argparse
import io

def generate_serial_sum_satire(f, n, interval_min=-1.0, interval_max=1.0):
    """Generate serial sum file in the text format for n elements"""

    # INPUTS section
    f.write('INPUTS {\n')
    f.write('\n')  # Blank line after INPUTS {
    
    # Add all A_0 through A_{n-1} variables
    for i in range(n):
        f.write(f'A_{i}\t fl64 : ({interval_min}, {interval_max}) ;\n')

    f.write('}\n')
    
    # OUTPUTS section
    f.write('OUTPUTS {\n')
    f.write('\n')  # Blank line after OUTPUTS {
    f.write(f'A_0_{n-1} ;\n')
    f.write('}\n')
    
    # EXPRS section
    f.write('EXPRS {\n')
    f.write('\n')  # Blank line after EXPRS {

    # First expression: A_0_1 = A_0 + A_1
    f.write(f'A_0_1 rnd64 = A_0 + A_1 ;\n')
    f.write(' ;\n')
    
    # Subsequent expressions: A_0_i = A_0_{i-1} + A_i for i from 2 to n-1
    for i in range(2, n):
        f.write(f'A_0_{i} rnd64 = A_0_{i-1} + A_{i} ;\n')
        f.write(' ;\n')

    f.write('}\n')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate Satire file for serial sum of n elements'
    )
    parser.add_argument('n', type=int,
                       help='Number of elements to sum')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=-1.0,
                       help='Minimum interval bound (default: -1.0)')
    parser.add_argument('--interval-max', type=float, default=1.0,
                       help='Maximum interval bound (default: 1.0)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 2:
        print("Error: n must be at least 2")
        sys.exit(1)

    if args.output:
        with open(args.output, 'w') as f:
            generate_serial_sum_satire(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_serial_sum_satire(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
