import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class ThemeChangeScreen extends StatelessWidget {
  const ThemeChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.appBarColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Theme',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: context.textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(
            height: 1,
            color: context.dividerColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.openSans,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
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
                children: [
                  _buildThemeOption(
                    context,
                    title: 'Light Mode',
                    icon: Icons.light_mode_outlined,
                    mode: ThemeMode.light,
                    currentMode: themeController.themeMode,
                  ),
                  _buildDivider(context),
                  _buildThemeOption(
                    context,
                    title: 'Dark Mode',
                    icon: Icons.dark_mode_outlined,
                    mode: ThemeMode.dark,
                    currentMode: themeController.themeMode,
                  ),
                  _buildDivider(context),
                  _buildThemeOption(
                    context,
                    title: 'System Default',
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
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    return ListTile(
      onTap: () => context.read<ThemeController>().setTheme(mode),
      leading: Icon(
        icon,
        color: isSelected ? context.primaryColor : context.subTextColor,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? context.primaryColor : context.textColor,
          fontFamily: FontFamily.openSans,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.primaryColor, size: 24.sp)
          : Icon(
              Icons.circle_outlined,
              color: context.dividerColor,
              size: 24.sp,
            ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 50.w,
      color: context.dividerColor,
    );
  }
}
