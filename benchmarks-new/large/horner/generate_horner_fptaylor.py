#!/usr/bin/env python3
import sys

def generate_horner_fptaylor(n):
    """Generate FPTaylor file for Horner polynomial of degree n"""
    lines = []

    # Variables section header
    lines.append('Variables')

    # Add x variable
    lines.append('  float64 x  in [0.1, 1000];')

    # Add a0 to aN variables
    for i in range(n + 1):
        lines.append(f'  float64 a{i} in [0.1, 1000];')

    # Blank line
    lines.append('')

    # Definitions section header
    lines.append('Definitions')

    # Add z1 to z(n-1) definitions
    for i in range(1, n):
        if i == 1:
            # First definition: z1 = rnd64_up(aN * x + a(N-1))
            lines.append(f'  z{i} =rnd64_up(a{n} * x + a{n-1});')
        else:
            # Subsequent definitions: zi = rnd64_up(z(i-1) * x + a(N-i))
            lines.append(f'  z{i} =rnd64_up(z{i-1} * x + a{n-i});')

    # Blank line
    lines.append('')

    # Expressions section header
    lines.append('Expressions')

    # Final expression: HornerN = rnd64_up(z(N-1) * x + a0)
    lines.append(f'  Horner{n} =rnd64_up (z{n-1} * x + a0);')

    return '\n'.join(lines)

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_horner_fptaylor.py <n> [output_file]")
        print("Example: python generate_horner_fptaylor.py 5 horner5_fptaylor.txt")
        sys.exit(1)

    n = int(sys.argv[1])
    content = generate_horner_fptaylor(n)

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

