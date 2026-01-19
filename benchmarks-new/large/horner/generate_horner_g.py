#!/usr/bin/env python3
import sys
import argparse
import io

def generate_horner_gappa(f, n, interval_min=-1, interval_max=1):
    """Generate Gappa file for Horner polynomial of degree n"""

    # Rounding mode definition
    f.write('@rnd = float<ieee_64, up>;\n')

    # R variable definitions (exact computation)
    if n == 2:
        # Special case for n=2
        f.write(f'r  = (a{n} * x + a{n-1}) * x + a0;\n')
    else:
        # For n > 2: generate ri variables
        f.write(f'r{n-1}  = (a{n} * x + a{n-1});\n')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            f.write(f'r{i}  = (r{i+1} * x + a{i});\n')

        f.write('r   = (r1 * x + a0);\n')

    # Z variable definitions (rounded computation)
    if n == 2:
        # Special case for n=2
        f.write(f'z  = rnd(rnd(a{n} * x + a{n-1}) * x + a0);\n')
    else:
        # For n > 2: generate zi variables
        f.write(f'z{n-1}  = rnd(a{n} * x + a{n-1});\n')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            f.write(f'z{i}  = rnd(z{i+1} * x + a{i});\n')

        f.write('z   = rnd(z1 * x + a0);\n')

    # Define ex0 (rounded) and Mex0 (exact) for compute_bound.py
    f.write('\n')
    f.write('ex0 = z;\n')
    f.write('Mex0 = r;\n')

    # Blank line and comment
    f.write('\n')
    f.write('# the logical formula that Gappa will try (and succeed) to prove\n')

    # Logical formula
    f.write(f'{{ x in [{interval_min},{interval_max}]\n')

    # Constraints for a0 to aN
    for i in range(n + 1):
        f.write(f'  /\\ a{i} in [{interval_min},{interval_max}]\n')

    # Final line
    f.write('  -> |(z - r) / r| in ? }')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_horner_gappa(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_horner_gappa(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()

