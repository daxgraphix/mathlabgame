import re, json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    content = f.read()

# Find all message keys
msg_pattern = re.compile(r'^(\s*)"([^"@]+)"\s*:\s*"(?:[^"\\]|\\.)*"', re.MULTILINE)
meta_pattern = re.compile(r'^(\s*)"@([^"]+)"\s*:\s*\{', re.MULTILINE)

messages = []
for m in msg_pattern.finditer(content):
    indent = m.group(1)
    key = m.group(2)
    messages.append((m.start(), m.end(), indent, key))

metadata_keys = set()
for m in meta_pattern.finditer(content):
    metadata_keys.add(m.group(2))

# Build insertions: insert after each message that lacks metadata
insertions = []
for start, end, indent, key in messages:
    if key in metadata_keys:
        continue
    placeholder_block = (
        f'{indent}"@{key}": {{\n'
        f'{indent}  "description": "",\n'
        f'{indent}  "placeholders": {{}}\n'
        f'{indent}}},\n'
    )
    insertions.append((end, placeholder_block))

# Apply insertions in reverse order to preserve positions
insertions.sort(key=lambda x: x[0], reverse=True)
for pos, text in insertions:
    content = content[:pos] + text + content[pos:]

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Inserted {len(insertions)} metadata blocks")
