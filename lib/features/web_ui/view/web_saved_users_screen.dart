import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/saved_user_model.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

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
                title: 'Saved Profiles',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
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

  Widget _buildContentArea(BuildContext context, List<SavedUserModel> savedUsers) {
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

  Widget _buildLeftSidebar(BuildContext context, List<SavedUserModel> savedUsers) {
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
                  'All Saved',
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
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  ToastService.showSuccessToast(context, "Create folder feature coming soon!");
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create New Folder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            ],
          ),
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
        const Text(
          'No saved users yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
