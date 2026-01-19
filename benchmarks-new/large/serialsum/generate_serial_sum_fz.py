#!/usr/bin/env python3
import sys
import argparse
import io
from fpcodegen import generate_tuple_type

def generate_serial_sum_fz(f, n, interval_min=-1, interval_max=1, precision=64):
    """Generate Fuzzi serial sum for n elements"""

    # Include statement
    f.write(f'#include "../../float_ops/addfp{precision}.fz"\n')

    # Function signature with nested tuple parameter
    f.write('function serial_sum\n')
    tuple_type = generate_tuple_type(n)
    f.write(f'(a :\n')
    f.write(tuple_type + ')\n')
    f.write('{\n')

    # Tuple unpacking: let (A_0, as1) = a; let (A_1, as2) = as1; ...
    for i in range(n-1):
        if i == 0:
            f.write(f'let (A_{i}, as{i+1}) = a;\n')
        elif i < n-2:
            f.write(f'let (A_{i}, as{i+1})= as{i};\n')
        else:
            f.write(f'let (A_{i}, A_{i+1})= as{i};\n')

    # Sequential addition operations
    for i in range(1, n-1):
        if i == 1:
            f.write(f"A_0_{i}' = addfp{precision} (| A_0 , A_{i} |);\n")
        else:
            f.write(f"A_0_{i}' = addfp{precision} (| A_0_{i-1} , A_{i} |);\n")
        f.write(f'let A_0_{i}=A_0_{i}\';\n')

    # Return final result
    f.write(f'addfp{precision} (|A_0_{n-2} , A_{n-1}|)\n')
    f.write('}\n')

    # Interval annotations - all on one line
    call_line = f'serial_sum'
    for _ in range(n):
        call_line += f'[{interval_min}, {interval_max}]'
    f.write(call_line + '\n')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_serial_sum_fz(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_serial_sum_fz(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
