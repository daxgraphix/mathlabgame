import re

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    lines = f.readlines()

# Track state
output = []
in_metadata = False
brace_depth = 0
metadata_indent = None
skip_until_next_top_level = False

for i, line in enumerate(lines):
    stripped = line.strip()
    
    # Track metadata block depth
    if stripped.startswith('"@') and ':' in stripped:
        in_metadata = True
        brace_depth = stripped.count('{') - stripped.count('}')
        metadata_indent = len(line) - len(line.lstrip())
        output.append(line)
        continue
    
    if in_metadata:
        brace_depth += line.count('{') - line.count('}')
        output.append(line)
        if brace_depth <= 0:
            in_metadata = False
        continue
    
    # Detect top-level message: "key": "value"
    m = re.match(r'^(\s*)"([^@"]+)"\s*:\s*"', line)
    if m and not skip_until_next_top_level:
        indent = m.group(1)
        key = m.group(2)
        output.append(line)
        # Insert metadata block after this line
        output.append(f'{indent}"@{key}": {{\n')
        output.append(f'{indent}  "description": "",\n')
        output.append(f'{indent}  "placeholders": {{}}\n')
        output.append(f'{indent}}},\n')
        continue
    
    output.append(line)

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.writelines(output)

print("Metadata blocks inserted")
