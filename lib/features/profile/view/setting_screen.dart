import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/core/controller/language_controller.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,
              size: 20.sp, color: context.textColor),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(height: 1, color: context.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: context.isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: greyColorWithOpacity0_4,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingItem(
                context,
                icon: Icons.person_outline,
                label: AppLocalizations.of(context)!.editProfile,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                label: AppLocalizations.of(context)!.helpSupport,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.helpSupport),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.wb_sunny_outlined,
                label: AppLocalizations.of(context)!.appearance,
                onTap: () => _showThemeBottomSheet(context),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.language_outlined,
                label: AppLocalizations.of(context)!.language,
                onTap: () => _showLanguageBottomSheet(context),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.description_outlined,
                label: AppLocalizations.of(context)!.termsConditions,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.termsConditions),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.shield_outlined,
                label: AppLocalizations.of(context)!.privacyPolicy,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy),
              ),
              // _buildSettingItem(
              //   context,
              //   icon: Icons.block_outlined,
              //   label: 'Blocked Users',
              //   onTap: () =>
              //       Navigator.pushNamed(context, AppRoutes.blockedUsers),
              // ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.visibility_outlined,
                label: AppLocalizations.of(context)!.unhideAllPosts,
                onTap: () async {
                  await context.read<TradeController>().clearHiddenPosts();
                  if (context.mounted) {
                    ToastService.showSuccessToast(context, AppLocalizations.of(context)!.allHiddenPostsVisible);
                    context.read<TradeController>().fetchHomePosts(); // Refresh feed
                  }
                },
              ),
            ],
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
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade600, size: 24.sp),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: context.textColor,
          fontFamily: FontFamily.openSans,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: greyColor,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.dividerColor,
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final languageController = context.watch<LanguageController>();
        final currentLocale = languageController.locale.languageCode;

        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: 20.h),
              _buildLanguageOption(
                context,
                title: AppLocalizations.of(context)!.english,
                isSelected: currentLocale == 'en',
                onTap: () {
                  languageController.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: AppLocalizations.of(context)!.hindi,
                isSelected: currentLocale == 'hi',
                onTap: () {
                  languageController.setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: AppLocalizations.of(context)!.marathi,
                isSelected: currentLocale == 'mr',
                onTap: () {
                  languageController.setLanguage('mr');
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
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
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: isSelected ? context.primaryColor : context.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.primaryColor)
          : null,
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBg,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        ThemeMode selectedMode = context.read<ThemeController>().themeMode;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
              decoration: BoxDecoration(
                color: context.scaffoldBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.appearance,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.white10
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close,
                              color: context.textColor, size: 20.sp),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        padding: EdgeInsets.all(8.w),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Divider(color: context.dividerColor, thickness: 1),
                  _buildThemeOption(
                    context,
                    title: AppLocalizations.of(context)!.lightTheme,
                    mode: ThemeMode.light,
                    currentMode: selectedMode,
                    onChanged: (mode) =>
                        setModalState(() => selectedMode = mode!),
                  ),
                  _buildDivider(),
                  _buildThemeOption(
                    context,
                    title: AppLocalizations.of(context)!.darkTheme,
                    mode: ThemeMode.dark,
                    currentMode: selectedMode,
                    onChanged: (mode) =>
                        setModalState(() => selectedMode = mode!),
                  ),
                  _buildDivider(),
                  _buildThemeOption(
                    context,
                    title: AppLocalizations.of(context)!.useDeviceTheme,
                    mode: ThemeMode.system,
                    currentMode: selectedMode,
                    onChanged: (mode) =>
                        setModalState(() => selectedMode = mode!),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ThemeController>().setTheme(selectedMode);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.savePreference,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                          color: context.onPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: greyColor,
      ),
      child: RadioListTile<ThemeMode>(
        value: mode,
        groupValue: currentMode,
        onChanged: onChanged,
        activeColor: context.primaryColor,
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
