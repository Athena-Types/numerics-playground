#!/usr/bin/env python3
import sys
import argparse
import io

def generate_horner_fptaylor(f, n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for Horner polynomial of degree n"""

    # Variables section header
    f.write('Variables\n')

    # Add x variable
    f.write(f'  float64 x  in [{interval_min}, {interval_max}];\n')

    # Add a0 to aN variables
    for i in range(n + 1):
        f.write(f'  float64 a{i} in [{interval_min}, {interval_max}];\n')

    # Blank line
    f.write('\n')

    # Definitions section header
    f.write('Definitions\n')

    # Add z1 to z(n-1) definitions
    for i in range(1, n):
        if i == 1:
            # First definition: z1 = rnd64_up(aN * x + a(N-1))
            f.write(f'  z{i} =rnd64_up(a{n} * x + a{n-1});\n')
        else:
            # Subsequent definitions: zi = rnd64_up(z(i-1) * x + a(N-i))
            f.write(f'  z{i} =rnd64_up(z{i-1} * x + a{n-i});\n')

    # Blank line
    f.write('\n')

    # Expressions section header
    f.write('Expressions\n')

    # Final expression: HornerN = rnd64_up(z(N-1) * x + a0)
    f.write(f'  Horner{n} =rnd64_up (z{n-1} * x + a0);')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fptaylor file for Horner polynomial of degree n'
    )
    parser.add_argument('n', type=int,
                       help='Polynomial degree')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=-1,
                       help='Minimum interval bound (default: -1)')
    parser.add_argument('--interval-max', type=float, default=1,
                       help='Maximum interval bound (default: 1)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.output:
        with open(args.output, 'w') as f:
            generate_horner_fptaylor(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_horner_fptaylor(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()

