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

def generate_matrix_unpacking(var_name, n):
    """Generate unpacking statements for matrix (rows)"""
    lines = []
    lines.append(f"let [{var_name}'] = {var_name};")

    if n == 1:
        lines.append(f"let {var_name}0 = {var_name}';")
        return lines

    for i in range(n - 1):
        if i == 0:
            lines.append(f"let ({var_name}0, {var_name}S1) = {var_name}';")
        elif i < n - 2:
            lines.append(f"let ({var_name}{i}, {var_name}S{i+1})= {var_name}S{i};")
        else:
            lines.append(f"let ({var_name}{i}, {var_name}{i+1})= {var_name}S{i};")

    return lines

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
    lines.extend(generate_matrix_unpacking('A', n))

    # Unpack columns of B
    lines.append('// cols of b')
    lines.extend(generate_matrix_unpacking('B', n))

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
        elements.append(generate_nested_comment(row_elements))
    comment = f"// {generate_nested_comment(elements)}"
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

def generate_nested_comment(elements):
    """Generate nested tuple comment representation"""
    if len(elements) == 1:
        return elements[0]
    elif len(elements) == 2:
        return f"({elements[0]},{elements[1]})"
    else:
        result = elements[-1]
        for i in range(len(elements) - 2, -1, -1):
            result = f"({elements[i]},{result})"
        return result

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_mat_mul.py <n> [output_file]")
        print("Example: python generate_mat_mul.py 4 mat_mul4.fz")
        sys.exit(1)

    n = int(sys.argv[1])

    if n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)

    content = generate_mat_mul(n)

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
