import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmer = context.watch<ShimmerController>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: shimmer.isLoading
          ? _buildShimmer(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Matches'),
                  _buildNotificationCard(
                    context,
                    imagePath: 'assets/food1.png',
                    distance: '75m',
                    message: [
                      const TextSpan(text: 'Gayatri is taking your '),
                      const TextSpan(
                        text: 'paneer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    subMessage: [
                      const TextSpan(text: 'Giving you '),
                      const TextSpan(
                        text: 'palak paneer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' in return'),
                    ],
                    actions: [
                      _buildActionButton('Chat', appColor, Colors.white),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Suggestions',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: FontFamily.openSans,
                            color: context.textColor,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.filter_list_outlined,
                                size: 18.sp, color: context.textColor),
                            SizedBox(width: 4.w),
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                                fontFamily: FontFamily.openSans,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildNotificationCard(
                    context,
                    imagePath: 'assets/mobile1.png',
                    distance: '75m',
                    message: [
                      const TextSpan(text: 'Riya is giving '),
                      const TextSpan(
                        text: 'Samsung S10 Ultra',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    subMessage: [
                      TextSpan(
                        text: '(Permanent - Mobile - Like new)',
                        style: TextStyle(
                          color: context.subTextColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                    actions: [
                      _buildActionButton('Take', appColor, Colors.white),
                      SizedBox(width: 8.w),
                      _buildActionButton(
                          'Ignore', Colors.blue.withOpacity(0.1), appColor),
                    ],
                  ),
                  _buildNotificationCard(
                    context,
                    imagePath: 'assets/veg1.png',
                    distance: '75m',
                    message: [
                      const TextSpan(text: 'Suyash is taking '),
                      const TextSpan(
                        text: 'Bhaji',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    subMessage: [
                      TextSpan(
                        text: 'Giving Grocery in return',
                        style: TextStyle(
                          color: context.subTextColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                    actions: [
                      _buildActionButton('Give', appColor, Colors.white),
                      SizedBox(width: 8.w),
                      _buildActionButton(
                          'Ignore', Colors.blue.withOpacity(0.1), appColor),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
      ),
      centerTitle: true,
      title: Text(
        'Notifications',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: Divider(height: 1, color: greyColor.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
          color: context.textColor,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String imagePath,
    required String distance,
    required List<TextSpan> message,
    required List<TextSpan> subMessage,
    required List<Widget> actions,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  imagePath,
                  width: 85.w,
                  height: 75.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 85.w,
                    height: 75.w,
                    color: context.isDarkMode
                        ? Colors.white10
                        : Colors.grey.shade200,
                    child: Icon(Icons.image,
                        color: context.isDarkMode
                            ? Colors.white24
                            : Colors.grey.shade400),
                  ),
                ),
              ),
              Positioned(
                top: 6.h,
                left: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: blackColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    distance,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.textColor,
                      fontFamily: FontFamily.openSans,
                    ),
                    children: message,
                  ),
                ),
                SizedBox(height: 2.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.subTextColor,
                      fontFamily: FontFamily.openSans,
                    ),
                    children: subMessage,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(children: actions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: ShimmerBox(height: 20.h, width: 80.w),
          ),
          SizedBox(height: 12.h),
          _buildShimmerCard(context),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(height: 20.h, width: 100.w),
                ShimmerBox(height: 15.h, width: 60.w),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildShimmerCard(context),
          _buildShimmerCard(context),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 70.w, width: 70.w, radius: 12.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14.h, width: 180.w),
                SizedBox(height: 6.h),
                ShimmerBox(height: 12.h, width: 140.w),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    ShimmerBox(height: 25.h, width: 60.w, radius: 6.r),
                    SizedBox(width: 8.w),
                    ShimmerBox(height: 25.h, width: 60.w, radius: 6.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
