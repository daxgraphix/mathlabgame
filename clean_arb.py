import re, json

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    content = f.read()

# Remove all existing metadata blocks to clean corruption
# Match top-level "@key": { ... }, blocks (may span multiple lines)
content = re.sub(r'\n\s*"@[^"]+"\s*:\s*\{.*?\n\s*\},?', '', content, flags=re.DOTALL)

# Also remove any stray empty lines left behind
content = re.sub(r'\n{3,}', '\n\n', content)

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.write(content)

print("Removed all metadata blocks")
