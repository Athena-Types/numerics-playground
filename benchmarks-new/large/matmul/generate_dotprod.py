#!/usr/bin/env python3
import sys
import argparse
import io
from fpcodegen import generate_tuple_type, generate_unpacking_statements

def generate_computation_tree_factor(n, start_idx=0, var_counter=[0], is_top_level=True):
    """Generate the nested factor/addfp64 computation tree
    Base case (n=2): returns complete computation: lb cN = factor |mul, mul| in addfp64 cN
    Recursive case (n>2):
      - If top level: returns just factor |<left>, <right>|
      - If not top level: returns lb cN = factor |<left>, <right>| in addfp64 cN
    """
    if n == 1:
        return f"mulfp64 (a{start_idx}, b{start_idx})"
    elif n == 2:
        # Base case: creates a complete monadic computation
        var_num = var_counter[0]
        var_counter[0] += 1
        left = f"mulfp64 (a{start_idx}, b{start_idx})"
        right = f"mulfp64 (a{start_idx + 1}, b{start_idx + 1})"
        return f"lb c{var_num} = factor |{left}, {right}| in addfp64 c{var_num}"
    else:
        # Recursive case
        mid = n // 2
        # Subtrees are NOT top level
        left = generate_computation_tree_factor(mid, start_idx, var_counter, is_top_level=False)
        right = generate_computation_tree_factor(n - mid, start_idx + mid, var_counter, is_top_level=False)

        factor_expr = f"factor |{left}, {right}|"

        if is_top_level:
            # Top level: just return the factor expression
            return factor_expr
        else:
            # Not top level: wrap with lb cN = ... in addfp64 cN
            var_num = var_counter[0]
            var_counter[0] += 1
            return f"lb c{var_num} = {factor_expr} in addfp64 c{var_num}"

def generate_dotprod_factor(f, n):
    """Generate dot product function for n elements (with factor)"""

    # Includes
    f.write('#include "../../float_ops/addfp64.fz"\n')
    f.write('#include "../../float_ops/mulfp64.fz"\n')
    f.write('\n')

    # Function signature
    tuple_type = generate_tuple_type(n)
    f.write(f'function dotprod{n}\n')
    f.write(f'(a : {tuple_type})\n')
    f.write(f'(b : {tuple_type})\n')
    f.write('{\n')

    # Unpacking for a
    for line in generate_unpacking_statements('a', n):
        f.write(line + '\n')

    # Unpacking for b
    for line in generate_unpacking_statements('b', n):
        f.write(line + '\n')

    # Blank line
    if n > 1:
        f.write('\n')

    # Computation tree
    var_counter = [0]
    comp_tree = generate_computation_tree_factor(n, 0, var_counter, is_top_level=True)

    # Wrap the entire tree with lb res = ... in / addfp64 res
    f.write(f'lb res = {comp_tree} in\n')
    f.write('addfp64 res\n')
    f.write('}\n')

def generate_dotprod(f, n):
    """Generate dot product function for n elements (no factor)"""

    # Includes
    f.write('#include "../../float_ops/addfp64.fz"\n')
    f.write('#include "../../float_ops/mulfp64.fz"\n')
    f.write('\n')

    # Function signature
    tuple_type = generate_tuple_type(n)
    f.write(f'function dotprod{n}\n')
    f.write(f'(a : {tuple_type})\n')
    f.write(f'(b : {tuple_type})\n')
    f.write('{\n')

    # Unpacking for a
    for line in generate_unpacking_statements('a', n):
        f.write(line + '\n')

    # Unpacking for b
    for line in generate_unpacking_statements('b', n):
        f.write(line + '\n')

    for i in range(0,n):
        f.write(f'lb c{i} = mulfp64(a{i}, b{i}) in \n')

    f.write(f'lb s{1} = addfp64<c0, c1> in \n')
    for i in range(2,n-1):
        f.write(f'lb s{i} = addfp64<c{i}, s{i-1}> in \n')
    f.write(f'addfp64<c{n-1}, s{n-2}>\n')
    f.write('}\n')

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for dot product of n elements'
    )
    parser.add_argument('n', type=int,
                       help='Vector dimension (must be at least 1)')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--factor', action='store_true', 
                        help='Whether to use the factor primitive')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    if args.output:
        with open(args.output, 'w') as f:
            if args.factor:
                generate_dotprod_factor(f, args.n)
            else:
                generate_dotprod(f, args.n)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        if args.factor:
            generate_dotprod_factor(buf, args.n)
        else:
            generate_dotprod(buf, args.n)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()

