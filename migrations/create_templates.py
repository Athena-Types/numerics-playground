#!/usr/bin/env python3

import re
import glob

indent = ''

for fpcore_file in glob.glob('benchmarks-new/*.fpcore'):
    template_file = fpcore_file.replace('.fpcore', '.fpcore.template')
    
    with open(fpcore_file, 'r') as f:
        lines = f.readlines()
    
    output_lines = []
    found_round = False
    found_precision = False
    for line in lines:
        if re.match(r'^\s*:round\s+\S+', line):
            found_round = True
            output_lines.append(f'{indent}:round\n')
            output_lines.append(f'{indent}${{ROUNDING_MODE}}\n')
            continue

        if re.match(r'^\s*:precision', line):
            found_precision = True
            output_lines.append(line)
            idx = lines.index(line)
            if idx + 1 < len(lines):
                next_line = lines[idx + 1]
                if 'binary64' in next_line:
                    output_lines.append(next_line)
                    output_lines.append(f'{indent}:round\n')
                    output_lines.append(f'{indent}${{ROUNDING_MODE}}\n')
                    continue
            continue

        if not found_precision and not found_round and re.match(r'^\s*:pre', line):
            output_lines.append(f'{indent}:precision\n')
            output_lines.append(f'{indent}binary64\n')
            output_lines.append(f'{indent}:round\n')
            output_lines.append(f'{indent}${{ROUNDING_MODE}}\n')
            output_lines.append(line)
            continue

        output_lines.append(line)
    
    with open(template_file, 'w') as f:
        f.writelines(output_lines)
    
    print(f"Created {template_file}")
