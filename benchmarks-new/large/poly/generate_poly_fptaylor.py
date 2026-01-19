#!/usr/bin/env python3
import sys
import argparse
import io

def generate_poly_fptaylor(f, n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for naive polynomial evaluation of degree n"""

    # Variables section header
    f.write('Variables\n')

    # Add x variable
    f.write(f'  float64 x  in [{interval_min}, {interval_max}];\n')

    # Add a0 to aN variables
    for i in range(n + 1):
        f.write(f'  float64 a{i} in [{interval_min}, {interval_max}];\n')

    # Blank line
    f.write('\n')

    # Definitions section header
    f.write('Definitions\n')

    # Compute x^1, x^2, ..., x^n
    if n >= 1:
        f.write('  x_1 = x;\n')
    
    for i in range(2, n + 1):
        f.write(f'  x_{i} =rnd64_up(x * x_{i-1});\n')

    # Compute S_n, S_{n-1}, ..., S_1 where S_i = a_i * x^i
    if n >= 1:
        f.write('\n')
    
    for i in range(n, 0, -1):
        f.write(f'  S_{i} =rnd64_up(a{i} * x_{i});\n')

    # Blank line
    f.write('\n')

    # Expressions section header
    f.write('Expressions\n')

    # Final expression: PolyN = a0 + S_N + S_{N-1} + ... + S_1
    sum_parts = ['a0']
    for i in range(1, n + 1):
        sum_parts.append(f'S_{i}')
    
    if len(sum_parts) == 1:
        # Special case: just a0 (n=0, but we require n>=1)
        f.write(f'  Poly{n} = a0;')
    elif len(sum_parts) == 2:
        # Special case: a0 + S_1
        f.write(f'  Poly{n} =rnd64_up ({sum_parts[0]} + {sum_parts[1]});')
    else:
        # Build nested additions: rnd64_up(rnd64_up(...) + S_i)
        sum_expr = f'rnd64_up({sum_parts[0]} + {sum_parts[1]})'
        for part in sum_parts[2:]:
            sum_expr = f'rnd64_up({sum_expr} + {part})'
        f.write(f'  Poly{n} = {sum_expr};')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_poly_fptaylor(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_poly_fptaylor(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
