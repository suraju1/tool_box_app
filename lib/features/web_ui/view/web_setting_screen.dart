import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/core/controller/language_controller.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class WebSettingScreen extends StatefulWidget {
  const WebSettingScreen({super.key});

  @override
  State<WebSettingScreen> createState() => _WebSettingScreenState();
}

class _WebSettingScreenState extends State<WebSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.openSans,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 24),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Theme.of(context).dividerColor),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.wb_sunny_outlined,
                    label: AppLocalizations.of(context)!.appearance,
                    onTap: () => _showThemeDialog(context),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.language_outlined,
                    label: AppLocalizations.of(context)!.language,
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Terms & Conditions',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.termsConditions),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.visibility_outlined,
                    label: 'Unhide All Posts',
                    onTap: () async {
                      await context.read<TradeController>().clearHiddenPosts();
                      if (!context.mounted) return;
                      ToastService.showSuccessToast(context, 'All hidden posts are now visible');
                      context.read<TradeController>().fetchHomePosts(); // Refresh feed
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Icon(icon, color: Colors.grey.shade600, size: 28),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.openSans,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final languageController = context.watch<LanguageController>();
        final currentLocale = languageController.locale.languageCode;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                title: 'English',
                isSelected: currentLocale == 'en',
                onTap: () {
                  languageController.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'हिन्दी (Hindi)',
                isSelected: currentLocale == 'hi',
                onTap: () {
                  languageController.setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'मराठी (Marathi)',
                isSelected: currentLocale == 'mr',
                onTap: () {
                  languageController.setLanguage('mr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        ThemeMode selectedMode = context.read<ThemeController>().themeMode;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Appearance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context,
                    title: 'Light theme',
                    mode: ThemeMode.light,
                    currentMode: selectedMode,
                    onChanged: (mode) => setModalState(() => selectedMode = mode!),
                  ),
                  _buildThemeOption(
                    context,
                    title: 'Dark theme',
                    mode: ThemeMode.dark,
                    currentMode: selectedMode,
                    onChanged: (mode) => setModalState(() => selectedMode = mode!),
                  ),
                  _buildThemeOption(
                    context,
                    title: 'Use device theme',
                    mode: ThemeMode.system,
                    currentMode: selectedMode,
                    onChanged: (mode) => setModalState(() => selectedMode = mode!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ThemeController>().setTheme(selectedMode);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: currentMode,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }
}
