#!/usr/bin/env python3
import sys
import argparse
import io


def generate_tree_sum_expr(f, terms, depth=0, var_counter=[0]):
    """Generate a binary tree summation expression using factor construct.
    
    Args:
        f: File object to write to
        terms: List of term names to sum (e.g., ['sum_a0_S1', 'S_2', 'S_3', ...])
        depth: Current depth in the tree (for variable naming)
        var_counter: Counter for unique variable names
    
    Returns:
        Expression string for the sum
    """
    if len(terms) == 1:
        return terms[0]
    elif len(terms) == 2:
        # Base case: just add the two terms
        return f"addfp64 (| {terms[0]} , {terms[1]} |)"
    else:
        # Split into two halves and combine with factor
        mid = len(terms) // 2
        left_terms = terms[:mid]
        right_terms = terms[mid:]
        
        # Recursively build left and right subtrees
        left_expr = generate_tree_sum_expr(f, left_terms, depth + 1, var_counter)
        right_expr = generate_tree_sum_expr(f, right_terms, depth + 1, var_counter)
        
        # If either expression is a factor result, bind it and extract with addfp64
        # Factor results are monads containing cartesian pairs, so we extract the pair
        if left_expr.startswith("factor"):
            var_counter[0] += 1
            left_var = f"sum_tree_{depth}_left_{var_counter[0]}"
            f.write(f"  lb {left_var} = {left_expr} in\n")
            left_expr = f"addfp64 ({left_var})"
        
        if right_expr.startswith("factor"):
            var_counter[0] += 1
            right_var = f"sum_tree_{depth}_right_{var_counter[0]}"
            f.write(f"  lb {right_var} = {right_expr} in\n")
            right_expr = f"addfp64 ({right_var})"
        
        # Combine with factor - expects a cartesian pair of monadic expressions
        return f"factor |{left_expr}, {right_expr}|"


def generate_poly_fz(f, n, interval_min=-1, interval_max=1):
    """Generate polynomial evaluation file for degree n using factor construct"""
    
    # Header includes
    f.write('#include "../../float_ops/addfp64.fz"\n')
    f.write('#include "../../float_ops/mulfp64.fz"\n')
    f.write('\n')
    
    # Function signature
    f.write(f'function Poly{n} \n')
    for i in range(n + 1):
        f.write(f'  (a{i} : num)\n')
    f.write(f'  (x : ![{n}.0]num) \n')
    f.write('{\n')
    
    # Extract x from bang type
    f.write("  lcb x' = x in\n")
    
    # Compute powers of x: x^2, x^3, ..., x^n
    if n >= 2:
        f.write(f"  lb x_2 = mulfp64 (x' , x') in\n")
    for i in range(3, n + 1):
        f.write(f"  lb x_{i} = mulfp64 (x' , x_{i-1}) in\n")
    
    # Compute S_i = a_i * x^i for i from n down to 1
    if n >= 1:
        f.write('\n')
    for i in range(n, 0, -1):
        if i == 1:
            f.write(f"  lb S_1 = mulfp64 (a1 , x') in\n")
        else:
            f.write(f"  lb S_{i} = mulfp64 (a{i} , x_{i}) in\n")
    
    # Build summation using factor for binary tree structure
    f.write('\n')
    if n == 0:
        f.write('  a0\n')
    elif n == 1:
        f.write('  addfp64 (| a0 , S_1 |)\n')
    else:
        # Handle a0 specially (it's a num, not a monad)
        # Add a0 to S_1 first to create a monadic term
        f.write("  lb sum_a0_S1 = addfp64 (| a0 , S_1 |) in\n")
        
        # Build list of remaining terms to sum
        terms = ['sum_a0_S1']
        for i in range(2, n + 1):
            terms.append(f'S_{i}')
        
        # Generate binary tree summation expression
        tree_expr = generate_tree_sum_expr(f, terms, 0, [0])
        
        # Write final expression
        if tree_expr.startswith("addfp64"):
            # Simple case: already a complete expression
            f.write(f"  {tree_expr}\n")
        else:
            # Factor expression: bind it and extract with addfp64
            f.write(f"  lb final_sum = {tree_expr} in\n")
            f.write("  addfp64 (final_sum)\n")
    
    f.write('}\n')
    f.write('\n')
    
    # Function call with intervals
    call_line = f'Poly{n}'
    for _ in range(n + 2):
        call_line += f'[{interval_min},{interval_max}]'
    f.write(call_line)


def parse_args():
    parser = argparse.ArgumentParser(
        description='Generate .fz file for polynomial evaluation of degree n'
    )
    parser.add_argument('n', type=int, help='Polynomial degree')
    parser.add_argument('output', nargs='?', type=str, default=None,
                       help='Output file (default: print to stdout)')
    parser.add_argument('--interval-min', type=float, default=-1,
                       help='Minimum interval bound (default: -1)')
    parser.add_argument('--interval-max', type=float, default=1,
                       help='Maximum interval bound (default: 1)')
    return parser.parse_args()


def main():
    args = parse_args()
    
    if args.n < 1:
        print("Error: n must be at least 1")
        sys.exit(1)
    
    if args.output:
        with open(args.output, 'w') as f:
            generate_poly_fz(f, args.n, args.interval_min, args.interval_max)
        print(f"Generated {args.output}")
    else:
        buf = io.StringIO()
        generate_poly_fz(buf, args.n, args.interval_min, args.interval_max)
        print(buf.getvalue(), end='')


if __name__ == '__main__':
    main()
