#!/usr/bin/env python3
import sys
import argparse

def generate_horner_satire(n, interval_min=-1.0, interval_max=1.0):
    """Generate Horner polynomial file in the text format for degree n"""
    lines = []

    # INPUTS section
    lines.append('INPUTS {')
    lines.append(f'         x fl64 : ({interval_min}, {interval_max}) ;')

    # Add a0 to aN
    for i in range(n + 1):
        lines.append(f'         a{i} fl64 : ({interval_min}, {interval_max}) ;')

    lines.append('}')

    # OUTPUTS section
    lines.append('OUTPUTS {')
    lines.append('         Z_0 ;')
    lines.append('}')

    # EXPRS section
    lines.append('EXPRS {')

    # Generate Z_1 through Z_0
    # Z_1 = (aN * x + a(N-1))
    lines.append(f'        Z_1 rnd64 = (a{n}*x + a{n-1}) ;')

    # Z_i = (Z_(i-1) * x + a(N-i)) for i from 2 to N-1
    for i in range(2, n):
        lines.append(f'        Z_{i} rnd64 = (Z_{i-1}*x + a{n-i}) ;')

    # Final: Z_0 = (Z_(N-1) * x + a0)
    lines.append(f'        Z_0 rnd64 = (Z_{n-1}*x + a0) ;')

    lines.append('}')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate Satire file for Horner polynomial of degree n'
    )
    parser.add_argument('n', type=int,
                       help='Polynomial degree')
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

    content = generate_horner_satire(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()

