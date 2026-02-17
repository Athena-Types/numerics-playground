#!/usr/bin/env python3
"""
Generate line plots comparing NegFuzz with Gappa and FPTaylor on large benchmarks.

Usage:
    python generate_large_plots.py 2026-02-05
    python generate_large_plots.py 2026-02-05 --output-dir ./figures
"""

import argparse
import csv
import re
import sys
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import pandas as pd
import seaborn as sns

# Tool configuration: (csv_key, display_name, color, marker)
TOOL_CONFIG = [
    ('negfuzz', 'NegFuzz', '#1f77b4', 'o'),
    ('factor', 'NegFuzz (factor)', '#2ca02c', 's'),
    ('gappa', 'Gappa', '#ff7f0e', '^'),
    ('fptaylor', 'FPTaylor', '#d62728', 'D'),
    ('satire', 'SATIRE', '#9467bd', 'v'),
]
TOOL_KEYS = [t[0] for t in TOOL_CONFIG]
TOOL_NAMES = [t[1] for t in TOOL_CONFIG]
COLORS = {t[1]: t[2] for t in TOOL_CONFIG}
MARKERS = {t[1]: t[3] for t in TOOL_CONFIG}

FAMILIES = {'horner': 'Horner Polynomial', 'matmul': 'Matrix Multiplication', 'serialsum': 'Serial Summation'}

# CSV column mappings
PRECISION_COLS = {'negfuzz': 'pre-abs', 'factor': 'pre-abs-factor', 'gappa': 'gappa-abs', 'fptaylor': 'fptaylor-abs', 'satire': 'satire-abs-15_25'}
TIMING_COLS = {'negfuzz': 'numfuzz', 'factor': 'numfuzz-factor', 'gappa': 'gappa-abs', 'fptaylor': 'fptaylor-abs', 'satire': 'satire-15_25'}
STATUS_COLS = {'negfuzz': 'numfuzz-status', 'factor': 'numfuzz-factor-status', 'gappa': 'gappa-abs-status', 'fptaylor': 'fptaylor-status', 'satire': 'satire-15_25-status'}


def parse_float(s):
    """Parse string to float, returning None if empty/invalid."""
    try:
        return float(s) if s and s.strip() else None
    except ValueError:
        return None


def extract_family_param(name):
    """Extract (family, param) from benchmark name, e.g., 'large/horner/Horner128' -> ('horner', 128)."""
    if not name.startswith('large/'):
        return None, None
    match = re.search(r'(\d+)$', name)
    if not match:
        return None, None
    param = int(match.group(1))
    name_lower = name.lower()
    for family in ['horner', 'matmul', 'poly']:
        if family in name_lower:
            return family, param
    if 'serialsum' in name_lower or 'serial_sum' in name_lower:
        return 'serialsum', param
    return None, None


def collect_data(results, timings, exclude=None):
    """Collect benchmark data as a DataFrame."""
    exclude = exclude or set()
    rows = []
    
    # Index timings by (family, param) for status lookup
    timing_index = {}
    for row in timings:
        family, param = extract_family_param(row['benchmark'])
        if family and family not in exclude:
            timing_index[(family, param)] = row
    
    for row in results:
        family, param = extract_family_param(row['benchmark'])
        if not family or family in exclude:
            continue
        timing_row = timing_index.get((family, param), {})
        for key, name, _, _ in TOOL_CONFIG:
            status = timing_row.get(STATUS_COLS[key], '')
            rows.append({'family': family, 'param': param, 'tool': name, 'metric': 'precision',
                         'value': parse_float(row.get(PRECISION_COLS[key])), 'status': status})
            rows.append({'family': family, 'param': param, 'tool': name, 'metric': 'timing',
                         'value': parse_float(timing_row.get(TIMING_COLS[key])), 'status': status})
    
    return pd.DataFrame(rows)


def add_timeout_markers(ax, df_subset):
    """Add markers at top edge for timed-out or missing data points."""
    for tool in TOOL_NAMES:
        if tool == 'NegFuzz (factor)':
            continue
        tool_data = df_subset[df_subset['tool'] == tool]
        missing = tool_data[(tool_data['status'] == 'timeout') | (tool_data['value'].isna())]['param'].values
        if len(missing):
            ax.plot(missing, [1.0] * len(missing), linestyle='none', marker=MARKERS[tool],
                    color=COLORS[tool], markersize=6, clip_on=False, zorder=10,
                    transform=ax.get_xaxis_transform(), label='_')


