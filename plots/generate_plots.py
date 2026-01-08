#!/usr/bin/env python3

import argparse
import glob
import json
import math
import os
import re
import subprocess
from datetime import datetime

import numpy as np
import pandas as pd
import seaborn as sns
import tqdm


def parse_bound(bnd: str) -> float:
    """
    Parse bound strings (handles "b" notation for binary exponents).
    
    Examples:
        parse_bound("0.5") -> 0.5
        parse_bound("136015914505992771b-53") -> 136015914505992771 * 2^-53
        parse_bound("[1.5]") -> 1.5
    """
    bnd = bnd.strip("[]")
    bnd = bnd.strip()

    if "b" in bnd:
        mantissa = int(bnd.split("b")[0])
        exp = int(bnd.split("b")[1])
        return mantissa * (2 ** exp)
    else:
        return float(bnd)


def parse_gappa_out(filename: str):
    """Parse gappa output files and return (lb, ub) tuple or None."""
    try:
        with open(filename, "r") as f:
            file = f.read()
        if "Error" in file:
            return None

        # Fix: use raw string for regex to avoid escape sequence warning
        file = re.sub(r"\{.*?\}", "", file).strip()
        bounds = [parse_bound(x.strip()) for x in file.split("in")[1].strip().split(",")]

        lb = abs(float(bounds[0]))
        ub = abs(float(bounds[1]))
        return (lb, ub)

    except (FileNotFoundError, IndexError, ValueError, KeyError) as e:
        return None


def parse_fptaylor_out(filename: str):
    """
    Parse FPTaylor output files and return (abs_error, rel_error) tuple or None.
    
    Examples of FPTaylor output format:
        Absolute error: 4.441e-15
        Relative error: 1.011e-15
    """
    try:
        with open(filename, "r") as f:
            file = f.read()
            abs_error = None
            rel_error = None
            for line in file.split("\n"):
                if "Absolute error" in line:
                    try:
                        abs_error = float(line.split(":")[1].split()[0])
                    except (ValueError, IndexError):
                        print(f"Warning: Could not parse abs error from: {line}")
                if "Relative error" in line:
                    try:
                        rel_error = float(line.split(":")[1].split()[0])
                    except (ValueError, IndexError):
                        pass
        return (abs_error, rel_error)
    except (FileNotFoundError, ValueError) as e:
        return None


def parse_satire_out(filename: str):
    """
    Parse Satire output files and return (abs_error, None) tuple or None.
    
    Satire only provides absolute error bounds, not relative error.
    
    Examples of Satire output format:
        INPUT_FILE : <path>
        
        //-------------------------------------
        VAR : <variable_name>
        ABSOLUTE_ERROR : 1.4432899320127035e-15
        REAL_INTERVAL : [-4, 4.0]
        FP_INTERVAL : [-4.000000000000002, 4.000000000000002]
        //-------------------------------------
    """
    try:
        with open(filename, "r") as f:
            file = f.read()
            abs_error = None
            for line in file.split("\n"):
                if "ABSOLUTE_ERROR" in line:
                    try:
                        # Extract value after "ABSOLUTE_ERROR : "
                        abs_error = float(line.split(":")[1].strip())
                    except (ValueError, IndexError):
                        print(f"Warning: Could not parse absolute error from: {line}")
        return (abs_error, None) if abs_error is not None else None
    except (FileNotFoundError, ValueError) as e:
        return None


def timing_out(timing_file: str):
    """
    Extract timing data from JSON files.
    
    Expected JSON format:
        {
            "results": [
                {
                    "median": 0.12345
                }
            ]
        }
    """
    try:
        with open(timing_file) as f:
            data = json.load(f)
            return data["results"][0]["median"]
    except (FileNotFoundError, json.JSONDecodeError, KeyError, IndexError):
        return None


