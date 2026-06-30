import 'package:flutter/material.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/blocked_user_model.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:intl/intl.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

class WebBlockedUsersScreen extends StatefulWidget {
  const WebBlockedUsersScreen({super.key});

  @override
  State<WebBlockedUsersScreen> createState() => _WebBlockedUsersScreenState();
}

class _WebBlockedUsersScreenState extends State<WebBlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final blockedUsers = profileController.blockedUsers;
    final isLoading = profileController.isLoading && blockedUsers.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              WebScreenHeader(
                title: AppLocalizations.of(context)!.blockedUsers,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: AppLocalizations.of(context)!.refresh,
                    onPressed: () =>
                        context.read<ProfileController>().getBlockedUsers(),
                  )
                ],
              ),
              const Divider(height: 1),
              _buildInfoBanner(context),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : blockedUsers.isEmpty
                        ? _buildEmptyState(context)
                        : _buildWebGrid(context, blockedUsers),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.blockedUsersWillNotBe,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF42526E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebGrid(
      BuildContext context, List<BlockedUserModel> blockedUsers) {
    int crossAxisCount = 2;
    if (MediaQuery.of(context).size.width < 800) {
      crossAxisCount = 1;
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: blockedUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(context, blockedUsers[index]);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, BlockedUserModel user) {
    return InkWell(
      onTap: () => ProfileController.navigateToUserProfile(context, user.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: AppCachedImage(
                    imageUrl: user.profileImage ?? '',
                    userName: user.fullName,
                    width: 80,
                    height: 80,
                    radius: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${user.avgStars} (${user.totalRatings} Reviews)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (user.blockedAt.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Blocked on: ${DateFormat('dd MMM yyyy').format(DateTime.parse(user.blockedAt))}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => _showUnblockDialog(context, user),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text(
                  AppLocalizations.of(context)!.unblock,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, BlockedUserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(AppLocalizations.of(context)!.unblockUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: AppCachedImage(
                  imageUrl: user.profileImage ?? '',
                  userName: user.fullName,
                  width: 100,
                  height: 100,
                  radius: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Are you sure you want to unblock ${user.fullName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final response = await context
                    .read<ProfileController>()
                    .unblockUser(user.id);
                if (!context.mounted) return;
                if (response.success) {
                  ToastService.showSuccessToast(context, response.message);
                } else {
                  ToastService.showErrorToast(context, response.message);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.unblock,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.block, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.noBlockedUsers,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