def setup_axes(ax, ylabel, title=None):
    """Configure axes for log-log plot."""
    ax.set_xlabel('Parameter (N)', fontsize=14)
    ax.set_ylabel(ylabel, fontsize=14)
    ax.tick_params(axis='both', labelsize=13)
    if title:
        ax.set_title(title, fontsize=15)
    ax.set_xscale('log', base=2)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)


def plot_lines(ax, df_subset):
    """Plot lines with seaborn."""
    sns.lineplot(data=df_subset, x='param', y='value', hue='tool', style='tool',
                 markers=MARKERS, palette=COLORS, dashes=False, ax=ax, markersize=6, legend=False)


def make_legend_handles():
    """Create manual legend handles."""
    return [Line2D([0], [0], color=COLORS[t], marker=MARKERS[t], linewidth=2, markersize=6, label=t)
            for t in TOOL_NAMES]


def create_plots(df, output_dir):
    """Create all plots."""
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True)
    
    for family in df['family'].unique():
        title = FAMILIES.get(family, family)
        for metric, ylabel, suffix in [('precision', 'Absolute Error Bound', 'precision'),
                                        ('timing', 'Execution Time (seconds)', 'timing')]:
            df_subset = df[(df['family'] == family) & (df['metric'] == metric)]
            fig, ax = plt.subplots(figsize=(8, 5))
            plot_lines(ax, df_subset)
            setup_axes(ax, ylabel, f'{title} - {suffix.title()}')
            add_timeout_markers(ax, df_subset)
            ax.legend(handles=make_legend_handles(), loc='best', fontsize=13)
            plt.tight_layout()
            plt.savefig(output_dir / f'{family}_{suffix}.pdf', bbox_inches='tight')
            plt.savefig(output_dir / f'{family}_{suffix}.png', dpi=150, bbox_inches='tight')
            plt.close()
        print(f"Created plots for {family}", file=sys.stderr)
    
    # Combined figure
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    for col, family in enumerate(['horner', 'matmul', 'serialsum']):
        if family not in df['family'].values:
            continue
        for row, (metric, ylabel) in enumerate([('precision', 'Absolute Error Bound'), ('timing', 'Execution Time (s)')]):
            df_subset = df[(df['family'] == family) & (df['metric'] == metric)]
            ax = axes[row, col]
            plot_lines(ax, df_subset)
            setup_axes(ax, ylabel, FAMILIES[family] if row == 0 else None)
            add_timeout_markers(ax, df_subset)
    
    fig.legend(handles=make_legend_handles(), loc='lower center', ncol=5, fontsize=13, bbox_to_anchor=(0.5, -0.02))
    plt.tight_layout(rect=[0, 0.05, 1, 1])
    plt.savefig(output_dir / 'large_benchmarks_combined.pdf', bbox_inches='tight')
    plt.savefig(output_dir / 'large_benchmarks_combined.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Created combined plot", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description='Generate line plots for large benchmark scaling')
    parser.add_argument('date', help='Date string for CSV files (e.g., 2026-02-05)')
    parser.add_argument('--output-dir', '-o', default='.', help='Output directory for plots')
    parser.add_argument('--dir', '-d', default='.', help='Directory containing CSV files')
    args = parser.parse_args()
    
    base_dir = Path(args.dir)
    results_file, timings_file = base_dir / f'results-{args.date}.csv', base_dir / f'timings-{args.date}.csv'
    
    for f in [results_file, timings_file]:
        if not f.exists():
            sys.exit(f"Error: {f} not found")
    
    with open(results_file) as f:
        results = list(csv.DictReader(f))
    with open(timings_file) as f:
        timings = list(csv.DictReader(f))
    
    create_plots(collect_data(results, timings, exclude={'poly'}), args.output_dir)
    print(f"Plots saved to {args.output_dir}", file=sys.stderr)


if __name__ == '__main__':
    main()