def sample_post(fname: str):
    """
    Sample post-hoc error bounds using subprocess calls.
    
    Returns (post, post_bnd, post_bnd_abs) tuple.
    """
    try:
        # Sample a value from the benchmark
        sample = subprocess.run(
            f"python ../benchmarks-new/{fname}.py",
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        post = float(sample.stdout.strip())

        # Compute post-hoc bound
        sampled_bnd = subprocess.run(
            f"../fuzzrs/target/release/fuzzrs --input ../benchmarks-new/{fname}.fz --post={post}",
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        post_bnd = float(sampled_bnd.stdout.split("\n")[2].split(":")[1].strip())
        post_bnd_abs = max(
            abs(post) * (math.exp(post_bnd) - 1),
            abs(post) * (1 - math.exp(-post_bnd))
        )
        return (post, post_bnd, post_bnd_abs)
    except (subprocess.CalledProcessError, ValueError, IndexError, FileNotFoundError) as e:
        print(f"Warning: Failed to sample post-hoc bounds for {fname}: {e}")
        return None


def process_benchmark(base_name: str, precision: str, rounding_mode: str, benchmarks_dir: str = "../benchmarks-new"):
    """
    Process a single benchmark and return results and timing dictionaries.
    
    Args:
        base_name: Base benchmark name (e.g., 'kepler0' or 'large/horner/Horner4') used for .fz files
        precision: Precision string (e.g., 'binary64')
        rounding_mode: Rounding mode string (e.g., 'toPositive')
        benchmarks_dir: Directory containing benchmark files
    
    Returns (result_dict, timing_dict, post_samples_list)
    """
    result = {"benchmark": base_name}
    timing = {"benchmark": base_name}

    # Check if this is a large benchmark (has path prefix)
    is_large_benchmark = "large" in base_name
    
    # Construct full name from components for FPTaylor and Gappa files
    # Large benchmarks don't use precision/rounding mode in filenames
    if is_large_benchmark:
        full_name = base_name
    else:
        full_name = f"{base_name}-{precision}-{rounding_mode}"

    # Parse fz output files (use base_name since .fz files don't include rounding mode in filename)
    # TODO: NegFuzz currently ignores precision and rounding_mode parameters - propagate these to NegFuzz processing
    try:
        with open(f"{benchmarks_dir}/{base_name}.fz.out") as f:
            lines = str(f.read()).split("\n")
            pre_rel = lines[0].split(":")[1].strip().replace("Some", "").replace("(", "").replace(")", "")
            pre_abs = lines[1].split(":")[1].strip()
        result["pre-rel"] = pre_rel if pre_rel else None
        result["pre-abs"] = pre_abs if pre_abs else None
    except (FileNotFoundError, IndexError) as e:
        result["pre-rel"] = None
        result["pre-abs"] = None

    try:
        with open(f"{benchmarks_dir}/{base_name}-factor.fz.out") as f:
            lines = str(f.read()).split("\n")
            pre_rel_factor = lines[0].split(":")[1].strip().replace("Some", "").replace("(", "").replace(")", "")
            pre_abs_factor = lines[1].split(":")[1].strip()
        result["pre-rel-factor"] = pre_rel_factor if pre_rel_factor else None
        result["pre-abs-factor"] = pre_abs_factor if pre_abs_factor else None
    except (FileNotFoundError, IndexError) as e:
        result["pre-rel-factor"] = None
        result["pre-abs-factor"] = None

    # Parse gappa outputs (use full_name constructed from precision and rounding_mode)
    g_abs = parse_gappa_out(f"{benchmarks_dir}/{full_name}-abs.g.out")
    if g_abs:
        g_abs = max(*g_abs)
    else:
        g_abs = None
    result["gappa-abs"] = g_abs

    g_rel = parse_gappa_out(f"{benchmarks_dir}/{full_name}-rel.g.out")
    if g_rel:
        g_rel = max(*g_rel)
    else:
        g_rel = None
    result["gappa-rel"] = g_rel

    # Parse FPTaylor outputs (use full_name constructed from precision and rounding_mode)
    fptaylor_result = parse_fptaylor_out(f"{benchmarks_dir}/{full_name}.fptaylor.out")
    if fptaylor_result:
        fptaylor_abs, fptaylor_rel = fptaylor_result
    else:
        fptaylor_abs, fptaylor_rel = None, None
    result["fptaylor-abs"] = fptaylor_abs
    result["fptaylor-rel"] = fptaylor_rel

    # Parse Satire outputs (for large benchmarks)
    satire_configs = ["noAbs", "10_20", "15_25", "20_40"]
    for config in satire_configs:
        satire_filename = f"{benchmarks_dir}/{base_name}_sat_abs-serial_{config}.out"
        satire_result = parse_satire_out(satire_filename)
        if satire_result:
            result[f"satire-abs-{config}"] = satire_result[0]  # abs_error
        else:
            result[f"satire-abs-{config}"] = None

    # Parse timing files
    timing["gappa-abs"] = timing_out(f"{benchmarks_dir}/{full_name}-abs.g.json")
    timing["gappa-rel"] = timing_out(f"{benchmarks_dir}/{full_name}-rel.g.json")
    timing["numfuzz"] = timing_out(f"{benchmarks_dir}/{base_name}.fz.json")
    timing["numfuzz-factor"] = timing_out(f"{benchmarks_dir}/{base_name}-factor.fz.json")
    timing["fptaylor-rel"] = timing_out(f"{benchmarks_dir}/{full_name}-rel.fptaylor.json")
    timing["fptaylor-abs"] = timing_out(f"{benchmarks_dir}/{full_name}-abs.fptaylor.json")

    return result, timing


def generate_pdfs(post_samples: dict, results_transpose: pd.DataFrame, output_dir: str = "."):
    """Generate PDF plots for each benchmark."""
    for fname in post_samples.keys():
        samples_df = pd.DataFrame(
            post_samples[fname],
            columns=["result", "error-bound-rel", "error-bound-abs"]
        )

        # Get reference bounds (matching notebook access pattern)
        gappa_abs = results_transpose[fname]["gappa-abs"]
        gappa_rel = results_transpose[fname]["gappa-rel"]
        fptaylor_abs = results_transpose[fname]["fptaylor-abs"]
        numfuzz_abs = results_transpose[fname]["pre-abs-factor"]

        # Create plot
        g = sns.relplot(samples_df, x="result", y="error-bound-abs")
        g.set_axis_labels(
            f"Output distribution for {fname} (n={len(samples_df)})",
            "PairFuzz a posterori absolute error bound"
        )
        ax = g.ax

        # Add reference lines (only if values are not None/NaN)
        if gappa_abs is not None and not pd.isna(gappa_abs):
            ax.axhline(y=gappa_abs, linestyle="--", color="red", linewidth=1, label="Gappa")
        if fptaylor_abs is not None and not pd.isna(fptaylor_abs):
            ax.axhline(y=fptaylor_abs, linestyle=":", color="green", linewidth=1, label="FPTaylor")

        ax.legend()
        g.set(yscale="log")

        # Save PDF
        output_path = os.path.join(output_dir, f"{fname}.pdf")
        g.savefig(output_path)
        print(f"Saved PDF: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Generate PDFs and CSV files from benchmark results")
    parser.add_argument(
        "--date",
        type=str,
        default=None,
        help="Date stamp for output files (YYYY-MM-DD format). Defaults to today's date."
    )
    parser.add_argument(
        "--benchmarks-dir",
        type=str,
        default="../benchmarks-new",
        help="Directory containing benchmark files (default: ../benchmarks-new)"
    )
    parser.add_argument(
        "--samples",
        type=int,
        default=10000,
        help="Number of post-hoc samples per benchmark (default: 10000)"
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default=".",
        help="Output directory for PDFs and CSVs (default: current directory)"
    )
    parser.add_argument(
        "--skip-sampling",
        action="store_true",
        help="Skip the time-consuming post-hoc sampling step"
    )

    args = parser.parse_args()

    # Set date
    if args.date:
        date_str = args.date
    else:
        date_str = datetime.now().strftime("%Y-%m-%d")

    # Find small benchmarks (in root directory)
    small_benchmarks = glob.glob(f"{args.benchmarks_dir}/*.fz")
    small_base_names = [os.path.basename(x).replace(".fz", "") for x in small_benchmarks if "factor" not in x and "shoelace" not in x]
    
    # Find large benchmarks (in subdirectories: large/horner/, large/matmul/, large/serialsum/, large/poly/)
    large_benchmark_types = ["horner", "matmul", "serialsum", "poly"]
    large_base_names = []
    for bench_type in large_benchmark_types:
        large_benchmarks = glob.glob(f"{args.benchmarks_dir}/large/{bench_type}/*.fz")
        for bench_path in large_benchmarks:
            # Filter out -factor.fz files and dotprod*.fz files
            filename = os.path.basename(bench_path)
            if "factor" not in filename and "dotprod" not in filename:
                # Extract base name with path prefix (e.g., "large/horner/Horner4")
                rel_path = os.path.relpath(bench_path, args.benchmarks_dir)
                base_name = rel_path.replace(".fz", "")
                large_base_names.append(base_name)
    
    # Combine and sort all benchmarks
    base_names = small_base_names + large_base_names
    base_names.sort()

    print(f"Found {len(base_names)} benchmarks")
    print(f"Output date: {date_str}")
    print(f"Output directory: {args.output_dir}")
    
    # Configuration for FPTaylor and Gappa comparisons
    precision = "binary64"
    rounding_mode = "toPositive"
    print(f"Note: Comparing NegFuzz (toPositive) against FPTaylor/Gappa with {precision} precision and {rounding_mode} rounding mode")
    print(f"Warning: NegFuzz currently ignores/skips precision and rounding mode settings (TODO: propagate precision/rounding_mode to NegFuzz processing)")

    # Process benchmarks
    results = []
    timings = []
    post_samples = {}

    print("\nProcessing benchmarks...")
    for base_name in tqdm.tqdm(base_names):
        full_name = f"{base_name}-{precision}-{rounding_mode}"
        print(f"Processing: {base_name} (using {full_name} for FPTaylor/Gappa files)")
        result, timing = process_benchmark(base_name, precision, rounding_mode, args.benchmarks_dir)
        results.append(result)
        timings.append(timing)

        # Sample post-hoc bounds (use base_name for .fz files)
        if not args.skip_sampling:
            print(f"  Sampling {args.samples} post-hoc bounds for {base_name}...")
            samples = []
            for _ in range(args.samples):
                sample = sample_post(base_name)
                if sample is not None:
                    samples.append(sample)
            post_samples[base_name] = samples
        else:
            print(f"  Skipping sampling for {base_name}")

    # Create dataframes
    results_df = pd.DataFrame(results)
    timings_df = pd.DataFrame(timings)

    # Create transpose for plotting
    results_transpose = results_df.transpose()
    results_transpose.columns = results_transpose.iloc[0]

    # Generate PDFs
    if not args.skip_sampling and post_samples:
        print("\nGenerating PDFs...")
        generate_pdfs(post_samples, results_transpose, args.output_dir)
    else:
        print("\nSkipping PDF generation (no samples)")

    # Format results CSV
    cols = ["pre-rel", "pre-abs", "pre-rel-factor", "pre-abs-factor",
            "gappa-abs", "gappa-rel", "fptaylor-abs", "fptaylor-rel",
            "satire-abs-noAbs", "satire-abs-10_20", "satire-abs-15_25", "satire-abs-20_40"]
    
    # Filter to only include columns that exist in the dataframe
    cols = [col for col in cols if col in results_df.columns]
    
    # Replace "None" strings with np.nan and convert to float64
    results_df[cols] = results_df[cols].replace({"None": np.nan}).astype("float64")
    
    # Format each column (NaN becomes empty string)
    for col in cols:
        results_df[col] = results_df[col].apply(lambda x: f'{x:.4g}' if pd.notna(x) else '')

    # Write CSVs
    results_csv = os.path.join(args.output_dir, f"results-{date_str}.csv")
    timings_csv = os.path.join(args.output_dir, f"timings-{date_str}.csv")

    results_df.to_csv(results_csv, index=False)
    timings_df.to_csv(timings_csv, index=False)

    print(f"\nSaved CSV files:")
    print(f"  Results: {results_csv}")
    print(f"  Timings: {timings_csv}")


if __name__ == "__main__":
    main()
