import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/core/widgets/logout_dialog.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/core/widgets/user_review_dialog.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final shimmer = context.watch<ShimmerController>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: shimmer.isLoading
          ? _buildShimmer(context)
          : SingleChildScrollView(
              child: Column(children: [
                _buildHeader(context),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 15.h),
                      _buildBioSection(),
                      SizedBox(height: 15.h),
                      //rate this person now button
                      _buildRateThisPersonButton(context),

                      SizedBox(height: 15.h),
                      _buildReviewsSection(),
                      SizedBox(height: 15.h),
                      _buildTradeHistoryStats(context),
                      SizedBox(height: 20.h),
                      // _buildSettingsList(context),
                      _saveUserButton(context),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ]),
            ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Shimmer
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: defoultColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
            padding: EdgeInsets.fromLTRB(25.w, 50.h, 25.w, 40.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(height: 24.h, width: 100.w),
                    ShimmerBox(height: 30.h, width: 80.w, radius: 8.r),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    ShimmerBox(height: 96.r, width: 96.r, radius: 48.r),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(height: 24.h, width: 120.w),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 16.h, width: 150.w),
                          SizedBox(height: 12.h),
                          ShimmerBox(height: 32.h, width: 140.w, radius: 10.r),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 15.h),
                // Bio Section Shimmer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 20.h, width: 60.w),
                      SizedBox(height: 12.h),
                      ShimmerBox(height: 14.h, width: double.infinity),
                      SizedBox(height: 8.h),
                      ShimmerBox(height: 14.h, width: double.infinity),
                      SizedBox(height: 8.h),
                      ShimmerBox(height: 14.h, width: 200.w),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // Reviews Section Shimmer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(height: 20.h, width: 140.w),
                          ShimmerBox(height: 16.h, width: 100.w),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          ShimmerBox(height: 50.r, width: 50.r, radius: 25.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerBox(height: 16.h, width: 100.w),
                                SizedBox(height: 8.h),
                                ShimmerBox(height: 12.h, width: 80.w),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // Trade History Shimmer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ShimmerBox(height: 20.h, width: 120.w),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Expanded(
                              child: ShimmerBox(
                                  height: 100.h,
                                  width: double.infinity,
                                  radius: 10.r)),
                          SizedBox(width: 16.w),
                          Expanded(
                              child: ShimmerBox(
                                  height: 100.h,
                                  width: double.infinity,
                                  radius: 10.r)),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ShimmerBox(
                          height: 100.h, width: double.infinity, radius: 10.r),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // Settings List Shimmer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: List.generate(
                        5,
                        (index) => Column(
                              children: [
                                Row(
                                  children: [
                                    ShimmerBox(
                                        height: 24.h, width: 24.w, radius: 4.r),
                                    SizedBox(width: 16.w),
                                    ShimmerBox(height: 18.h, width: 150.w),
                                    const Spacer(),
                                    ShimmerBox(
                                        height: 16.h, width: 16.w, radius: 8.r),
                                  ],
                                ),
                                if (index < 4) ...[
                                  SizedBox(height: 12.h),
                                  Divider(
                                      height: 1, color: context.dividerColor),
                                  SizedBox(height: 12.h),
                                ],
                              ],
                            )),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: defoultColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              Text(
                'Profile',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              //report and block
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  // Handle selection
                },
                offset: const Offset(0, 55),
                shape: PopupMenuArrowShape(
                  borderRadius: 10.r,
                ),
                color: context.surfaceColor,
                elevation: 4,
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    // padding: EdgeInsets.zero,
                    value: 'block',
                    height: 40.h,
                    child: Center(
                      child: Text(
                        'Block',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuDivider(height: 1),
                  PopupMenuItem<String>(
                    value: 'report',
                    height: 40.h,
                    child: Center(
                      child: Text(
                        'Report',
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                  ),
                ],
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Icon(
                    Icons.more_vert,
                    color: whiteColor,
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 48.r,
                backgroundImage: const AssetImage('assets/profile2.png'),
              ),
              SizedBox(height: 10.h),
              Text(
                'Riya',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              Text(
                'Pune, Maharashtra',
                style: TextStyle(
                  color: whiteColor.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.openSans,
              color: context.textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Entrepreneur | Passionate about sustainable living | Love connecting with people for meaningful exchanges. Always looking for unique items to give and take.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: context.subTextColor,
              fontSize: 12.sp,
              height: 1.3,
              fontFamily: FontFamily.openSans,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor, width: 1.w),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '4.8 (12 Reviews)',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildReviewItem(),
          Divider(color: context.dividerColor),
          _buildReviewItem(),
          Divider(color: context.dividerColor),
          _buildReviewItem(),
          SizedBox(height: 5.h),
          TextButton(
            onPressed: () {},
            child: Text(
              'Reviews & Ratings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                fontFamily: FontFamily.openSans,
                color: defoultColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: const AssetImage('assets/profile1.png'),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rajesh Kumar',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textColor),
                ),
                Row(
                  children: List.generate(
                      5,
                      (index) =>
                          Icon(Icons.star, color: Colors.amber, size: 14.sp)),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Excellent service! The item was exactly as described and the handover was smooth.',
                  style:
                      TextStyle(fontSize: 12.sp, color: context.subTextColor),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined,
                        size: 14.sp, color: context.subTextColor),
                    SizedBox(width: 12.w),
                    Icon(Icons.thumb_down_outlined,
                        size: 14.sp, color: context.subTextColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeHistoryStats(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Trade History',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.openSans,
                color: context.textColor,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Total Gives', '35', Colors.red, Icons.card_giftcard),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard(
                    'Total Takes', '28', Colors.orange, Icons.redeem_outlined),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard(
                    'Total Trades', '63', Colors.orange, Icons.handshake),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white10 : greyColor.withOpacity(0.1),
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: defoultColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: context.textColor,
              fontWeight: FontWeight.w500,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveUserButton(BuildContext context) {
    bool isSaved = false;
    return GestureDetector(
      onTap: () {
        setState(() {
          isSaved = !isSaved;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 60.w),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
          color: defoultColor,
          borderRadius: BorderRadius.circular(8.r),
          //border: Border.all(color: greyColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 25.sp,
              color: whiteColor,
            ),
            SizedBox(width: 8.w),
            Text(
              isSaved ? 'Saved' : 'Save User',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: whiteColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

// commented
  Widget _buildSettingsList(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSettingsItem(context, Icons.settings_outlined, 'Settings'),
          Divider(height: 1, color: greyColor.withOpacity(0.4), thickness: 1),
          _buildSettingsItem(context, Icons.wb_sunny_outlined, 'Theme'),
          Divider(height: 1, color: greyColor.withOpacity(0.4), thickness: 1),
          _buildSettingsItem(
              context, Icons.visibility_outlined, 'Visibility options'),
          Divider(height: 1, color: greyColor.withOpacity(0.4), thickness: 1),
          _buildSettingsItem(context, Icons.person_outline, 'Account Centre'),
          Divider(height: 1, color: greyColor.withOpacity(0.4), thickness: 1),
          _buildSettingsItem(
              context, Icons.messenger_outline, 'Report a Problem'),
          Divider(height: 1, color: greyColor.withOpacity(0.4), thickness: 1),
          _buildSettingsItem(context, Icons.logout, 'Logout', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String label,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : context.textColor),
      title: Text(label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.openSans,
            color: isLogout ? Colors.red : context.textColor,
          )),
      trailing: isLogout
          ? null
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.textColor,
            ),
      onTap: () {
        if (isLogout) {
          showDialog(
            context: context,
            builder: (context) => const LogoutDialog(),
          );
        }
      },
    );
  }

  _buildRateThisPersonButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const UserReviewDialog(),
        );
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        margin: EdgeInsets.symmetric(horizontal: 45.w),
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: greyColorWithOpacity0_4,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Rate This Person',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.openSans,
            color: whiteColor,
          ),
        ),
      ),
    );
  }
}

class PopupMenuArrowShape extends ShapeBorder {
  final double borderRadius;
  final double arrowWidth;
  final double arrowHeight;

  const PopupMenuArrowShape({
    this.borderRadius = 12.0,
    this.arrowWidth = 16.0,
    this.arrowHeight = 10.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
        rect.topLeft + Offset(0, arrowHeight), rect.bottomRight);
    final double x = rect.width - 24; // Position arrow near the right side

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)))
      ..moveTo(x - arrowWidth / 2, rect.top)
      ..lineTo(x, rect.top - arrowHeight)
      ..lineTo(x + arrowWidth / 2, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
