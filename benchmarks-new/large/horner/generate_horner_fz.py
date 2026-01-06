#!/usr/bin/env python3
import sys
import argparse

def generate_horner_fz(n):
    """Generate Horner polynomial file for degree n"""
    lines = []

    # Header
    lines.append('#include "../../float_ops/fma64.fz"')
    lines.append('')

    # Function signature
    lines.append(f'function Horner{n} ')

    # Parameters a0 to aN
    for i in range(n + 1):
        lines.append(f'  (a{i} : num)')

    # x parameter
    lines.append(f'  (x : ![{n}.0]num) ')
    lines.append('{')

    # lcb line
    lines.append("  lcb x' = x in")

    # First lb z0 line
    lines.append(f"  lb z0 = (((FMA64 a{n}) x') a{n-1}) in")

    # Blank line if n > 2
    if n > 2:
        lines.append('')

    # Intermediate lb zi lines
    for i in range(1, n - 1):
        lines.append(f"  lb z{i} = (((FMA64 z{i-1}) x') a{n-i-1}) in")

    # Blank line and final expression
    if n > 2:
        lines.append('')
    lines.append(f"  (((FMA64 z{n-2}) x') a0)")
    lines.append('}')
    lines.append('')

    # Function call
    call_line = f'Horner{n}'
    for _ in range(n + 2):
        call_line += '[-1,1]'
    lines.append(call_line)

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for Horner polynomial of degree n'
    )
    parser.add_argument('n', type=int,
                       help='Polynomial degree')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    return parser.parse_args()

def main():
    args = parse_args()
    content = generate_horner_fz(args.n)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()

