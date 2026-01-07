#!/usr/bin/env python3
import sys
import argparse

def generate_serial_sum_satire(n, interval_min=-1.0, interval_max=1.0):
    """Generate serial sum file in the text format for n elements"""
    lines = []

    # INPUTS section
    lines.append('INPUTS {')
    lines.append('')  # Blank line after INPUTS {
    
    # Add all A_0 through A_{n-1} variables
    for i in range(n):
        lines.append(f'A_{i}\t fl64 : ({interval_min}, {interval_max}) ;')

    lines.append('}')
    
    # OUTPUTS section
    lines.append('OUTPUTS {')
    lines.append('')  # Blank line after OUTPUTS {
    lines.append(f'A_0_{n-1} ;')
    lines.append('}')
    
    # EXPRS section
    lines.append('EXPRS {')
    lines.append('')  # Blank line after EXPRS {

    # First expression: A_0_1 = A_0 + A_1
    lines.append(f'A_0_1 rnd64 = A_0 + A_1 ;')
    lines.append(' ;')
    
    # Subsequent expressions: A_0_i = A_0_{i-1} + A_i for i from 2 to n-1
    for i in range(2, n):
        lines.append(f'A_0_{i} rnd64 = A_0_{i-1} + A_{i} ;')
        lines.append(' ;')

    lines.append('}')

    # Join with newlines and add trailing newline to match reference format
    return '\n'.join(lines) + '\n'

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

    content = generate_serial_sum_satire(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content, end='')

if __name__ == '__main__':
    main()
