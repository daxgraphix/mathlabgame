import json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en = json.load(f)
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw = json.load(f)

# Check placeholder types for messages that have them in both files
for key in ['ptsToLevel', 'timeLeftShort', 'levelUppercase']:
    en_msg = en.get(key, '')
    sw_msg = sw.get(key, '')
    en_md = en.get(f'@{key}', {})
    sw_md = sw.get(f'@{key}', {})
    print(f'{key}:')
    print(f'  EN: {en_msg}')
    print(f'  SW: {sw_msg}')
    print(f'  EN placeholders: {en_md.get("placeholders", {})}')
    print(f'  SW placeholders: {sw_md.get("placeholders", {})}')
