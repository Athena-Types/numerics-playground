#!/usr/bin/env python3
import sys

def generate_horner_gappa(n):
    """Generate Gappa file for Horner polynomial of degree n"""
    lines = []

    # Rounding mode definition
    lines.append('@rnd = float<ieee_64, up>;')

    # R variable definitions (exact computation)
    if n == 2:
        # Special case for n=2
        lines.append(f'r  = (a{n} * x + a{n-1}) * x + a0;')
    else:
        # For n > 2: generate ri variables
        lines.append(f'r{n-1}  = (a{n} * x + a{n-1});')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            lines.append(f'r{i}  = (r{i+1} * x + a{i});')

        lines.append('r   = (r1 * x + a0);')

    # Z variable definitions (rounded computation)
    if n == 2:
        # Special case for n=2
        lines.append(f'z  = rnd(rnd(a{n} * x + a{n-1}) * x + a0);')
    else:
        # For n > 2: generate zi variables
        lines.append(f'z{n-1}  = rnd(a{n} * x + a{n-1});')

        for i in range(n - 2, 0, -1):  # Changed from range(n-2, 1, -1)
            lines.append(f'z{i}  = rnd(z{i+1} * x + a{i});')

        lines.append('z   = rnd(z1 * x + a0);')

    # Blank line and comment
    lines.append('')
    lines.append('# the logical formula that Gappa will try (and succeed) to prove')

    # Logical formula
    lines.append('{ x in [0.1,1000]')

    # Constraints for a0 to aN
    for i in range(n + 1):
        lines.append(f'  /\\ a{i} in [0.1,1000]')

    # Final line
    lines.append('  -> |(z - r) / r| in ? }')

    return '\n'.join(lines)

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_horner_gappa.py <n> [output_file]")
        print("Example: python generate_horner_gappa.py 5 horner5_gappa.txt")
        sys.exit(1)

    n = int(sys.argv[1])
    content = generate_horner_gappa(n)

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

