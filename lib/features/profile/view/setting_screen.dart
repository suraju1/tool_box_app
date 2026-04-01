import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

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
          'Settings',
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
                label: 'Edit Profile',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.helpSupport),
              ),
              _buildDivider(),
              //dont show theme option
              // _buildSettingItem(
              //   context,
              //   icon: Icons.palette_outlined,
              //   label: 'Theme',
              //   onTap: () =>
              //       Navigator.pushNamed(context, AppRoutes.themeChange),
              // ),
              // _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.termsConditions),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy),
              ),
              // _buildDivider(),
              // _buildSettingItem(
              //   context,
              //   icon: Icons.block_outlined,
              //   label: 'Blocked Users',
              //   onTap: () =>
              //       Navigator.pushNamed(context, AppRoutes.blockedUsers),
              // ),
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
}
