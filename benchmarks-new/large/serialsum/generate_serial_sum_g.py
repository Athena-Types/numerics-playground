#!/usr/bin/env python3
import sys
import argparse

def generate_serial_sum_gappa(n, interval_min=-1, interval_max=1):
    """Generate Gappa file for serial sum of n elements"""
    lines = []

    # Rounding mode
    lines.append('@rnd = float<ieee_64, up>;')
    lines.append('')

    # Exact computation (r variables)
    for i in range(1, n):
        if i == 1:
            lines.append(f'r{i} = (a0 + a1);')
        else:
            lines.append(f'r{i} = (r{i-1} + a{i});')
    lines.append('')

    # Rounded computation (z variables)
    for i in range(1, n):
        if i == 1:
            lines.append(f'z{i} = rnd(a0 + a1);')
        else:
            lines.append(f'z{i} = rnd(z{i-1} + a{i});')
    lines.append('')

    # Logical formula (proof goal)
    lines.append('# the logical formula that Gappa will try (and succeed) to prove')
    lines.append('{')
    for i in range(n):
        lines.append(f'  a{i} in [{interval_min},{interval_max}]')
        if i < n-1:
            lines.append('  /\\')
    lines.append(f'  -> |(z{n-1} - r{n-1}) / r{n-1}| in ?')
    lines.append('}')

    return '\n'.join(lines)

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

    content = generate_serial_sum_gappa(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
