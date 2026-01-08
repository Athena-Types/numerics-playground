#!/usr/bin/env python3
import sys
import argparse

def generate_poly_fz(n, interval_min=-1, interval_max=1):
    """Generate naive polynomial evaluation file for degree n"""
    lines = []

    # Header
    lines.append('#include "../../float_ops/addfp64.fz"')
    lines.append('#include "../../float_ops/mulfp64.fz"')
    lines.append('')

    # Function signature
    lines.append(f'function Poly{n} ')

    # Parameters a0 to aN
    for i in range(n + 1):
        lines.append(f'  (a{i} : num)')

    # x parameter
    lines.append(f'  (x : ![{n}.0]num) ')
    lines.append('{')

    # lcb line for x
    lines.append("  lcb x' = x in")

    # Compute x^1, x^2, ..., x^n
    # x_1 = x
    if n >= 1:
        lines.append("  lb x_1 = x' in")
    
    # x_i = x * x_{i-1} for i from 2 to n
    for i in range(2, n + 1):
        lines.append(f"  lb x_{i} = mulfp64 (| x' , x_{i-1} |) in")
    
    # Compute S_n, S_{n-1}, ..., S_1 where S_i = a_i * x^i
    # For each i from n down to 1, compute S_i = a_i * x^i
    if n >= 1:
        lines.append('')
    
    for i in range(n, 0, -1):
        lines.append(f"  lb S_{i} = mulfp64 (| a{i} , x_{i} |) in")

    # Compute sum: Final = a0 + S_n + S_{n-1} + ... + S_1
    # Build up the sum sequentially
    lines.append('')
    
    if n == 1:
        # Special case: just a0 + S_1
        lines.append('  addfp64 (| a0 , S_1 |)')
    else:
        # Start with a0 + S_1
        lines.append("  lb sum_1 = addfp64 (| a0 , S_1 |) in")
        
        # Add S_2 through S_n sequentially
        for i in range(2, n):
            lines.append(f"  lb sum_{i} = addfp64 (| sum_{i-1} , S_{i} |) in")
        
        # Final addition with S_n
        lines.append(f"  addfp64 (| sum_{n-1} , S_{n} |)")

    lines.append('}')
    lines.append('')

    # Function call
    call_line = f'Poly{n}'
    for _ in range(n + 2):
        call_line += f'[{interval_min},{interval_max}]'
    lines.append(call_line)

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for naive polynomial evaluation of degree n'
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

    content = generate_poly_fz(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
