#!/usr/bin/env python3
import sys
import argparse
import io

def generate_serial_sum_gappa(f, n, interval_min=-1, interval_max=1):
    """Generate Gappa file for serial sum of n elements"""

    # Rounding mode
    f.write('@rnd = float<ieee_64, up>;\n')
    f.write('\n')

    # Exact computation (r variables)
    for i in range(1, n):
        if i == 1:
            f.write(f'r{i} = (a0 + a1);\n')
        else:
            f.write(f'r{i} = (r{i-1} + a{i});\n')
    f.write('\n')

    # Rounded computation (z variables)
    for i in range(1, n):
        if i == 1:
            f.write(f'z{i} = rnd(a0 + a1);\n')
        else:
            f.write(f'z{i} = rnd(z{i-1} + a{i});\n')
    f.write('\n')

    # Define ex0 (rounded) and Mex0 (exact) for compute_bound.py
    f.write(f'ex0 = z{n-1};\n')
    f.write(f'Mex0 = r{n-1};\n')
    f.write('\n')

    # Logical formula (proof goal)
    f.write('# the logical formula that Gappa will try (and succeed) to prove\n')
    f.write('{\n')
    for i in range(n):
        f.write(f'  a{i} in [{interval_min},{interval_max}]\n')
        if i < n-1:
            f.write('  /\\\n')
    f.write(f'  -> |(z{n-1} - r{n-1}) / r{n-1}| in ?\n')
    f.write('}')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .g file for serial sum of n elements'
    )
    parser.add_argument('n', type=int,
                       help='Number of elements to sum')
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
            generate_serial_sum_gappa(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_serial_sum_gappa(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
