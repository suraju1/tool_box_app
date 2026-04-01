import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/model/saved_user_model.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class SavedUsersScreen extends StatefulWidget {
  const SavedUsersScreen({super.key});

  @override
  State<SavedUsersScreen> createState() => _SavedUsersScreenState();
}

class _SavedUsersScreenState extends State<SavedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getSavedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final savedUsers = profileController.savedUsers;
    final isLoading = profileController.isLoading && savedUsers.isEmpty;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Saved Users',
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
      body: isLoading
          ? _buildShimmerGrid()
          : savedUsers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<ProfileController>().getSavedUsers(),
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                    ),
                    itemCount: savedUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(context, savedUsers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildUserCard(BuildContext context, SavedUserModel user) {
    return InkWell(
      onTap: () {
        ProfileController.navigateToUserProfile(context, user.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: greyColorWithOpacity0_4,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(color: context.dividerColor),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: AppCachedImage(
                      imageUrl: user.profileImage ?? '',
                      userName: user.fullName,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () async {
                        final response = await context
                            .read<ProfileController>()
                            .toggleSaveUser(user.id);
                        if (response.success && mounted) {
                          ToastService.showSuccessToast(
                              context, response.message);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: context.surfaceColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: context.primaryColor,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: greyColor, size: 12.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          user.location ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.subTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            user.avgStars,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                            ),
                          ),
                          Text(
                            ' (${user.totalRatings})',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: context.subTextColor,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 60.sp, color: greyColor),
          SizedBox(height: 15.h),
          Text(
            'No saved users yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: context.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Profiles you save will appear here',
            style: TextStyle(
              fontSize: 12.sp,
              color: context.subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            children: [
              Expanded(
                child: ShimmerBox(
                  height: double.infinity,
                  width: double.infinity,
                  radius: 15.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14.h, width: 100.w),
                    SizedBox(height: 5.h),
                    ShimmerBox(height: 10.h, width: 80.w),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
