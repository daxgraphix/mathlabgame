with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    lines = f.readlines()

output = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.rstrip()
    
    # Check if this line ends with a comma
    if stripped.endswith(',') and i + 1 < len(lines):
        next_line = lines[i + 1].lstrip()
        # If next line starts with } or ], this is a trailing comma
        if next_line.startswith('}') or next_line.startswith(']'):
            # Remove the trailing comma
            output.append(stripped[:-1] + '\n')
            i += 1
            continue
    
    output.append(line)
    i += 1

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.writelines(output)

print("Removed trailing commas")
