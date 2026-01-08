#!/usr/bin/env python3
import sys
import argparse

def generate_poly_satire(n, interval_min=-1.0, interval_max=1.0):
    """Generate naive polynomial evaluation file in SATIRE text format for degree n"""
    lines = []

    # INPUTS section
    lines.append('INPUTS {')
    lines.append(f'         x fl64 : ({interval_min}, {interval_max}) ;')

    # Add a0 to aN
    for i in range(n + 1):
        lines.append(f'         a{i} fl64 : ({interval_min}, {interval_max}) ;')

    lines.append('}')

    # OUTPUTS section
    lines.append('OUTPUTS {')
    lines.append('         Final ;')
    lines.append('}')

    # EXPRS section
    lines.append('EXPRS {')

    # Generate S_n, S_{n-1}, ..., S_1 where S_i = a_i * x^i
    # For each i from n down to 1, compute S_i = a_i * x^i
    # where x^i is computed as repeated multiplication: x * x * ... * x (i times)
    acc = []
    for i in range(n, 0, -1):
        # Build x^i: x * x * ... * x (i times)
        if i == 1:
            x_power = "x"
        else:
            x_power = "( " + " * ".join(["x"] * i) + " )"
        
        # S_i = a_i * x^i
        lines.append(f'        S_{i} rnd64 = (a{i} * {x_power}) ;')
        acc.append(f'S_{i}')

    # Final expression: Final = a0 + S_n + S_{n-1} + ... + S_1
    if acc:
        acc_str = " + ".join(acc)
        lines.append(f'        Final rnd64 = (a0 + {acc_str}) ;')
    else:
        # Special case: n=0 (but we require n>=1)
        lines.append('        Final rnd64 = a0 ;')

    lines.append('}')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate Satire file for naive polynomial evaluation of degree n'
    )
    parser.add_argument('n', type=int,
                       help='Polynomial degree')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=-1.0,
                       help='Minimum interval bound (default: -1.0)')
    parser.add_argument('--interval-max', type=float, default=1.0,
                       help='Maximum interval bound (default: 1.0)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    content = generate_poly_satire(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
