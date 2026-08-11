import json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en = json.load(f)
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw = json.load(f)

# Copy placeholder metadata from EN to SW, preserving SW message values and descriptions
for key in en:
    if key.startswith('@') and not key.startswith('@@'):
        base_key = key[1:]
        if base_key in sw:
            en_md = en[key]
            sw_md = sw.get(key, {})
            
            # Start with Swahili description if it exists and is non-empty
            new_md = {
                "description": sw_md.get("description", ""),
                "placeholders": {}
            }
            
            # Copy placeholders from English metadata
            if "placeholders" in en_md:
                for ph_name, ph_value in en_md["placeholders"].items():
                    new_md["placeholders"][ph_name] = ph_value.copy() if isinstance(ph_value, dict) else ph_value
            
            sw[key] = new_md

# Write updated Swahili file
with open('lib/l10n/app_sw.arb', 'w', encoding='utf-8') as f:
    json.dump(sw, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Synced placeholder metadata from EN to SW")
