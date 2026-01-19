#!/usr/bin/env python3
import sys
import argparse
import io

def generate_matmul_gappa(f, n, interval_min=-1, interval_max=1):
    """Generate Gappa file for full n x n matrix multiplication (all entries computed, error analyzed on c[0][0])"""

    # Rounding mode definition
    f.write('@rnd = float<ieee_64, up>;\n')
    f.write('\n')

    # Exact computation (r variables) - compute all n*n entries
    for i in range(n):
        for j in range(n):
            # For each entry c[i][j], compute dot product of row i of A and column j of B
            if n == 1:
                # Special case: first product
                f.write(f'r{i}{j} = (a{i}0 * b0{j});\n')
            else:
                # Compute products: rp{i}{j}_k = a[i][k] * b[k][j] (exact)
                for k in range(n):
                    if k == 0:
                        f.write(f'rp{i}{j}_{k} = (a{i}{k} * b{k}{j});\n')
                    else:
                        f.write(f'rp{i}{j}_{k} = (a{i}{k} * b{k}{j});\n')

                # Compute intermediate sums: rs{i}{j}_k (exact)
                for k in range(1, n):
                    if k == 1:
                        f.write(f'rs{i}{j}_{k} = (rp{i}{j}_0 + rp{i}{j}_{k});\n')
                    else:
                        f.write(f'rs{i}{j}_{k} = (rs{i}{j}_{k-1} + rp{i}{j}_{k});\n')

                # Final entry: r{i}{j} = last sum
                f.write(f'r{i}{j} = rs{i}{j}_{n-1};\n')

    f.write('\n')

    # Rounded computation (z variables) - compute all n*n entries
    for i in range(n):
        for j in range(n):
            # For each entry c[i][j], compute dot product with rounding
            if n == 1:
                # Special case: first product
                f.write(f'z{i}{j} = rnd(a{i}0 * b0{j});\n')
            else:
                # Compute products: zp{i}{j}_k = rnd(a[i][k] * b[k][j])
                for k in range(n):
                    if k == 0:
                        f.write(f'zp{i}{j}_{k} = rnd(a{i}{k} * b{k}{j});\n')
                    else:
                        f.write(f'zp{i}{j}_{k} = rnd(a{i}{k} * b{k}{j});\n')

                # Compute intermediate sums: zs{i}{j}_k (rounded)
                for k in range(1, n):
                    if k == 1:
                        f.write(f'zs{i}{j}_{k} = rnd(zp{i}{j}_0 + zp{i}{j}_{k});\n')
                    else:
                        f.write(f'zs{i}{j}_{k} = rnd(zs{i}{j}_{k-1} + zp{i}{j}_{k});\n')

                # Final entry: z{i}{j} = last sum
                f.write(f'z{i}{j} = zs{i}{j}_{n-1};\n')

    # Define ex0 (rounded) and Mex0 (exact) for compute_bound.py
    # Using z00 and r00 as they are the analyzed output
    f.write('\n')
    f.write('ex0 = z00;\n')
    f.write('Mex0 = r00;\n')

    # Blank line and comment
    f.write('\n')
    f.write('# the logical formula that Gappa will try (and succeed) to prove\n')

    # Logical formula
    f.write('{\n')

    # Constraints for all input variables
    first = True
    for i in range(n):
        for j in range(n):
            if first:
                f.write(f'  a{i}{j} in [{interval_min},{interval_max}]\n')
                first = False
            else:
                f.write(f'  /\\ a{i}{j} in [{interval_min},{interval_max}]\n')

    for i in range(n):
        for j in range(n):
            f.write(f'  /\\ b{i}{j} in [{interval_min},{interval_max}]\n')

    # Final line: only analyze absolute error on c[0][0]
    f.write(f'  -> |z00 - r00| in ?\n')
    f.write('}')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .g file for n x n matrix multiplication'
    )
    parser.add_argument('n', type=int,
                       help='Matrix dimension (must be at least 1)')
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
        print("Error: n must be at least 1", file=sys.stderr)
        sys.exit(1)

    if args.output:
        with open(args.output, 'w') as f:
            generate_matmul_gappa(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_matmul_gappa(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
