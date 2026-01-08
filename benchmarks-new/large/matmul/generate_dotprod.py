#!/usr/bin/env python3
import sys
import argparse
from fpcodegen import generate_tuple_type, generate_unpacking_statements

def generate_computation_tree(n, start_idx=0, var_counter=[0], is_top_level=True):
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
        left = generate_computation_tree(mid, start_idx, var_counter, is_top_level=False)
        right = generate_computation_tree(n - mid, start_idx + mid, var_counter, is_top_level=False)

        factor_expr = f"factor |{left}, {right}|"

        if is_top_level:
            # Top level: just return the factor expression
            return factor_expr
        else:
            # Not top level: wrap with lb cN = ... in addfp64 cN
            var_num = var_counter[0]
            var_counter[0] += 1
            return f"lb c{var_num} = {factor_expr} in addfp64 c{var_num}"

def generate_dotprod(n):
    """Generate dot product function for n elements"""
    lines = []

    # Includes
    lines.append('#include "../../float_ops/addfp64.fz"')
    lines.append('#include "../../float_ops/mulfp64.fz"')
    lines.append('')

    # Function signature
    tuple_type = generate_tuple_type(n)
    lines.append(f'function dotprod{n}')
    lines.append(f'(a : {tuple_type})')
    lines.append(f'(b : {tuple_type})')
    lines.append('{')

    # Unpacking for a
    for line in generate_unpacking_statements('a', n):
        lines.append(line)

    # Unpacking for b
    for line in generate_unpacking_statements('b', n):
        lines.append(line)

    # Blank line
    if n > 1:
        lines.append('')

    # Computation tree
    var_counter = [0]
    comp_tree = generate_computation_tree(n, 0, var_counter, is_top_level=True)

    # Wrap the entire tree with lb res = ... in / addfp64 res
    lines.append(f'lb res = {comp_tree} in')
    lines.append('addfp64 res')
    lines.append('}')

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for dot product of n elements'
    )
    parser.add_argument('n', type=int,
                       help='Vector dimension (must be at least 1)')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    content = generate_dotprod(args.n)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
            f.write('\n')
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()

