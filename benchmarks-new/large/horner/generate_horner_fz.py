#!/usr/bin/env python3
import sys

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

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_horner_fz.py <n> [output_file]")
        print("Example: python generate_horner_fz.py 5 horner5.fz")
        sys.exit(1)

    n = int(sys.argv[1])
    content = generate_horner_fz(n)

    if len(sys.argv) >= 3:
        # Write to specified file
        output_file = sys.argv[2]
        with open(output_file, 'w') as f:
            f.write(content)
        print(f"Generated {output_file}")
    else:
        # Print to stdout
        print(content)

if __name__ == '__main__':
    main()

