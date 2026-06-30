import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/saved_user_model.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

import 'package:tool_bocs/features/web_ui/view/web_collection_items_screen.dart';

class WebSavedUsersScreen extends StatefulWidget {
  const WebSavedUsersScreen({super.key});

  @override
  State<WebSavedUsersScreen> createState() => _WebSavedUsersScreenState();
}

class _WebSavedUsersScreenState extends State<WebSavedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getSavedUsers();
      context.read<ProfileController>().getCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final savedUsers = profileController.savedUsers;
    final isLoading = profileController.isLoading && savedUsers.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              WebScreenHeader(
                title: AppLocalizations.of(context)!.savedProfiles,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: AppLocalizations.of(context)!.refresh,
                    onPressed: () =>
                        context.read<ProfileController>().getSavedUsers(),
                  )
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContentArea(context, savedUsers),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(
      BuildContext context, List<SavedUserModel> savedUsers) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLeftSidebar(context, savedUsers),
          const SizedBox(width: 24),
          _buildRightContentArea(context),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(
      BuildContext context, List<SavedUserModel> savedUsers) {
    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.3);
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.allSaved,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: FontFamily.openSans,
                  ),
                ),
                Text(
                  '${savedUsers.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8),
                    fontFamily: FontFamily.openSans,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          Expanded(
            child: savedUsers.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: savedUsers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final user = savedUsers[index];
                      return _buildProfileListItem(context, user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(BuildContext context, SavedUserModel user) {
    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.3);
    return InkWell(
      onTap: () {
        ProfileController.navigateToUserProfile(context, user.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AppCachedImage(
                imageUrl: user.profileImage ?? '',
                userName: user.fullName,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                radius: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                user.fullName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.openSans,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightContentArea(BuildContext context) {
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebCollectionItemsScreen(
                                    collection: collection),
                              ),
                            ).then((_) {
                              context
                                  .read<ProfileController>()
                                  .getCollections();
                            });
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
                                Icon(Icons.folder,
                                    size: 40,
                                    color: Theme.of(context).primaryColor),
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
                                  '${collection.itemCount} items',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withOpacity(0.6),
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

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bookmark_border, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.noSavedUsersYet,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                AppLocalizations.of(context)!.createNewFolder,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: FontFamily.openSans,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: TextField(
                  controller: nameController,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.folderName,
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameController.text.trim().isNotEmpty) {
                            setState(() => isSaving = true);
                            final res = await context
                                .read<ProfileController>()
                                .createCollection(nameController.text.trim());
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (res.success) {
                                ToastService.showSuccessToast(
                                    context,
                                    AppLocalizations.of(context)!
                                        .collectionCreatedSuccessfully);
                              } else {
                                ToastService.showErrorToast(
                                    context,
                                    res.message ??
                                        AppLocalizations.of(context)!
                                            .failedToCreateCollection);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppLocalizations.of(context)!.create),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
