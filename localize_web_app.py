import os
import re
import json

arb_path = r'd:\Axolotls_Projects\tool_box_app\lib\l10n\app_en.arb'
web_ui_dir = r'd:\Axolotls_Projects\tool_box_app\lib\features\web_ui'

# 1. Load ARB file
with open(arb_path, 'r', encoding='utf-8') as f:
    arb_data = json.load(f)

# Create a mapping of string value -> key
# We only map strings that don't have placeholders for exact matches
value_to_key = {}
for key, value in arb_data.items():
    if key.startswith('@'):
        continue
    # Skip if it contains placeholders in the ARB value like {name}
    if '{' in value and '}' in value:
        continue
    # Store exact value match
    value_to_key[value] = key
    
    # Store variations (e.g., lowercase, stripped)
    # But to be safe, let's stick to exact matches and maybe some common escapes
    value_to_key[value.replace('\n', '\\n')] = key

# We want to replace hardcoded strings in Text(), hintText:, label:, etc.
# Regular expression to find Text('something') or Text("something")
# This is tricky because strings can contain escaped quotes.
# We will use a simpler approach: iterate over the value_to_key dict,
# and for each value, find and replace it in the dart files.

# To avoid replacing random code, we will look for:
# 'value' or "value"
# and replace with AppLocalizations.of(context)!.key

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original_content = content
    replaced_count = 0
    
    for value, key in value_to_key.items():
        # Escape value for regex
        # We handle single and double quotes
        escaped_value = re.escape(value)
        
        # 1. Replace inside Text()
        # Find: Text('value') or Text("value") or const Text('value')
        # Replace: Text(AppLocalizations.of(context)!.key)
        
        pattern1 = r"(?<!\w)const\s+Text\s*\(\s*['\"]" + escaped_value + r"['\"]\s*"
        content, c1 = re.subn(pattern1, f"Text(AppLocalizations.of(context)!.{key}", content)
        
        pattern2 = r"(?<!\w)Text\s*\(\s*['\"]" + escaped_value + r"['\"]\s*"
        content, c2 = re.subn(pattern2, f"Text(AppLocalizations.of(context)!.{key}", content)
        
        # 2. Replace hintText, labelText, etc.
        # Find: hintText: 'value'
        # Replace: hintText: AppLocalizations.of(context)!.key
        pattern3 = r"(hintText|labelText|tooltip|label|title)\s*:\s*['\"]" + escaped_value + r"['\"]"
        content, c3 = re.subn(pattern3, f"\\1: AppLocalizations.of(context)!.{key}", content)
        
        # 3. Replace direct strings (be careful with this, so we only do it if it's very specific, but let's stick to the above for safety)
        
        replaced_count += c1 + c2 + c3
        
    if replaced_count > 0:
        # Check if import is present
        import_stmt = "import 'package:tool_bocs/l10n/generated/app_localizations.dart';"
        if import_stmt not in content:
            # Find the last import and insert after it
            last_import_idx = content.rfind("import '")
            if last_import_idx != -1:
                end_of_line = content.find('\n', last_import_idx)
                content = content[:end_of_line+1] + import_stmt + '\n' + content[end_of_line+1:]
            else:
                content = import_stmt + '\n' + content
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath} ({replaced_count} replacements)")

for root, _, files in os.walk(web_ui_dir):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
            
print("Done processing web files.")
