#!/usr/bin/env python3
import sys
import argparse

def generate_horner_gappa(n, interval_min=-1, interval_max=1):
    """Generate Gappa file for Horner polynomial of degree n"""
    lines = []

    # Rounding mode definition
    lines.append('@rnd = float<ieee_64, up>;')

    # R variable definitions (exact computation)
    if n == 2:
        # Special case for n=2
        lines.append(f'r  = (a{n} * x + a{n-1}) * x + a0;')
    else:
        # For n > 2: generate ri variables
        lines.append(f'r{n-1}  = (a{n} * x + a{n-1});')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            lines.append(f'r{i}  = (r{i+1} * x + a{i});')

        lines.append('r   = (r1 * x + a0);')

    # Z variable definitions (rounded computation)
    if n == 2:
        # Special case for n=2
        lines.append(f'z  = rnd(rnd(a{n} * x + a{n-1}) * x + a0);')
    else:
        # For n > 2: generate zi variables
        lines.append(f'z{n-1}  = rnd(a{n} * x + a{n-1});')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            lines.append(f'z{i}  = rnd(z{i+1} * x + a{i});')

        lines.append('z   = rnd(z1 * x + a0);')

    # Blank line and comment
    lines.append('')
    lines.append('# the logical formula that Gappa will try (and succeed) to prove')

    # Logical formula
    lines.append(f'{{ x in [{interval_min},{interval_max}]')

    # Constraints for a0 to aN
    for i in range(n + 1):
        lines.append(f'  /\\ a{i} in [{interval_min},{interval_max}]')

    # Final line
    lines.append('  -> |(z - r) / r| in ? }')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .g file for Horner polynomial of degree n'
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
    content = generate_horner_gappa(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()

