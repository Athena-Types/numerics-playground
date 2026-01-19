#!/usr/bin/env python3
import sys
import argparse
import io

def generate_poly_satire(f, n, interval_min=-1.0, interval_max=1.0):
    """Generate naive polynomial evaluation file in SATIRE text format for degree n"""

    # INPUTS section
    f.write('INPUTS {\n')
    f.write(f'         x fl64 : ({interval_min}, {interval_max}) ;\n')

    # Add a0 to aN
    for i in range(n + 1):
        f.write(f'         a{i} fl64 : ({interval_min}, {interval_max}) ;\n')

    f.write('}\n')

    # OUTPUTS section
    f.write('OUTPUTS {\n')
    f.write('         Final ;\n')
    f.write('}\n')

    # EXPRS section
    f.write('EXPRS {\n')

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
        f.write(f'        S_{i} rnd64 = (a{i} * {x_power}) ;\n')
        acc.append(f'S_{i}')

    # Final expression: Final = a0 + S_n + S_{n-1} + ... + S_1
    if acc:
        acc_str = " + ".join(acc)
        f.write(f'        Final rnd64 = (a0 + {acc_str}) ;\n')
    else:
        # Special case: n=0 (but we require n>=1)
        f.write('        Final rnd64 = a0 ;\n')

    f.write('}')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_poly_satire(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_poly_satire(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
