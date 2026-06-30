import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class WebThemeChangeScreen extends StatelessWidget {
  const WebThemeChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.appearanceSettings,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: FontFamily.openSans,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.customizeTheLookAndFeel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: context.subTextColor,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: context.dividerColor.withOpacity(0.5)),
                  boxShadow: context.isDarkMode
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      title: 'Light Mode',
                      subtitle: 'Clean and bright',
                      icon: Icons.light_mode_outlined,
                      mode: ThemeMode.light,
                      currentMode: themeController.themeMode,
                    ),
                    _buildDivider(context),
                    _buildThemeOption(
                      context,
                      title: AppLocalizations.of(context)!.darkMode,
                      subtitle: 'Easy on the eyes',
                      icon: Icons.dark_mode_outlined,
                      mode: ThemeMode.dark,
                      currentMode: themeController.themeMode,
                    ),
                    _buildDivider(context),
                    _buildThemeOption(
                      context,
                      title: 'System Default',
                      subtitle: 'Follows your OS setting',
                      icon: Icons.settings_brightness_outlined,
                      mode: ThemeMode.system,
                      currentMode: themeController.themeMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => context.read<ThemeController>().setTheme(mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primaryColor.withOpacity(0.1)
                      : context.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? context.primaryColor : context.subTextColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? context.primaryColor
                            : context.textColor,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: context.primaryColor, size: 28)
              else
                Icon(
                  Icons.circle_outlined,
                  color: context.dividerColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 80,
      color: context.dividerColor.withOpacity(0.5),
    );
  }
}
