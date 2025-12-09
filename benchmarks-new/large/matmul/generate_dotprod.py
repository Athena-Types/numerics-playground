#!/usr/bin/env python3
import sys

def generate_tuple_type(n):
    """Generate nested tuple type for n elements: (num,(num,(num,num)))"""
    if n == 1:
        return "num"
    elif n == 2:
        return "(num,num)"
    else:
        result = "num"
        for i in range(n - 2):
            result = f"(num,{result})"
        result = f"(num,{result})"
        return result

def generate_unpacking(var_name, n):
    """Generate unpacking statements for nested tuples"""
    lines = []
    if n == 1:
        return []

    for i in range(n - 1):
        if i < n - 2:
            lines.append(f"lp ({var_name}{i}, {var_name}s{i+1}) = {var_name if i == 0 else var_name + 's' + str(i)} in")
        else:
            lines.append(f"lp ({var_name}{i}, {var_name}{i+1}) = {var_name}s{i} in")

    return lines

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
    for line in generate_unpacking('a', n):
        lines.append(line)

    # Unpacking for b
    for line in generate_unpacking('b', n):
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

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_dotprod.py <n> [output_file]")
        print("Example: python generate_dotprod.py 4 dotprod4.fz")
        sys.exit(1)

    n = int(sys.argv[1])

    if n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    content = generate_dotprod(n)

    if len(sys.argv) >= 3:
        # Write to specified file
        output_file = sys.argv[2]
        with open(output_file, 'w') as f:
            f.write(content)
            f.write('\n')
        print(f"Generated {output_file}")
    else:
        # Print to stdout
        print(content)

if __name__ == '__main__':
    main()

