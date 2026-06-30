import os
import re

web_ui_dir = r'd:\Axolotls_Projects\tool_box_app\lib\features\web_ui'
count = 0
strings = set()

for root, _, files in os.walk(web_ui_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
                matches = re.findall(r"Text\s*\(\s*(['\"].*?['\"])\s*[,\)]", content)
                count += len(matches)
                strings.update(matches)

print(f"Total Text(string) occurrences: {count}")
print(f"Unique strings: {len(strings)}")
for s in list(strings):
    print(s)
