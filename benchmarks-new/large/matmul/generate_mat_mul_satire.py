#!/usr/bin/env python3
import sys
import argparse
import io

def generate_mat_mul_satire(f, n, interval_min=1.0, interval_max=2.0):
    """Generate matrix multiplication file in the text format for n×n matrices"""

    # INPUTS section
    f.write('INPUTS {\n')
    
    # Add all A matrix elements
    for i in range(n):
        for j in range(n):
            f.write(f'A_{i}_{j} fl64 : ({interval_min}, {interval_max}) ;\n')
    
    # Add all B matrix elements
    for i in range(n):
        for j in range(n):
            f.write(f'B_{i}_{j} fl64 : ({interval_min}, {interval_max}) ;\n')

    f.write('}\n')
    f.write('\n')

    # OUTPUTS section
    f.write('OUTPUTS {\n')
    
    # Add all C matrix elements
    for i in range(n):
        for j in range(n):
            f.write(f'C_{i}_{j};\n')

    f.write('}\n')
    f.write('\n')

    # EXPRS section
    f.write('EXPRS {\n')

    # Generate expressions for each C_i_j
    # C_i_j = sum of A_i_k * B_k_j for k from 0 to n-1
    for i in range(n):
        for j in range(n):
            # Build the sum expression
            terms = []
            for k in range(n):
                terms.append(f'A_{i}_{k}*B_{k}_{j}')
            expr = '+'.join(terms)
            f.write(f'C_{i}_{j} rnd64 =  {expr} ;\n')

    f.write('}\n')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate Satire file for matrix multiplication of n×n matrices'
    )
    parser.add_argument('n', type=int,
                       help='Matrix dimension (must be at least 1)')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=1.0,
                       help='Minimum interval bound (default: 1.0)')
    parser.add_argument('--interval-max', type=float, default=2.0,
                       help='Maximum interval bound (default: 2.0)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    if args.output:
        with open(args.output, 'w') as f:
            generate_mat_mul_satire(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_mat_mul_satire(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
