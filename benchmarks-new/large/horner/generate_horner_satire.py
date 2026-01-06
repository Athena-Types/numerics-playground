#!/usr/bin/env python3
import sys

def generate_horner_satire(n):
    """Generate Horner polynomial file in the text format for degree n"""
    lines = []

    # INPUTS section
    lines.append('INPUTS {')
    lines.append('         x fl64 : (-1.0, 1.0) ;')

    # Add a0 to aN
    for i in range(n + 1):
        lines.append(f'         a{i} fl64 : (-1.0, 1.0) ;')

    lines.append('}')

    # OUTPUTS section
    lines.append('OUTPUTS {')
    lines.append('         Z_0 ;')
    lines.append('}')

    # EXPRS section
    lines.append('EXPRS {')

    # Generate Z_1 through Z_0
    # Z_1 = (aN * x + a(N-1))
    lines.append(f'        Z_1 rnd64 = (a{n}*x + a{n-1}) ;')

    # Z_i = (Z_(i-1) * x + a(N-i)) for i from 2 to N-1
    for i in range(2, n):
        lines.append(f'        Z_{i} rnd64 = (Z_{i-1}*x + a{n-i}) ;')

    # Final: Z_0 = (Z_(N-1) * x + a0)
    lines.append(f'        Z_0 rnd64 = (Z_{n-1}*x + a0) ;')

    lines.append('}')

    return '\n'.join(lines)

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_horner_satire.py <n> [output_file]")
        print("Example: python generate_horner_satire.py 2 horner2.txt")
        sys.exit(1)

    n = int(sys.argv[1])

    if n < 2:
        print("Error: n must be at least 2")
        sys.exit(1)

    content = generate_horner_satire(n)

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

