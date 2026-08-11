import re

# Read Swahili file to get the canonical key order and structure
with open('lib/l10n/app_sw.arb', encoding='utf-8') as f:
    sw_content = f.read()

# Read corrupted English file to extract English values
with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en_content = f.read()

# Extract all message values from English file
en_values = {}
for m in re.finditer(r'^(\s*)"([^@"]+)"\s*:\s*"((?:[^"\\]|\\.)*)"', en_content, re.MULTILINE):
    key = m.group(2)
    value = m.group(3)
    en_values[key] = value

# Extract metadata blocks from Swahili file (for placeholder definitions)
sw_metadata = {}
for m in re.finditer(r'"@([^"]+)"\s*:\s*\{(\s*.*?)\n\s*\},?', sw_content, re.DOTALL):
    key = m.group(1)
    block = m.group(2)
    sw_metadata[key] = block

# Also extract metadata from English file (in case there are English-specific ones)
for m in re.finditer(r'"@([^"]+)"\s*:\s*\{(\s*.*?)\n\s*\},?', en_content, re.DOTALL):
    key = m.group(1)
    block = m.group(2)
    # Only use if not already in Swahili metadata
    if key not in sw_metadata:
        sw_metadata[key] = block

# Build new English ARB content
output_lines = ['{\n', '  "@@locale": "en",\n']

# Process Swahili file line by line to preserve structure
sw_lines = sw_content.split('\n')
i = 0
while i < len(sw_lines):
    line = sw_lines[i]
    stripped = line.strip()
    
    # Skip @@locale
    if stripped.startswith('"@@locale"'):
        i += 1
        continue
    
    # Detect message line: "key": "value"
    m = re.match(r'^(\s*)"([^@"]+)"\s*:\s*"', line)
    if m:
        indent = m.group(1)
        key = m.group(2)
        
        # Get English value if available, otherwise use Swahili as placeholder
        value = en_values.get(key, 'MISSING')
        
        # Write message line
        output_lines.append(f'{indent}"{key}": "{value}",\n')
        
        # Check if there's metadata for this key
        if key in sw_metadata:
            output_lines.append(f'{indent}"@{key}": {{\n')
            # Parse metadata block line by line
            md_lines = sw_metadata[key].split('\n')
            for md_line in md_lines:
                output_lines.append(f'{indent}  {md_line.strip()}\n')
            output_lines.append(f'{indent}}},\n')
        else:
            # Add empty metadata block
            output_lines.append(f'{indent}"@{key}": {{\n')
            output_lines.append(f'{indent}  "description": "",\n')
            output_lines.append(f'{indent}  "placeholders": {{}}\n')
            output_lines.append(f'{indent}}},\n')
        
        i += 1
        continue
    
    # Skip existing metadata blocks in Swahili file
    if stripped.startswith('"@') and ':' in stripped:
        # Skip until end of block
        brace_depth = stripped.count('{') - stripped.count('}')
        i += 1
        while i < len(sw_lines) and brace_depth > 0:
            brace_depth += sw_lines[i].count('{') - sw_lines[i].count('}')
            i += 1
        continue
    
    output_lines.append(line + '\n')
    i += 1

# Write the reconstructed file
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print("Reconstructed app_en.arb")
