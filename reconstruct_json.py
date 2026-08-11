import json

# Read Swahili file
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw_data = json.load(f)

# Read corrupted English file to extract English values
with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en_content = f.read()

# Extract English values from corrupted file
en_values = {}
for m in __import__('re').finditer(r'"([^@"]+)"\s*:\s*"((?:[^"\\]|\\.)*)"', en_content):
    key = m.group(1)
    value = m.group(2)
    if not key.startswith('@@'):
        en_values[key] = value

# Build new English ARB data
en_data = {"@@locale": "en"}

# Add all keys from Swahili file with English values
for key, value in sw_data.items():
    if key.startswith('@@'):
        continue
    if key.startswith('@'):
        # This is a metadata key, skip for now
        continue
    # Use English value if available
    en_value = en_values.get(key, value)
    en_data[key] = en_value

# Add metadata blocks for all message keys
for key in list(en_data.keys()):
    if key.startswith('@@'):
        continue
    # Check if the message has placeholders
    if '{' in en_data[key]:
        # Create metadata with placeholders
        placeholders = {}
        for ph in __import__('re').findall(r'\{(\w+)\}', en_data[key]):
            placeholders[ph] = {"type": "String", "example": ph}
        en_data[f"@{key}"] = {
            "description": "",
            "placeholders": placeholders
        }
    else:
        en_data[f"@{key}"] = {
            "description": "",
            "placeholders": {}
        }

# Write the new file with nice formatting
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Reconstructed app_en.arb with proper JSON formatting")
