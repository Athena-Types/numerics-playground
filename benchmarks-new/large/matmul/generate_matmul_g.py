#!/usr/bin/env python3
import sys
import argparse

def generate_matmul_gappa(n, interval_min=-1, interval_max=1):
    """Generate Gappa file for full n x n matrix multiplication (all entries computed, error analyzed on c[0][0])"""
    lines = []

    # Rounding mode definition
    lines.append('@rnd = float<ieee_64, up>;')
    lines.append('')

    # Exact computation (r variables) - compute all n*n entries
    for i in range(n):
        for j in range(n):
            # For each entry c[i][j], compute dot product of row i of A and column j of B
            if n == 1:
                # Special case: first product
                lines.append(f'r{i}{j} = (a{i}0 * b0{j});')
            else:
                # Compute products: rp{i}{j}_k = a[i][k] * b[k][j] (exact)
                for k in range(n):
                    if k == 0:
                        lines.append(f'rp{i}{j}_{k} = (a{i}{k} * b{k}{j});')
                    else:
                        lines.append(f'rp{i}{j}_{k} = (a{i}{k} * b{k}{j});')

                # Compute intermediate sums: rs{i}{j}_k (exact)
                for k in range(1, n):
                    if k == 1:
                        lines.append(f'rs{i}{j}_{k} = (rp{i}{j}_0 + rp{i}{j}_{k});')
                    else:
                        lines.append(f'rs{i}{j}_{k} = (rs{i}{j}_{k-1} + rp{i}{j}_{k});')

                # Final entry: r{i}{j} = last sum
                lines.append(f'r{i}{j} = rs{i}{j}_{n-1};')

    lines.append('')

    # Rounded computation (z variables) - compute all n*n entries
    for i in range(n):
        for j in range(n):
            # For each entry c[i][j], compute dot product with rounding
            if n == 1:
                # Special case: first product
                lines.append(f'z{i}{j} = rnd(a{i}0 * b0{j});')
            else:
                # Compute products: zp{i}{j}_k = rnd(a[i][k] * b[k][j])
                for k in range(n):
                    if k == 0:
                        lines.append(f'zp{i}{j}_{k} = rnd(a{i}{k} * b{k}{j});')
                    else:
                        lines.append(f'zp{i}{j}_{k} = rnd(a{i}{k} * b{k}{j});')

                # Compute intermediate sums: zs{i}{j}_k (rounded)
                for k in range(1, n):
                    if k == 1:
                        lines.append(f'zs{i}{j}_{k} = rnd(zp{i}{j}_0 + zp{i}{j}_{k});')
                    else:
                        lines.append(f'zs{i}{j}_{k} = rnd(zs{i}{j}_{k-1} + zp{i}{j}_{k});')

                # Final entry: z{i}{j} = last sum
                lines.append(f'z{i}{j} = zs{i}{j}_{n-1};')

    # Blank line and comment
    lines.append('')
    lines.append('# the logical formula that Gappa will try (and succeed) to prove')

    # Logical formula
    lines.append('{')

    # Constraints for all input variables
    first = True
    for i in range(n):
        for j in range(n):
            if first:
                lines.append(f'  a{i}{j} in [{interval_min},{interval_max}]')
                first = False
            else:
                lines.append(f'  /\\ a{i}{j} in [{interval_min},{interval_max}]')

    for i in range(n):
        for j in range(n):
            lines.append(f'  /\\ b{i}{j} in [{interval_min},{interval_max}]')

    # Final line: only analyze absolute error on c[0][0]
    lines.append(f'  -> |z00 - r00| in ?')
    lines.append('}')

    return '\n'.join(lines)

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

    content = generate_matmul_gappa(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
