#!/usr/bin/env python3
"""
Generate LaTeX tables comparing NegFuzz with Gappa and FPTaylor on small benchmarks.

Usage:
    python generate_tables.py 2026-02-05
    python generate_tables.py 2026-02-05 --output small-benchmarks-tables.tex
"""

import argparse
import csv
import math
import sys
from pathlib import Path


def load_csv(filepath):
    """Load CSV file and return list of dicts."""
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)


def parse_float(s):
    """Parse a string to float, returning None if empty or invalid."""
    if s is None or s.strip() == '':
        return None
    try:
        return float(s)
    except ValueError:
        return None


def format_sci(val, precision=2):
    """Format a number in scientific notation like 2.67e-12."""
    if val is None:
        return '---'
    exp = math.floor(math.log10(abs(val)))
    mantissa = val / (10 ** exp)
    return f"{mantissa:.{precision}f}e{exp:+d}".replace('e+', 'e').replace('e-0', 'e-').replace('e0', 'e')


def format_ratio(ratio, precision=1):
    """Format a ratio like (2.0×) or (1.5e9×)."""
    if ratio is None:
        return '---'
    if ratio >= 1e6:
        exp = math.floor(math.log10(ratio))
        mantissa = ratio / (10 ** exp)
        return f"({mantissa:.1f}e{exp}$\\times$)"
    elif ratio >= 10:
        return f"({ratio:.0f}$\\times$)"
    else:
        return f"({ratio:.1f}$\\times$)"


def is_small_benchmark(name):
    """Check if benchmark is a 'small' benchmark (not in large/ directory)."""
    return not name.startswith('large/')


def generate_precision_table(results, standalone=True):
    """Generate LaTeX table for precision comparison."""
    lines = []
    
    if standalone:
        lines.append("% =============================================================================")
        lines.append("% TABLE: Precision Comparison (Absolute Error Bounds)")
        lines.append("% =============================================================================")
    
    lines.append("\\begin{table}[htbp]")
    lines.append("\\centering")
    lines.append("\\caption{Absolute error bounds on small benchmarks.")
    lines.append("  Ratios show how many times tighter than NegFuzz (higher is better).")
    lines.append("  }")
    lines.append("\\label{tab:small-precision-abs}")
    lines.append("\\small")
    lines.append("\\begin{tabular}{@{}lcccc@{}}")
    lines.append("\\toprule")
    lines.append("Benchmark & NegFuzz & NegFuzz (factor) & Gappa & FPTaylor \\\\")
    lines.append("\\midrule")
    
    for row in results:
        benchmark = row['benchmark']
        if not is_small_benchmark(benchmark):
            continue
        
        # Parse values
        negfuzz = parse_float(row.get('pre-abs'))
        negfuzz_factor = parse_float(row.get('pre-abs-factor'))
        gappa = parse_float(row.get('gappa-abs'))
        fptaylor = parse_float(row.get('fptaylor-abs'))
        
        if negfuzz is None:
            continue  # Skip if no baseline
        
        # Compute ratios (how many times tighter than NegFuzz)
        ratio_negfuzz = 1.0
        ratio_factor = negfuzz / negfuzz_factor if negfuzz_factor else None
        ratio_gappa = negfuzz / gappa if gappa else None
        ratio_fptaylor = negfuzz / fptaylor if fptaylor else None
        
        # Format cells
        cell_negfuzz = f"{format_sci(negfuzz)} (1.0$\\times$)"
        cell_factor = f"{format_sci(negfuzz_factor)} {format_ratio(ratio_factor)}" if negfuzz_factor else "---"
        cell_gappa = f"{format_sci(gappa)} {format_ratio(ratio_gappa)}" if gappa else "---"
        cell_fptaylor = f"{format_sci(fptaylor)} {format_ratio(ratio_fptaylor)}" if fptaylor else "---"
        
        # Escape underscores in benchmark name
        benchmark_escaped = benchmark.replace('_', '\\_')
        
        lines.append(f"{benchmark_escaped} & {cell_negfuzz} & {cell_factor} & {cell_gappa} & {cell_fptaylor} \\\\")
    
    lines.append("\\bottomrule")
    lines.append("\\end{tabular}")
    lines.append("\\end{table}")
    
    return '\n'.join(lines)


