#!/usr/bin/env python3
import sys
import argparse
import io

def generate_horner_fz(f, n, interval_min=-1, interval_max=1):
    """Generate Horner polynomial file for degree n"""

    # Header
    f.write('#include "../../float_ops/fma64.fz"\n')
    f.write('\n')

    # Function signature
    f.write(f'function Horner{n} \n')

    # Parameters a0 to aN
    for i in range(n + 1):
        f.write(f'  (a{i} : num)\n')

    # x parameter
    f.write(f'  (x : ![{n}.0]num) \n')
    f.write('{\n')

    # lcb line
    f.write("  lcb x' = x in\n")

    # First lb z0 line
    f.write(f"  lb z0 = (((FMA64 a{n}) x') a{n-1}) in\n")

    # Blank line if n > 2
    if n > 2:
        f.write('\n')

    # Intermediate lb zi lines
    for i in range(1, n - 1):
        f.write(f"  lb z{i} = (((FMA64 z{i-1}) x') a{n-i-1}) in\n")

    # Blank line and final expression
    if n > 2:
        f.write('\n')
    f.write(f"  (((FMA64 z{n-2}) x') a0)\n")
    f.write('}\n')
    f.write('\n')

    # Function call
    call_line = f'Horner{n}'
    for _ in range(n + 2):
        call_line += f'[{interval_min},{interval_max}]'
    f.write(call_line)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for Horner polynomial of degree n'
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
            generate_horner_fz(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_horner_fz(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()

