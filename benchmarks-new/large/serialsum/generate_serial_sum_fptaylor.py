#!/usr/bin/env python3
import sys
import argparse
import io

def generate_serial_sum_fptaylor(f, n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for serial sum of n elements"""

    # Variables section
    f.write('Variables\n')
    for i in range(n):
        f.write(f'  float64 a{i} in [{interval_min}, {interval_max}];\n')
    f.write('\n')

    # Definitions section (intermediate sums)
    f.write('Definitions\n')
    for i in range(1, n-1):
        if i == 1:
            f.write(f'  s{i} = rnd64_up(a0 + a1);\n')
        else:
            f.write(f'  s{i} = rnd64_up(s{i-1} + a{i});\n')
    f.write('\n')

    # Expressions section (final sum)
    f.write('Expressions\n')
    if n == 2:
        f.write(f'  serial_sum{n} = rnd64_up(a0 + a1);')
    else:
        f.write(f'  serial_sum{n} = rnd64_up(s{n-2} + a{n-1});')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fptaylor file for serial sum of n elements'
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
            generate_serial_sum_fptaylor(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_serial_sum_fptaylor(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
