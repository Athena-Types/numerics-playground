#!/usr/bin/env python3
import sys
import argparse
import io

def generate_poly_fz(f, n, interval_min=-1, interval_max=1):
    """Generate naive polynomial evaluation file for degree n"""

    # Header
    f.write('#include "../../float_ops/addfp64.fz"\n')
    f.write('#include "../../float_ops/mulfp64.fz"\n')
    f.write('\n')

    # Function signature
    f.write(f'function Poly{n} \n')

    # Parameters a0 to aN
    for i in range(n + 1):
        f.write(f'  (a{i} : num)\n')

    # x parameter
    f.write(f'  (x : ![{n}.0]num) \n')
    f.write('{\n')

    # lcb line for x
    f.write("  lcb x' = x in\n")

    # Compute x^1, x^2, ..., x^n
    # x_1 = x
    if n >= 1:
        f.write("  lb x_1 = x' in\n")
    
    # x_i = x * x_{i-1} for i from 2 to n
    for i in range(2, n + 1):
        f.write(f"  lb x_{i} = mulfp64 (| x' , x_{i-1} |) in\n")
    
    # Compute S_n, S_{n-1}, ..., S_1 where S_i = a_i * x^i
    # For each i from n down to 1, compute S_i = a_i * x^i
    if n >= 1:
        f.write('\n')
    
    for i in range(n, 0, -1):
        f.write(f"  lb S_{i} = mulfp64 (| a{i} , x_{i} |) in\n")

    # Compute sum: Final = a0 + S_n + S_{n-1} + ... + S_1
    # Build up the sum sequentially
    f.write('\n')
    
    if n == 1:
        # Special case: just a0 + S_1
        f.write('  addfp64 (| a0 , S_1 |)\n')
    else:
        # Start with a0 + S_1
        f.write("  lb sum_1 = addfp64 (| a0 , S_1 |) in\n")
        
        # Add S_2 through S_n sequentially
        for i in range(2, n):
            f.write(f"  lb sum_{i} = addfp64 (| sum_{i-1} , S_{i} |) in\n")
        
        # Final addition with S_n
        f.write(f"  addfp64 (| sum_{n-1} , S_{n} |)\n")

    f.write('}\n')
    f.write('\n')

    # Function call
    call_line = f'Poly{n}'
    for _ in range(n + 2):
        call_line += f'[{interval_min},{interval_max}]'
    f.write(call_line)

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_poly_fz(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_poly_fz(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
