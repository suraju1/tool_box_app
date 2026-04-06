import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/skeleton_widgets.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/util/date_util.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.appBarColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
        ),
        title: Text(
          'My Posts',
          style: TextStyle(
            color: context.textColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProfileController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.myPosts.isEmpty) {
            return _buildLoadingState();
          }

          if (controller.errorMessage != null && controller.myPosts.isEmpty) {
            return _buildErrorState(controller.errorMessage!);
          }

          if (controller.myPosts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => controller.getMyPosts(),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              itemCount: controller.myPosts.length,
              separatorBuilder: (context, index) => SizedBox(height: 6.h),
              itemBuilder: (context, index) {
                return _buildPostCard(context, controller.myPosts[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: const ProductCardSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: context.textColor, fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<ProfileController>().getMyPosts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'You haven\'t created any posts yet',
            style: TextStyle(
              color: context.subTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Create a post to start trading!',
            style: TextStyle(
              color: greyColor,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createGivePost),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(
              'Create Post',
              style: TextStyle(
                  color: context.onPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: post.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: greyColor.withOpacity(0.2),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTake ? 'Taking' : 'Giving',
                          style: TextStyle(
                            color: isTake ? Colors.orange : Colors.green,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          post.itemName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: context.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(Icons.label_outline,
                                color: Colors.grey, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              post.itemCategory,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(post.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                          color: _getStatusColor(post.status).withOpacity(0.5)),
                    ),
                    child: Text(
                      post.status,
                      style: TextStyle(
                        color: _getStatusColor(post.status),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imagePath.isNotEmpty
                  ? AppCachedImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      radius: 0,
                    )
                  : Container(
                      color: context.dividerColor,
                      child: Icon(Icons.image, size: 48.sp, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        DateUtil.formatTimeAgo(post.createdAt),
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notifications,
                        arguments: post.id,
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'View Offers',
                        style: TextStyle(
                          color: context.onPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
