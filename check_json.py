import json, re

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    content = f.read()

# Find duplicate keys
keys = re.findall(r'"([^@"]+)"\s*:', content)
from collections import Counter
dupes = {k: v for k, v in Counter(keys).items() if v > 1}
if dupes:
    print('Duplicate keys:', dupes)
else:
    print('No duplicate keys')

# Try to parse and show error position
try:
    json.loads(content)
    print("JSON is valid")
except json.JSONDecodeError as e:
    print(f'Error at line {e.lineno}, col {e.colno}: {e.msg}')
    lines = content.split('\n')
    start = max(0, e.lineno - 3)
    end = min(len(lines), e.lineno + 2)
    for i in range(start, end):
        marker = '>>> ' if i == e.lineno - 1 else '    '
        print(f'{marker}{i+1}: {lines[i]}')
