#!/usr/bin/env python3
"""Shared utilities for code generation scripts."""

def generate_right_nested_structure(elements, separator=","):
    """Generate right-nested structure from a list of elements.

    Examples:
        ['a'] -> 'a'
        ['a', 'b'] -> '(a,b)'
        ['a', 'b', 'c'] -> '(a,(b,c))'
        ['a', 'b', 'c', 'd'] -> '(a,(b,(c,d)))'
    """
    if len(elements) == 1:
        return elements[0]
    elif len(elements) == 2:
        return f"({elements[0]}{separator}{elements[1]})"
    else:
        result = elements[-1]
        for i in range(len(elements) - 2, -1, -1):
            result = f"({elements[i]}{separator}{result})"
        return result


def generate_tuple_type(n, element_type="num"):
    """Generate nested tuple type for n elements.

    Examples:
        n=1: 'num'
        n=2: '(num,num)'
        n=3: '(num,(num,num))'
        n=4: '(num,(num,(num,num)))'
    """
    if n == 1:
        return element_type
    elif n == 2:
        return f"({element_type},{element_type})"
    else:
        result = element_type
        for i in range(n - 2):
            result = f"({element_type},{result})"
        result = f"({element_type},{result})"
        return result


def generate_unpacking_statements(var_name, n, keyword="lp", temp_suffix="s"):
    """Generate unpacking statements for nested tuples.

    Args:
        var_name: Base variable name (e.g., 'a', 'b')
        n: Number of elements to unpack
        keyword: Unpacking keyword ('lp' or 'let')
        temp_suffix: Suffix for temporary variables ('s' or 'S')

    Returns:
        List of unpacking statement strings
    """
    lines = []
    if n == 1:
        return []

    for i in range(n - 1):
        if i < n - 2:
            source = var_name if i == 0 else f"{var_name}{temp_suffix}{i}"
            lines.append(f"{keyword} ({var_name}{i}, {var_name}{temp_suffix}{i+1}) = {source} in")
        else:
            lines.append(f"{keyword} ({var_name}{i}, {var_name}{i+1}) = {var_name}{temp_suffix}{i} in")

    return lines


def generate_matrix_unpacking_statements(var_name, n):
    """Generate unpacking statements for matrix (rows) with 'let' syntax.

    Args:
        var_name: Base variable name (e.g., 'A', 'B')
        n: Matrix dimension

    Returns:
        List of unpacking statement strings
    """
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
