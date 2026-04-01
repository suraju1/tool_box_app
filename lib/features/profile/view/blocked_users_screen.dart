import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/blocked_user_model.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:intl/intl.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final blockedUsers = profileController.blockedUsers;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Blocked Users',
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
      body: profileController.isLoading && blockedUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInfoBanner(context),
                Expanded(
                  child: blockedUsers.isEmpty
                      ? Center(
                          child: Text(
                            'No blocked users',
                            style: TextStyle(
                              color: context.subTextColor,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              profileController.getBlockedUsers(),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            itemCount: blockedUsers.length,
                            itemBuilder: (context, index) =>
                                _buildBlockedUserItem(
                                    context, blockedUsers[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.primaryColor.withOpacity(0.1)
            : const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info, color: context.primaryColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Blocked users will not be able to see your posts or contact you.',
              style: TextStyle(
                color: context.isDarkMode
                    ? Colors.white70
                    : const Color(0xFF42526E),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserItem(BuildContext context, BlockedUserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
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
      child: InkWell(
        onTap: () => ProfileController.navigateToUserProfile(context, user.id),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: AppCachedImage(
                      imageUrl: user.profileImage ?? '',
                      userName: user.fullName,
                      width: 56.r,
                      height: 56.r,
                      radius: 30.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.r),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 14.sp,
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
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${user.avgStars} (${user.totalRatings} Reviews)',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.subTextColor,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                      ],
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        user.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.subTextColor,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ],
                    if (user.blockedAt.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Blocked on: ${DateFormat('dd MMM yyyy').format(DateTime.parse(user.blockedAt))}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.subTextColor.withOpacity(0.7),
                          fontFamily: FontFamily.openSans,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (user.location != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        user.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.subTextColor,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 32.h,
                child: OutlinedButton(
                  onPressed: () => _showUnblockBottomSheet(context, user),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  child: Text(
                    'Unblock',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnblockBottomSheet(BuildContext context, BlockedUserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: AppCachedImage(
                  imageUrl: user.profileImage ?? '',
                  userName: user.fullName,
                  width: 100.r,
                  height: 100.r,
                  radius: 50.r,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Are you sure you want to',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              Text(
                'unblock ${user.fullName}?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final response = await context
                            .read<ProfileController>()
                            .unblockUser(user.id);
                        if (response.success) {
                          if (mounted) {
                            ToastService.showSuccessToast(
                                context, response.message);
                          }
                        } else {
                          if (mounted) {
                            ToastService.showErrorToast(
                                context, response.message);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Unblock',
                        style: TextStyle(
                          color: context.onPrimaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.surfaceColor,
                        foregroundColor: context.textColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(color: context.dividerColor),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
