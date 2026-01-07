#!/usr/bin/env python3
import sys
import argparse

def generate_matmul_fptaylor(n, interval_min=-1, interval_max=1):
    """Generate FPTaylor file for full n x n matrix multiplication (all entries computed, error analyzed on c[0][0])"""
    lines = []

    # Variables section header
    lines.append('Variables')

    # Add all elements of matrix A
    for i in range(n):
        for j in range(n):
            lines.append(f'  float64 a{i}{j} in [{interval_min}, {interval_max}];')

    # Add all elements of matrix B
    for i in range(n):
        for j in range(n):
            lines.append(f'  float64 b{i}{j} in [{interval_min}, {interval_max}];')

    # Blank line
    lines.append('')

    # Definitions section header
    lines.append('Definitions')

    # Compute all n*n entries c[i][j] in row-major order
    for i in range(n):
        for j in range(n):
            # For each entry c[i][j], compute dot product of row i of A and column j of B
            if n == 1:
                # Special case: first product
                lines.append(f'  c{i}{j} = rnd64_up(a{i}0 * b0{j});')
            else:
                # Compute products: p{i}{j}_k = a[i][k] * b[k][j]
                for k in range(n):
                    if k == 0:
                        lines.append(f'  p{i}{j}_{k} = rnd64_up(a{i}{k} * b{k}{j});')
                    else:
                        lines.append(f'  p{i}{j}_{k} = rnd64_up(a{i}{k} * b{k}{j});')

                # Compute intermediate sums: s{i}{j}_1 = p0 + p1, s{i}{j}_2 = s1 + p2, etc.
                for k in range(1, n):
                    if k == 1:
                        lines.append(f'  s{i}{j}_{k} = rnd64_up(p{i}{j}_0 + p{i}{j}_{k});')
                    else:
                        lines.append(f'  s{i}{j}_{k} = rnd64_up(s{i}{j}_{k-1} + p{i}{j}_{k});')

                # Final entry: c{i}{j} = last sum
                lines.append(f'  c{i}{j} = s{i}{j}_{n-1};')

    # Blank line
    lines.append('')

    # Expressions section header
    lines.append('Expressions')

    # Only analyze error on c[0][0], but all entries were computed
    lines.append(f'  matmul{n} = c00;')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fptaylor file for n x n matrix multiplication'
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

    content = generate_matmul_fptaylor(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
