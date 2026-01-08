#!/usr/bin/env python3
import sys
import argparse
from fpcodegen import generate_tuple_type

def generate_serial_sum_fz(n, interval_min=-1, interval_max=1, precision=64):
    """Generate Fuzzi serial sum for n elements"""
    lines = []

    # Include statement
    lines.append(f'#include "../../float_ops/addfp{precision}.fz"')

    # Function signature with nested tuple parameter
    lines.append('function serial_sum')
    tuple_type = generate_tuple_type(n)
    lines.append(f'(a :')
    lines.append(tuple_type + ')')
    lines.append('{')

    # Tuple unpacking: let (A_0, as1) = a; let (A_1, as2) = as1; ...
    for i in range(n-1):
        if i == 0:
            lines.append(f'let (A_{i}, as{i+1}) = a;')
        elif i < n-2:
            lines.append(f'let (A_{i}, as{i+1})= as{i};')
        else:
            lines.append(f'let (A_{i}, A_{i+1})= as{i};')

    # Sequential addition operations
    for i in range(1, n-1):
        if i == 1:
            lines.append(f"A_0_{i}' = addfp{precision} (| A_0 , A_{i} |);")
        else:
            lines.append(f"A_0_{i}' = addfp{precision} (| A_0_{i-1} , A_{i} |);")
        lines.append(f'let A_0_{i}=A_0_{i}\';')

    # Return final result
    lines.append(f'addfp{precision} (|A_0_{n-2} , A_{n-1}|)')
    lines.append('}')

    # Interval annotations - all on one line
    call_line = f'serial_sum'
    for _ in range(n):
        call_line += f'[{interval_min}, {interval_max}]'
    lines.append(call_line)

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for serial sum of n elements'
    )
    parser.add_argument('n', type=int,
                       help='Number of elements to sum')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=-1,
                       help='Minimum interval bound (default: -1)')
    parser.add_argument('--interval-max', type=float, default=1,
                       help='Maximum interval bound (default: 1)')
    return parser.parse_args()

def main():
    args = parse_args()

    content = generate_serial_sum_fz(args.n, args.interval_min, args.interval_max)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
            f.write('\n')
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
