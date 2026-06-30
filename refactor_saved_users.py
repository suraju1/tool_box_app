import re

with open('lib/features/web_ui/view/web_saved_users_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add getCollections to initState
init_state_pattern = r'(context\.read<ProfileController>\(\)\.getSavedUsers\(\);)'
content = re.sub(init_state_pattern, r'\1\n      context.read<ProfileController>().getCollections();', content)

# Modify _buildRightContentArea
right_area_pattern = r'Widget _buildRightContentArea\(BuildContext context\) \{.*?(?=  Widget _buildEmptyState)'
new_right_area = '''Widget _buildRightContentArea(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.3);
    final profileController = context.watch<ProfileController>();
    final collections = profileController.collections;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: FontFamily.openSans,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateFolderDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context)!.createNewFolder),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: collections.isEmpty
                  ? Center(
                      child: Text(
                        'No collections found.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: collections.length,
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        return InkWell(
                          onTap: () {
                            ToastService.showSuccessToast(context, 'Collection items feature coming soon!');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: dividerColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder, size: 40, color: Theme.of(context).primaryColor),
                                const SizedBox(height: 12),
                                Text(
                                  collection.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\ items',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

'''
content = re.sub(right_area_pattern, new_right_area, content, flags=re.DOTALL)

with open('lib/features/web_ui/view/web_saved_users_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

