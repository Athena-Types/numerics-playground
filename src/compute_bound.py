import sys

PAIRED_BOUNDS = {
    "pos-err" : "pos", # a'
    "pos-ideal" : "Mpos", # a
    "neg-err" : "neg",  # b'
    "neg-ideal" : "Mneg",  # b
    "b1" : "Mpos / Mpos - Mneg", # a / a - b
    "b2" : "Mneg / Mpos - Mneg", # b / a - b
    "b3" : "neg / pos - neg", # b' / a' - b'
    "b4" : "pos / pos - neg", # a' / a' - b'
}
BOUNDS = {
    "real" : "ex0", # a' - b'
    "ideal" : "Mex0", # a - b
    "rel" : "ex0 -/ Mex0", # a' - b' / a - b
    "abs" : "|ex0 - Mex0|", # |a' - b'|
}

def main(filename):
    with open(filename) as f:
        gappa_file = f.read()

    gappa_file_prefix = gappa_file.split("->")[0]

    if "paired" in filename:
        sweep(filename, gappa_file_prefix, PAIRED_BOUNDS)

    sweep(filename, gappa_file_prefix, BOUNDS)

def sweep(filename, gappa_file_prefix, bounds):
    for bound_name, bound_expr in bounds.items():
        out = filename.replace(".g", "-") + bound_name + ".g"
        content = gappa_file_prefix + f"-> {bound_expr} in ? " + '}'
        with open(out, "w") as f:
            f.write(content)
        print(f"Created gappa file {out}")

if __name__ == "__main__":
    main(sys.argv[1])
