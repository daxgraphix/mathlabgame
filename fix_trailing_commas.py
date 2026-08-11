import re

with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    content = f.read()

# Remove trailing commas before closing braces/brackets
# Pattern: comma followed by optional whitespace and then } or ]
content = re.sub(r',\s*}', '}', content)
content = re.sub(r',\s*]', ']', content)

# Verify it's valid JSON now
import json
try:
    data = json.loads(content)
    print("JSON is now valid")
except json.JSONDecodeError as e:
    print(f"Still invalid: {e}")
    exit(1)

# Re-serialize with proper formatting
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Fixed trailing commas and reformatted")
