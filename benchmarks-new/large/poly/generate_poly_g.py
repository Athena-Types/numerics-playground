#!/usr/bin/env python3
import sys
import argparse
import io

def generate_poly_gappa(f, n, interval_min=-1, interval_max=1):
    """Generate Gappa file for naive polynomial evaluation of degree n"""

    # Rounding mode definition
    f.write('@rnd = float<ieee_64, up>;\n')

    # R variable definitions (exact computation)
    # Compute x^1, x^2, ..., x^n (exact)
    if n >= 1:
        f.write('r_x_1  = x;\n')
    
    for i in range(2, n + 1):
        f.write(f'r_x_{i}  = (x * r_x_{i-1});\n')

    # Compute S_n, S_{n-1}, ..., S_1 (exact) where S_i = a_i * x^i
    if n >= 1:
        f.write('\n')
    
    for i in range(n, 0, -1):
        f.write(f'r_S_{i}  = (a{i} * r_x_{i});\n')

    # Compute exact final result: r = a0 + S_N + S_{N-1} + ... + S_1
    f.write('\n')
    sum_parts = ['a0']
    for i in range(1, n + 1):
        sum_parts.append(f'r_S_{i}')
    
    if len(sum_parts) == 1:
        f.write('r   = a0;\n')
    elif len(sum_parts) == 2:
        f.write(f'r   = ({sum_parts[0]} + {sum_parts[1]});\n')
    else:
        # Build nested additions
        sum_expr = f'({sum_parts[0]} + {sum_parts[1]})'
        for part in sum_parts[2:]:
            sum_expr = f'({sum_expr} + {part})'
        f.write(f'r   = {sum_expr};\n')

    # Z variable definitions (rounded computation)
    f.write('\n')
    
    # Compute x^1, x^2, ..., x^n (rounded)
    if n >= 1:
        f.write('z_x_1  = rnd(x);\n')
    
    for i in range(2, n + 1):
        f.write(f'z_x_{i}  = rnd(z_x_{i-1} * x);\n')

    # Compute S_n, S_{n-1}, ..., S_1 (rounded)
    if n >= 1:
        f.write('\n')
    
    for i in range(n, 0, -1):
        f.write(f'z_S_{i}  = rnd(a{i} * z_x_{i});\n')

    # Compute rounded final result: z = a0 + S_N + ... + S_1 (all rounded)
    f.write('\n')
    if len(sum_parts) == 1:
        f.write('z   = rnd(a0);\n')
    elif len(sum_parts) == 2:
        f.write(f'z   = rnd({sum_parts[0]} + z_S_1);\n')
    else:
        # Build nested rounded additions
        sum_expr = f'rnd({sum_parts[0]} + z_S_1)'
        for i, part in enumerate(sum_parts[2:], start=2):
            sum_expr = f'rnd({sum_expr} + z_S_{i})'
        f.write(f'z   = {sum_expr};\n')

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
        description='Generate .g file for naive polynomial evaluation of degree n'
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

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    if args.output:
        with open(args.output, 'w') as f:
            generate_poly_gappa(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_poly_gappa(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
