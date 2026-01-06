#!/usr/bin/env python3
import sys
import argparse

def generate_serial_sum_fptaylor(n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for serial sum of n elements"""
    lines = []

    # Variables section
    lines.append('Variables')
    for i in range(n):
        lines.append(f'  float64 a{i} in [{interval_min}, {interval_max}];')
    lines.append('')

    # Definitions section (intermediate sums)
    lines.append('Definitions')
    for i in range(1, n-1):
        if i == 1:
            lines.append(f'  s{i} = rnd64_up(a0 + a1);')
        else:
            lines.append(f'  s{i} = rnd64_up(s{i-1} + a{i});')
    lines.append('')

    # Expressions section (final sum)
    lines.append('Expressions')
    if n == 2:
        lines.append(f'  serial_sum{n} = rnd64_up(a0 + a1);')
    else:
        lines.append(f'  serial_sum{n} = rnd64_up(s{n-2} + a{n-1});')

    return '\n'.join(lines)

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

    content = generate_serial_sum_fptaylor(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
