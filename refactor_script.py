import re

with open('lib/features/web_ui/view/web_product_details_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

with open('new_widgets.dart', 'r', encoding='utf-8') as f:
    new_widgets = f.read()

# Remove _buildDescriptionSection
content = re.sub(r'  Widget _buildDescriptionSection\(PostModel post\) \{.*?^  \}', '', content, flags=re.MULTILINE | re.DOTALL)

# Remove _buildNewActionCard
content = re.sub(r'  Widget _buildNewActionCard\(PostModel post, LocationController locationController\) \{.*?^  \}', '', content, flags=re.MULTILINE | re.DOTALL)

# Remove _buildSpecificationsList
content = re.sub(r'  Widget _buildSpecificationsList\(PostModel post\) \{.*?^  \}', '', content, flags=re.MULTILINE | re.DOTALL)

# Remove _buildSpecRow
content = re.sub(r'  Widget _buildSpecRow\(.*?^  \}', '', content, flags=re.MULTILINE | re.DOTALL)

content = content.replace('  Widget _buildNewSellerCard(PostModel post) {', new_widgets + '\n\n  Widget _buildNewSellerCard(PostModel post) {')

with open('lib/features/web_ui/view/web_product_details_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
