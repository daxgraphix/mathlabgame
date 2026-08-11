import re

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    content = f.read()

# Find all message keys with placeholders
pattern_msg = re.compile(r'"([^@"]+)"\s*:\s*"[^"]*\{[^}]+\}[^"]*"')
pattern_md = re.compile(r'"@([^"]+)"\s*:\s*\{')
msgs = set(pattern_msg.findall(content))
mds = set(pattern_md.findall(content))
missing = sorted(msgs - mds)
print(f'Messages with placeholders but missing metadata: {len(missing)}')
for m in missing:
    print(m)
