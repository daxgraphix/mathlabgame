import re

content = '    "placeholders": {},'
result = re.sub(r',\s*}', '}', content)
print('Before:', repr(content))
print('After:', repr(result))

# Also test with newline
content2 = '    "placeholders": {},\n  },'
result2 = re.sub(r',\s*}', '}', content2)
print('Before2:', repr(content2))
print('After2:', repr(result2))
