#!/usr/bin/env python3
import sys
import argparse
from fpcodgen import generate_tuple_type, generate_matrix_unpacking_statements, generate_right_nested_structure

def generate_matrix_type(n):
    """Generate nested tuple type for nxn matrix"""
    row_type = generate_tuple_type(n)

    if n == 1:
        return row_type
    elif n == 2:
        return f"({row_type},{row_type})"
    else:
        # Right-nest the rows
        result = row_type
        for i in range(n - 2):
            result = f"({row_type},{result})"
        result = f"({row_type},{result})"
        return result

def generate_mat_mul(n):
    """Generate matrix multiplication function for nxn matrices"""
    lines = []

    # Include
    lines.append(f'#include "dotprod{n}.fz"')
    lines.append('')

    # Function signature
    matrix_type = generate_matrix_type(n)
    lines.append(f'function mat_mul{n}')
    lines.append(f'(A : ![{n}.0]')
    lines.append(f'( {matrix_type} ))')
    lines.append(f'(B : ![{n}.0]')
    lines.append(f'( {matrix_type} ))')
    lines.append('{')

    # Unpack rows of A
    lines.append('// rows of a')
    lines.extend(generate_matrix_unpacking_statements('A', n))

    # Unpack columns of B
    lines.append('// cols of b')
    lines.extend(generate_matrix_unpacking_statements('B', n))

    # Compute all dot products
    lines.append('// cij is the dot product of the ith row of A and the jth column of B')
    lines.append('')

    for j in range(n):  # columns
        for i in range(n):  # rows
            lines.append(f'c{j:02d}_{i:02d} = ((dotprod{n} A{i}) B{j});')

    lines.append('')

    # Comment showing the nested tuple structure (optional)
    # Build the nested structure representation
    elements = []
    for j in range(n):
        row_elements = [f"c{j:02d}_{i:02d}" for i in range(n)]
        elements.append(generate_right_nested_structure(row_elements))
    comment = f"// {generate_right_nested_structure(elements)}"
    lines.append(comment)

    # Return first element
    lines.append('c00_00')
    lines.append('}')

    # Function call with ranges
    call_line = f'mat_mul{n}'
    num_ranges = 2 * n * n
    for _ in range(num_ranges):
        call_line += '[1,2]'
    lines.append(call_line)

    # Add commented line (like in the example)
    second_line = '//'
    for _ in range(num_ranges):
        second_line += '[1,2]'
    lines.append(second_line)

    return '\n'.join(lines)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for matrix multiplication of nxn matrices'
    )
    parser.add_argument('n', type=int,
                       help='Matrix dimension (must be at least 1)')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    return parser.parse_args()

def main():
    args = parse_args()

    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    content = generate_mat_mul(args.n)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(content)
            f.write('\n')
        print(f"Generated {args.output}")
    else:
        print(content)

if __name__ == '__main__':
    main()
