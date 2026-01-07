#!/usr/bin/env python3
import sys
import argparse

def generate_mat_mul_satire(n, interval_min=1.0, interval_max=2.0):
    """Generate matrix multiplication file in the text format for n×n matrices"""
    lines = []

    # INPUTS section
    lines.append('INPUTS {')
    
    # Add all A matrix elements
    for i in range(n):
        for j in range(n):
            lines.append(f'A_{i}_{j} fl64 : ({interval_min}, {interval_max}) ;')
    
    # Add all B matrix elements
    for i in range(n):
        for j in range(n):
            lines.append(f'B_{i}_{j} fl64 : ({interval_min}, {interval_max}) ;')

    lines.append('}')
    lines.append('')

    # OUTPUTS section
    lines.append('OUTPUTS {')
    
    # Add all C matrix elements
    for i in range(n):
        for j in range(n):
            lines.append(f'C_{i}_{j};')

    lines.append('}')
    lines.append('')

    # EXPRS section
    lines.append('EXPRS {')

    # Generate expressions for each C_i_j
    # C_i_j = sum of A_i_k * B_k_j for k from 0 to n-1
    for i in range(n):
        for j in range(n):
            # Build the sum expression
            terms = []
            for k in range(n):
                terms.append(f'A_{i}_{k}*B_{k}_{j}')
            expr = '+'.join(terms)
            lines.append(f'C_{i}_{j} rnd64 =  {expr} ;')

    lines.append('}')
    lines.append('')

    return '\n'.join(lines)

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

    content = generate_mat_mul_satire(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
