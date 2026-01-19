#!/usr/bin/env python3
import sys
import argparse
import io

def generate_horner_satire(f, n, interval_min=-1.0, interval_max=1.0):
    """Generate Horner polynomial file in the text format for degree n"""

    # INPUTS section
    f.write('INPUTS {\n')
    f.write(f'         x fl64 : ({interval_min}, {interval_max}) ;\n')

    # Add a0 to aN
    for i in range(n + 1):
        f.write(f'         a{i} fl64 : ({interval_min}, {interval_max}) ;\n')

    f.write('}\n')

    # OUTPUTS section
    f.write('OUTPUTS {\n')
    f.write('         Z_0 ;\n')
    f.write('}\n')

    # EXPRS section
    f.write('EXPRS {\n')

    # Generate Z_1 through Z_0
    # Z_1 = (aN * x + a(N-1))
    f.write(f'        Z_1 rnd64 = (a{n}*x + a{n-1}) ;\n')

    # Z_i = (Z_(i-1) * x + a(N-i)) for i from 2 to N-1
    for i in range(2, n):
        f.write(f'        Z_{i} rnd64 = (Z_{i-1}*x + a{n-i}) ;\n')

    # Final: Z_0 = (Z_(N-1) * x + a0)
    f.write(f'        Z_0 rnd64 = (Z_{n-1}*x + a0) ;\n')

    f.write('}')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_horner_satire(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_horner_satire(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()

