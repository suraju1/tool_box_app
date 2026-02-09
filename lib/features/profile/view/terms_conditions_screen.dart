import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
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
              _buildSectionTitle(context, '1. Acceptance of Terms'),
              _buildSectionContent(
                context,
                'By accessing and using Tool Bocs, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the application.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '2. User Registration'),
              _buildSectionContent(
                context,
                'Users must provide accurate information during registration. You are responsible for maintaining the confidentiality of your account credentials.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '3. Giving & Taking Policy'),
              _buildSectionContent(
                context,
                'Tool Bocs facilitates the exchange of items. Users are responsible for the accuracy of item descriptions and the safe handover of items.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '4. Prohibited Items'),
              _buildSectionContent(
                context,
                'Users may not list illegal, hazardous, or prohibited items as defined by local laws and our community guidelines.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '5. Limitation of Liability'),
              _buildSectionContent(
                context,
                'Tool Bocs is not responsible for the quality, safety, or legality of items exchanged. Users trade at their own risk.',
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, '6. Modifications to Terms'),
              _buildSectionContent(
                context,
                'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the updated terms.',
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
