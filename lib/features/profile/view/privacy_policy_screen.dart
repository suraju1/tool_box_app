import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: context.textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(height: 1, color: context.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.dividerColor),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, '1. Information Collection'),
              _buildSectionContent(
                context,
                'We collect information you provide directly to us, such as when you create an account, post an item, or communicate with other users.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '2. Use of Information'),
              _buildSectionContent(
                context,
                'We use the information we collect to provide, maintain, and improve our services, including to facilitate transactions and communications between users.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '3. Information Sharing'),
              _buildSectionContent(
                context,
                'We do not share your private personal information with third parties except as described in this policy, such as when required by law.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '4. Data Security'),
              _buildSectionContent(
                context,
                'We take reasonable measures to protect your information from loss, theft, misuse, and unauthorized access.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '5. Your Choices'),
              _buildSectionContent(
                context,
                'You can update your account information and preferences at any time through the app settings.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '6. Contact Us'),
              _buildSectionContent(
                context,
                'If you have any questions about this Privacy Policy, please contact us through the Help & Support section.',
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Last Updated: February 2026',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.subTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: context.textColor,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14.sp,
        color: context.textColor.withOpacity(0.7),
        height: 1.5,
        fontFamily: FontFamily.openSans,
      ),
    );
  }
}
