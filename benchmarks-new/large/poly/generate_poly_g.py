#!/usr/bin/env python3
import sys
import argparse

def generate_poly_gappa(n, interval_min=-1, interval_max=1):
    """Generate Gappa file for naive polynomial evaluation of degree n"""
    lines = []

    # Rounding mode definition
    lines.append('@rnd = float<ieee_64, up>;')

    # R variable definitions (exact computation)
    # Compute x^1, x^2, ..., x^n (exact)
    if n >= 1:
        lines.append('r_x_1  = x;')
    
    for i in range(2, n + 1):
        lines.append(f'r_x_{i}  = (x * r_x_{i-1});')

    # Compute S_n, S_{n-1}, ..., S_1 (exact) where S_i = a_i * x^i
    if n >= 1:
        lines.append('')
    
    for i in range(n, 0, -1):
        lines.append(f'r_S_{i}  = (a{i} * r_x_{i});')

    # Compute exact final result: r = a0 + S_N + S_{N-1} + ... + S_1
    lines.append('')
    sum_parts = ['a0']
    for i in range(1, n + 1):
        sum_parts.append(f'r_S_{i}')
    
    if len(sum_parts) == 1:
        lines.append('r   = a0;')
    elif len(sum_parts) == 2:
        lines.append(f'r   = ({sum_parts[0]} + {sum_parts[1]});')
    else:
        # Build nested additions
        sum_expr = f'({sum_parts[0]} + {sum_parts[1]})'
        for part in sum_parts[2:]:
            sum_expr = f'({sum_expr} + {part})'
        lines.append(f'r   = {sum_expr};')

    # Z variable definitions (rounded computation)
    lines.append('')
    
    # Compute x^1, x^2, ..., x^n (rounded)
    if n >= 1:
        lines.append('z_x_1  = rnd(x);')
    
    for i in range(2, n + 1):
        lines.append(f'z_x_{i}  = rnd(z_x_{i-1} * x);')

    # Compute S_n, S_{n-1}, ..., S_1 (rounded)
    if n >= 1:
        lines.append('')
    
    for i in range(n, 0, -1):
        lines.append(f'z_S_{i}  = rnd(a{i} * z_x_{i});')

    # Compute rounded final result: z = a0 + S_N + ... + S_1 (all rounded)
    lines.append('')
    if len(sum_parts) == 1:
        lines.append('z   = rnd(a0);')
    elif len(sum_parts) == 2:
        lines.append(f'z   = rnd({sum_parts[0]} + z_S_1);')
    else:
        # Build nested rounded additions
        sum_expr = f'rnd({sum_parts[0]} + z_S_1)'
        for i, part in enumerate(sum_parts[2:], start=2):
            sum_expr = f'rnd({sum_expr} + z_S_{i})'
        lines.append(f'z   = {sum_expr};')

    # Define ex0 (rounded) and Mex0 (exact) for compute_bound.py
    lines.append('')
    lines.append('ex0 = z;')
    lines.append('Mex0 = r;')

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

    content = generate_poly_gappa(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
