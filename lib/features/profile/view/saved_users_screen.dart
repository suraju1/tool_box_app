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
          'Saved Profiles',
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
          ? Center(child: CircularProgressIndicator(color: context.primaryColor))
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<ProfileController>().getSavedUsers(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildAllSavedCard(context, savedUsers),
                    SizedBox(height: 20.h),
                    _buildCreateFolderCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAllSavedCard(BuildContext context, List<SavedUserModel> savedUsers) {
    final dividerColor = context.dividerColor.withOpacity(0.3);
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Saved',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                    fontFamily: FontFamily.openSans,
                  ),
                ),
                Text(
                  '${savedUsers.length}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textColor.withOpacity(0.8),
                    fontFamily: FontFamily.openSans,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          savedUsers.isEmpty 
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  itemCount: savedUsers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final user = savedUsers[index];
                    return _buildProfileListItem(context, user);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildProfileListItem(BuildContext context, SavedUserModel user) {
    final dividerColor = context.dividerColor.withOpacity(0.3);
    return InkWell(
      onTap: () {
        ProfileController.navigateToUserProfile(context, user.id);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: AppCachedImage(
                imageUrl: user.profileImage ?? '',
                userName: user.fullName,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.cover,
                radius: 24.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                user.fullName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontFamily.openSans,
                  color: context.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateFolderCard(BuildContext context) {
    final dividerColor = context.dividerColor.withOpacity(0.3);
    return Container(
      height: 350.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: dividerColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                ToastService.showSuccessToast(context, "Create folder feature coming soon!");
              },
              borderRadius: BorderRadius.circular(50.r),
              child: Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  size: 32.sp,
                  color: context.textColor,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Create New Folder',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: context.textColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 60.sp, color: greyColor),
            SizedBox(height: 15.h),
            Text(
              'No saved users yet',
              style: TextStyle(
                fontSize: 18.sp,
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
