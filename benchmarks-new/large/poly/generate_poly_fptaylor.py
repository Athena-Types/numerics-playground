#!/usr/bin/env python3
import sys
import argparse

def generate_poly_fptaylor(n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for naive polynomial evaluation of degree n"""
    lines = []

    # Variables section header
    lines.append('Variables')

    # Add x variable
    lines.append(f'  float64 x  in [{interval_min}, {interval_max}];')

    # Add a0 to aN variables
    for i in range(n + 1):
        lines.append(f'  float64 a{i} in [{interval_min}, {interval_max}];')

    # Blank line
    lines.append('')

    # Definitions section header
    lines.append('Definitions')

    # Compute x^1, x^2, ..., x^n
    if n >= 1:
        lines.append('  x_1 = x;')
    
    for i in range(2, n + 1):
        lines.append(f'  x_{i} =rnd64_up(x * x_{i-1});')

    # Compute S_n, S_{n-1}, ..., S_1 where S_i = a_i * x^i
    if n >= 1:
        lines.append('')
    
    for i in range(n, 0, -1):
        lines.append(f'  S_{i} =rnd64_up(a{i} * x_{i});')

    # Blank line
    lines.append('')

    # Expressions section header
    lines.append('Expressions')

    # Final expression: PolyN = a0 + S_N + S_{N-1} + ... + S_1
    sum_parts = ['a0']
    for i in range(1, n + 1):
        sum_parts.append(f'S_{i}')
    
    if len(sum_parts) == 1:
        # Special case: just a0 (n=0, but we require n>=1)
        lines.append(f'  Poly{n} = a0;')
    elif len(sum_parts) == 2:
        # Special case: a0 + S_1
        lines.append(f'  Poly{n} =rnd64_up ({sum_parts[0]} + {sum_parts[1]});')
    else:
        # Build nested additions: rnd64_up(rnd64_up(...) + S_i)
        sum_expr = f'rnd64_up({sum_parts[0]} + {sum_parts[1]})'
        for part in sum_parts[2:]:
            sum_expr = f'rnd64_up({sum_expr} + {part})'
        lines.append(f'  Poly{n} = {sum_expr};')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fptaylor file for naive polynomial evaluation of degree n'
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

    content = generate_poly_fptaylor(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
