#!/usr/bin/env python3
import sys
import argparse
import io
from fpcodegen import generate_tuple_type, generate_matrix_unpacking_statements, generate_right_nested_structure

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

def generate_mat_mul(f, n):
    """Generate matrix multiplication function for nxn matrices"""

    # Include
    f.write(f'#include "dotprod{n}.fz"\n')
    f.write('\n')

    # Function signature
    matrix_type = generate_matrix_type(n)
    f.write(f'function mat_mul{n}\n')
    f.write(f'(A : ![{n}.0]\n')
    f.write(f'( {matrix_type} ))\n')
    f.write(f'(B : ![{n}.0]\n')
    f.write(f'( {matrix_type} ))\n')
    f.write('{\n')

    # Unpack rows of A
    f.write('// rows of a\n')
    for line in generate_matrix_unpacking_statements('A', n):
        f.write(line + '\n')

    # Unpack columns of B
    f.write('// cols of b\n')
    for line in generate_matrix_unpacking_statements('B', n):
        f.write(line + '\n')

    # Compute all dot products
    f.write('// cij is the dot product of the ith row of A and the jth column of B\n')
    f.write('\n')

    for j in range(n):  # columns
        for i in range(n):  # rows
            f.write(f'c{j:02d}_{i:02d} = ((dotprod{n} A{i}) B{j});\n')

    f.write('\n')

    # Comment showing the nested tuple structure (optional)
    # Build the nested structure representation
    elements = []
    for j in range(n):
        row_elements = [f"c{j:02d}_{i:02d}" for i in range(n)]
        elements.append(generate_right_nested_structure(row_elements))
    comment = f"// {generate_right_nested_structure(elements)}"
    f.write(comment + '\n')

    # Return first element
    f.write('c00_00\n')
    f.write('}\n')

    # Function call with ranges
    call_line = f'mat_mul{n}'
    num_ranges = 2 * n * n
    for _ in range(num_ranges):
        call_line += '[1,2]'
    f.write(call_line + '\n')

    # Add commented line (like in the example)
    second_line = '//'
    for _ in range(num_ranges):
        second_line += '[1,2]'
    f.write(second_line + '\n')

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

    if args.output:
        with open(args.output, 'w') as f:
            generate_mat_mul(f, args.n)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_mat_mul(buf, args.n)
        print(buf.getvalue(), end='')

if __name__ == '__main__':
    main()