def generate_timing_table(timings, standalone=True):
    """Generate LaTeX table for timing comparison."""
    lines = []
    
    if standalone:
        lines.append("")
        lines.append("% =============================================================================")
        lines.append("% TABLE: Timing Comparison")
        lines.append("% =============================================================================")
    
    lines.append("\\begin{table}[htbp]")
    lines.append("\\centering")
    lines.append("\\caption{Execution time (seconds) on small benchmarks.")
    lines.append("  Ratios show slowdown relative to NegFuzz (lower is better).}")
    lines.append("\\label{tab:small-timing}")
    lines.append("\\small")
    lines.append("\\begin{tabular}{@{}lcccc@{}}")
    lines.append("\\toprule")
    lines.append("Benchmark & NegFuzz & NegFuzz (factor) & Gappa & FPTaylor \\\\")
    lines.append("\\midrule")
    
    # Collect values for geometric mean
    all_negfuzz = []
    all_factor = []
    all_gappa = []
    all_fptaylor = []
    
    for row in timings:
        benchmark = row['benchmark']
        if not is_small_benchmark(benchmark):
            continue
        
        # Parse values
        negfuzz = parse_float(row.get('numfuzz'))
        negfuzz_factor = parse_float(row.get('numfuzz-factor'))
        gappa = parse_float(row.get('gappa-abs'))
        fptaylor = parse_float(row.get('fptaylor-abs'))
        
        if negfuzz is None:
            continue  # Skip if no baseline
        
        # Store for geometric mean
        all_negfuzz.append(negfuzz)
        if negfuzz_factor:
            all_factor.append(negfuzz_factor)
        if gappa:
            all_gappa.append(gappa)
        if fptaylor:
            all_fptaylor.append(fptaylor)
        
        # Compute ratios (slowdown relative to NegFuzz)
        ratio_negfuzz = 1.0
        ratio_factor = negfuzz_factor / negfuzz if negfuzz_factor else None
        ratio_gappa = gappa / negfuzz if gappa else None
        ratio_fptaylor = fptaylor / negfuzz if fptaylor else None
        
        # Format cells
        cell_negfuzz = f"{negfuzz:.4f} (1.0$\\times$)"
        cell_factor = f"{negfuzz_factor:.4f} {format_ratio(ratio_factor)}" if negfuzz_factor else "---"
        cell_gappa = f"{gappa:.4f} {format_ratio(ratio_gappa)}" if gappa else "---"
        cell_fptaylor = f"{fptaylor:.3f} {format_ratio(ratio_fptaylor)}" if fptaylor else "---"
        
        # Escape underscores in benchmark name
        benchmark_escaped = benchmark.replace('_', '\\_')
        
        lines.append(f"{benchmark_escaped} & {cell_negfuzz} & {cell_factor} & {cell_gappa} & {cell_fptaylor} \\\\")
    
    # Compute geometric means
    def geomean(vals):
        if not vals:
            return None
        return math.exp(sum(math.log(v) for v in vals) / len(vals))
    
    geo_negfuzz = geomean(all_negfuzz)
    geo_factor = geomean(all_factor)
    geo_gappa = geomean(all_gappa)
    geo_fptaylor = geomean(all_fptaylor)
    
    # Compute geometric mean ratios
    ratio_geo_factor = geo_factor / geo_negfuzz if geo_factor and geo_negfuzz else None
    ratio_geo_gappa = geo_gappa / geo_negfuzz if geo_gappa and geo_negfuzz else None
    ratio_geo_fptaylor = geo_fptaylor / geo_negfuzz if geo_fptaylor and geo_negfuzz else None
    
    lines.append("\\midrule")
    
    cell_geo_negfuzz = f"{geo_negfuzz:.4f} (1.0$\\times$)"
    cell_geo_factor = f"{geo_factor:.4f} {format_ratio(ratio_geo_factor)}" if geo_factor else "---"
    cell_geo_gappa = f"{geo_gappa:.4f} {format_ratio(ratio_geo_gappa)}" if geo_gappa else "---"
    cell_geo_fptaylor = f"{geo_fptaylor:.3f} {format_ratio(ratio_geo_fptaylor)}" if geo_fptaylor else "---"
    
    lines.append(f"\\textbf{{Geo.\\ mean}} & {cell_geo_negfuzz} & {cell_geo_factor} & {cell_geo_gappa} & {cell_geo_fptaylor} \\\\")
    
    lines.append("\\bottomrule")
    lines.append("\\end{tabular}")
    lines.append("\\end{table}")
    
    return '\n'.join(lines)

def main():
    parser = argparse.ArgumentParser(
        description='Generate LaTeX tables from benchmark results'
    )
    parser.add_argument('date', help='Date string for CSV files (e.g., 2026-02-05)')
    parser.add_argument('--output', '-o', default=None,
                        help='Output file (default: stdout)')
    parser.add_argument('--dir', '-d', default='.',
                        help='Directory containing CSV files (default: current dir)')
    
    args = parser.parse_args()
    
    # Construct file paths
    base_dir = Path(args.dir)
    results_file = base_dir / f'results-{args.date}.csv'
    timings_file = base_dir / f'timings-{args.date}.csv'
    
    # Check files exist
    if not results_file.exists():
        print(f"Error: Results file not found: {results_file}", file=sys.stderr)
        sys.exit(1)
    if not timings_file.exists():
        print(f"Error: Timings file not found: {timings_file}", file=sys.stderr)
        sys.exit(1)
    
    # Load data
    results = load_csv(results_file)
    timings = load_csv(timings_file)
    
    # Generate tables
    output_lines = []
    output_lines.append(generate_precision_table(results))
    output_lines.append(generate_timing_table(timings))
    
    output = '\n'.join(output_lines)
    
    # Write output
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Wrote tables to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == '__main__':
    main()
