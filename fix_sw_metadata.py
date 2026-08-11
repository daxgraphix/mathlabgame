import json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en = json.load(f)
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw = json.load(f)

# Build metadata from English file as template
en_metadata = {}
for key, value in en.items():
    if key.startswith('@') and not key.startswith('@@'):
        en_metadata[key[1:]] = value

# Add metadata to Swahili file for all messages
for key in list(sw.keys()):
    if key.startswith('@@') or key.startswith('@'):
        continue
    
    # Get English metadata as template
    en_md = en_metadata.get(key, {})
    
    if key in en_md:
        # Use English metadata structure but preserve Swahili description if it exists
        sw_md = sw.get(f'@{key}', {})
        new_md = {
            'description': sw_md.get('description', en_md.get('description', '')),
            'placeholders': {}
        }
        # Copy placeholders from English template
        if 'placeholders' in en_md:
            for ph_name, ph_value in en_md['placeholders'].items():
                new_md['placeholders'][ph_name] = ph_value.copy() if isinstance(ph_value, dict) else ph_value
        sw[f'@{key}'] = new_md
    else:
        # No placeholders in English, add empty metadata
        sw[f'@{key}'] = {
            'description': '',
            'placeholders': {}
        }

# Write the updated Swahili file
with open('lib/l10n/app_sw.arb', 'w', encoding='utf-8') as f:
    json.dump(sw, f, ensure_ascii=False, indent=2)
    f.write('\n')

print(f'Updated app_sw.arb with metadata for all {len([k for k in sw if not k.startswith("@")])} messages')
