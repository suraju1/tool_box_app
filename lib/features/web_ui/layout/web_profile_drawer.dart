import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/web_ui/view/web_logout_dialog.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/web_ui/view/web_setting_screen.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class WebProfileDrawer extends StatelessWidget {
  const WebProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final profile = profileController.ownProfile;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final dividerColor = theme.dividerColor;
    final primaryColor = theme.primaryColor;

    if (profile == null) {
      return Drawer(
        width: 320,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = profile.userDetails;

    return Drawer(
      width: 320,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: dividerColor, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: AppCachedImage(
                          imageUrl: user.image ?? '',
                          userName: user.fullName,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          radius: 36,
                          placeholderBgColor: primaryColor.withOpacity(0.1),
                          placeholderTextColor: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio!.trim(),
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontFamily.openSans,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Credit Balance : ',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: FontFamily.openSans,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.remainingBalance ?? '0.00',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: dividerColor, height: 1),
              const SizedBox(height: 10),
              
              // Menu
              _buildMenuItem(
                context: context,
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.webProfile);
                },
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.post_add_outlined,
                label: AppLocalizations.of(context)?.myPosts ?? 'My Posts',
                onTap: () => Navigator.pushNamed(context, AppRoutes.myPosts),
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.card_membership_outlined,
                label: AppLocalizations.of(context)?.mySubscription ?? 'My Subscription',
                onTap: () => Navigator.pushNamed(context, AppRoutes.mySubscription),
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.sync_alt,
                label: AppLocalizations.of(context)?.transactionHistory ?? 'Transaction History',
                onTap: () => Navigator.pushNamed(context, AppRoutes.transactionHistory),
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.bookmark_border,
                label: AppLocalizations.of(context)?.savedProfiles ?? 'Saved Profiles',
                onTap: () => Navigator.pushNamed(context, AppRoutes.savedUsers),
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.block_outlined,
                label: AppLocalizations.of(context)?.blockedUsers ?? 'Blocked Users',
                onTap: () => Navigator.pushNamed(context, AppRoutes.blockedUsers),
                textColor: textColor,
              ),
              const SizedBox(height: 10),
              Divider(color: dividerColor, height: 1),
              const SizedBox(height: 10),
              _buildMenuItem(
                context: context,
                icon: Icons.settings_outlined,
                label: AppLocalizations.of(context)?.settings ?? 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WebSettingScreen()),
                  );
                },
                textColor: textColor,
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.login_outlined,
                label: AppLocalizations.of(context)?.logout ?? 'Logout',
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => const WebLogoutDialog(),
                  );
                },
                textColor: textColor,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: textColor, size: 24),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }
}
