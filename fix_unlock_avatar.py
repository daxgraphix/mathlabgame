import json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en = json.load(f)
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw = json.load(f)

# Fix unlockAvatarConfirm cost type to int
for arb in [en, sw]:
    if '@unlockAvatarConfirm' in arb:
        if 'placeholders' in arb['@unlockAvatarConfirm']:
            if 'cost' in arb['@unlockAvatarConfirm']['placeholders']:
                arb['@unlockAvatarConfirm']['placeholders']['cost']['type'] = 'int'

# Write updated files
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(en, f, ensure_ascii=False, indent=2)
    f.write('\n')

with open('lib/l10n/app_sw.arb', 'w', encoding='utf-8') as f:
    json.dump(sw, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Fixed unlockAvatarConfirm cost type to int")
