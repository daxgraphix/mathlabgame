import json, re

# Read the newly generated English ARB
with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en_data = json.load(f)

# Read Swahili ARB for reference structure
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw_data = json.load(f)

# Separate message keys and metadata keys
messages = []
metadata = []
for key, value in en_data.items():
    if key.startswith('@@'):
        continue
    if key.startswith('@'):
        metadata.append((key[1:], value))  # Store without @ prefix
    else:
        messages.append((key, value))

# Build output with metadata interleaved after each message
output = ['{\n', '  "@@locale": "en",\n']

for i, (key, value) in enumerate(messages):
    indent = '  '
    # Write message
    output.append(f'{indent}"{key}": "{value}",\n')
    
    # Find and write metadata for this key
    md = next((m for k, m in metadata if k == key), None)
    if md:
        output.append(f'{indent}"@{key}": {{\n')
        output.append(f'{indent}  "description": "{md.get("description", "")}",\n')
        if md.get("placeholders"):
            output.append(f'{indent}  "placeholders": {{\n')
            for ph_name, ph_value in md["placeholders"].items():
                output.append(f'{indent}    "{ph_name}": {{\n')
                if isinstance(ph_value, dict):
                    for ph_key, ph_val in ph_value.items():
                        output.append(f'{indent}      "{ph_key}": "{ph_val}",\n')
                output.append(f'{indent}    }},\n')
            output.append(f'{indent}  }},\n')
        else:
            output.append(f'{indent}  "placeholders": {{}},\n')
        output.append(f'{indent}}},\n')

# Write the file
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.writelines(output)
    f.write('}\n')

print("Reconstructed app_en.arb with interleaved metadata")
