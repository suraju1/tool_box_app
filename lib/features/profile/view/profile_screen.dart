import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/core/widgets/logout_dialog.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/view/setting_screen.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/firebase_notification_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({
    super.key,
    this.isTab = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUserId = context.read<AuthController>().currentUser?.id;
      if (currentUserId != null) {
        final success = await context
            .read<ProfileController>()
            .getUserProfile(currentUserId, isOwnProfile: true);
        // Sync name and profile image to Firestore so chat screens show the real avatar
        if (success && mounted) {
          final profile = context.read<ProfileController>().ownProfile;
          FirebaseNotificationService.syncProfileData(
            fullName: profile?.userDetails.fullName,
            profileImageUrl: profile?.userDetails.image,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final profile = profileController.ownProfile;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: (profileController.isLoading ||
              (profile == null && profileController.errorMessage == null))
          ? _buildShimmer(context)
          : profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profileController.errorMessage ??
                            'User profile not found',
                        style: TextStyle(color: context.textColor),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final currentUserId =
                              context.read<AuthController>().currentUser?.id;
                          if (currentUserId != null) {
                            context
                                .read<ProfileController>()
                                .getUserProfile(currentUserId);
                          }
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context, profile),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 15.h),
                            _buildBioSection(profile),
                            SizedBox(height: 15.h),
                            _buildReviewsSection(profile),
                            SizedBox(height: 15.h),
                            _buildTradeHistoryStats(context, profile),
                            SizedBox(height: 15.h),
                            _buildSettingsList(context),
                            //SizedBox(height: 15.h),
                            // _logoutButton(context),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ],
                  ),
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
              color: context.appBarColor,
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
                              radius: 10.r,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: ShimmerBox(
                              height: 100.h,
                              width: double.infinity,
                              radius: 10.r,
                            ),
                          ),
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
                                      height: 1,
                                      color: Colors.grey.withOpacity(0.1)),
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

  Widget _buildHeader(BuildContext context, UserProfileModel profile) {
    final user = profile.userDetails;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        border: Border(
          bottom: BorderSide(color: context.dividerColor, width: 1.w),
        ),
      ),
      padding: EdgeInsets.fromLTRB(25.w, 50.h, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              if (!widget.isTab && Navigator.of(context).canPop())
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.arrow_back_ios,
                      color: context.textColor, size: 20.sp),
                ),
              Text(
                'Profile',
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.menu, color: context.textColor, size: 28.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.dividerColor, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48.r),
                      child: AppCachedImage(
                        imageUrl: user.image ?? '',
                        userName: user.fullName,
                        width: 96.r,
                        height: 96.r,
                        fit: BoxFit.cover,
                        radius: 48.r,
                        placeholderBgColor:
                            context.primaryColor.withOpacity(0.1),
                        placeholderTextColor: context.textColor,
                      ),
                    ),
                  ),
                  // hide camera icon from here
                  // Positioned(
                  //   bottom: 2.h,
                  //   right: 6.w,
                  //   child: Container(
                  //     padding: EdgeInsets.all(4.w),
                  //     decoration: BoxDecoration(
                  //       color: context.surfaceColor,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: Icon(Icons.camera_alt,
                  //         color: context.primaryColor, size: 16.sp),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    Text(
                      user.location ?? 'No location provided',
                      style: TextStyle(
                        color: context.subTextColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wallet, color: Colors.orange, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Wallet Balance ',
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 10.sp,
                              fontFamily: FontFamily.openSans,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹120.00',
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(UserProfileModel profile) {
    if (profile.userDetails.bio == null || profile.userDetails.bio!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor),
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
            profile.userDetails.bio!,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: greyColor,
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

  Widget _buildReviewsSection(UserProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.dividerColor),
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
                    '${profile.userDetails.averageRating} (${profile.userDetails.totalReviews} Reviews)',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor),
                  ),
                ],
              ),
            ],
          ),
          if (profile.reviews.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No reviews yet',
                style: TextStyle(color: greyColor, fontSize: 13.sp),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  profile.reviews.length > 3 ? 3 : profile.reviews.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) =>
                  _buildReviewItem(profile.reviews[index]),
            ),
            if (profile.reviews.length > 3) ...[
              SizedBox(height: 5.h),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full reviews screen if needed
                },
                child: Text(
                  'View All Reviews',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    fontFamily: FontFamily.openSans,
                    color: context.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: InkWell(
        onTap: () {
          ProfileController.navigateToUserProfile(context, review.reviewerId);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: context.primaryColor.withOpacity(0.1), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: AppCachedImage(
                  imageUrl: review.reviewerImage ?? '',
                  userName: review.reviewerName,
                  width: 50.r,
                  height: 50.r,
                  fit: BoxFit.cover,
                  radius: 25.r,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewerName,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) {
                        final ratingValue = review.rating is int
                            ? review.rating
                            : int.tryParse(review.rating.toString()) ?? 0;
                        return Icon(
                          index < ratingValue ? Icons.star : Icons.star_border,
                          color: index < ratingValue ? Colors.amber : greyColor,
                          size: 14.sp,
                        );
                      },
                    ),
                  ),
                  if (review.comment != null)
                    Text(
                      review.comment!,
                      style: TextStyle(fontSize: 12.sp, color: greyColor),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_outlined,
                          size: 14.sp, color: greyColor),
                      SizedBox(width: 12.w),
                      Icon(Icons.thumb_down_outlined,
                          size: 14.sp, color: greyColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeHistoryStats(
      BuildContext context, UserProfileModel profile) {
    final stats = profile.tradeStats;
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
                    'Total Gives',
                    stats.totalGives.toString(),
                    Colors.red,
                    Icons.card_giftcard),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard(
                    'Total Takes',
                    stats.totalTakes.toString(),
                    Colors.orange,
                    Icons.redeem_outlined),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard(
                    'Total Trades',
                    stats.totalTrades.toString(),
                    Colors.orange,
                    Icons.handshake),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.tradeHistory);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50.w),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'View Trade History',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: context.onPrimaryColor,
                ),
              ),
            ),
          ),
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
              color: context.primaryColor,
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

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
        children: [
          _buildProfileSettingItem(
            context,
            icon: Icons.wb_sunny_outlined,
            label: 'Themes',
            onTap: () => Navigator.pushNamed(context, AppRoutes.themeChange),
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.card_membership_outlined,
            label: 'My Subscription',
            onTap: () => Navigator.pushNamed(context, AppRoutes.mySubscription),
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.sync_alt,
            label: 'Transaction History',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.transactionHistory),
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.bookmark_border,
            label: 'Saved Profiles',
            onTap: () {},
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.block_outlined,
            label: 'Blocked Users',
            onTap: () => Navigator.pushNamed(context, AppRoutes.blockedUsers),
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingScreen()),
            ),
          ),
          _buildDivider(),
          _buildProfileSettingItem(
            context,
            icon: Icons.login_outlined,
            label: 'Logout',
            onTap: () => showDialog(
              context: context,
              builder: (context) => const LogoutDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettingItem(
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
