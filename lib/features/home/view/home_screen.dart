import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/location/view/location_selection_sheet.dart';
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/features/notifications/controller/notification_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/core/widgets/theme_selection_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationController = context.read<LocationController>();
      final tradeController = context.read<TradeController>();

      // Check for first-time user to show theme selection
      final firstUser = await StorageService.getFirstuser();
      if (firstUser == null && mounted) {
        ThemeSelectionBottomSheet.show(context);
      }

      // Reset filters when navigating to this screen
      tradeController.resetFilters();

      // Sync user-selected location (loaded from Hive in LocationController)
      tradeController.setLocation(
        locationController.latitude,
        locationController.longitude,
      );

      tradeController.fetchHomePosts();

      // Fetch unread notification count
      if (mounted) {
        context.read<NotificationController>().fetchUnreadCount();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<TradeController>().loadMoreHomePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: 25.h),
          _buildHeader(context),
          Expanded(
            child: Consumer<TradeController>(
              builder: (context, controller, child) {
                // Proactively sync location from LocationController if it exists but is missing in TradeSontroller
                final locationController = context.read<LocationController>();
                if (locationController.hasLocation && !controller.hasLocation) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setLocation(
                      locationController.latitude,
                      locationController.longitude,
                    );
                  });
                }

                if (controller.isHomeLoading && controller.homePosts.isEmpty) {
                  return _buildShimmer(context);
                }

                if (controller.errorMessage != null &&
                    controller.homePosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage!),
                        ElevatedButton(
                          onPressed: () => controller.fetchHomePosts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchHomePosts(refresh: true);
                  },
                  child: Column(
                    children: [
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      _buildDistanceSection(context),
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      Expanded(
                        child: controller.homePosts.isEmpty &&
                                !controller.isHomeLoading
                            ? ListView(
                                children: [
                                  SizedBox(height: 50.h),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off,
                                            size: 64.sp, color: Colors.grey),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'No posts found matching your filters',
                                          style: TextStyle(
                                            color: context.subTextColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 8.h),
                                itemCount: controller.homePosts.length +
                                    (controller.isHomeLoadMoreRunning ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 6.h),
                                itemBuilder: (context, index) {
                                  if (index == controller.homePosts.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return _buildProductCard(
                                    context,
                                    controller.homePosts[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        bottom: 4.h,
      ),
      decoration: BoxDecoration(
        color: context.appBarColor,
      ),
      child: Column(
        children: [
          // dont shgow logo here
          // Image.asset(
          //   'assets/logo_transperant.png',
          //   height: 40.h,
          //   color: context.isDarkMode ? Colors.white : Colors.black,
          // ),
          //SizedBox(height: 6.h),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: context.textColor,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Consumer<LocationController>(
                builder: (context, locationController, child) {
                  return Expanded(
                    child: InkWell(
                      onTap: () async {
                        await LocationSelectionSheet.show(context);
                        // After selection, update trade controller location and refresh
                        if (mounted) {
                          context.read<TradeController>().setLocation(
                                locationController.latitude,
                                locationController.longitude,
                              );
                          context.read<TradeController>().fetchHomePosts();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              locationController.address ?? 'NA',
                              style: TextStyle(
                                color: context.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            margin: EdgeInsets.only(right: 25.w),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: context.textColor,
                              size: 26.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              //no need to show this filter button currently on home screen
              // InkWell(
              //   onTap: () => showModalBottomSheet(
              //     context: context,
              //     isScrollControlled: true,
              //     backgroundColor: Colors.transparent,
              //     builder: (context) =>
              //         const FilterBottomSheet(initialPostType: 'all'),
              //   ),
              //   child: Container(
              //     clipBehavior: Clip.antiAlias,
              //     margin: EdgeInsets.only(left: 8.w),
              //     padding:
              //         EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.2),
              //       borderRadius: BorderRadius.circular(8.r),
              //     ),
              //     child: SvgPicture.asset(
              //       'assets/filter_icon.svg',
              //       width: 20.w,
              //       height: 20.h,
              //       colorFilter:
              //           const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              //     ),
              //   ),
              // ),
              //SizedBox(width: 1.w),
              Consumer<NotificationController>(
                builder: (context, notificationController, child) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          color: context.textColor,
                          size: 28.sp,
                        ),
                        if (notificationController.unreadCount > 0)
                          Positioned(
                            right: 0.w,
                            top: 2.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.h,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                notificationController.unreadCount > 99
                                    ? '99+'
                                    : notificationController.unreadCount
                                        .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // distance section
  Widget _buildDistanceSection(BuildContext context) {
    return Consumer<TradeController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: context.surfaceColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      padding: EdgeInsets.zero,
                      value: controller.distanceKm,
                      min: 0,
                      max: 50,
                      activeColor: context.primaryColor,
                      inactiveColor: Colors.grey.shade200,
                      thumbColor: context.primaryColor,
                      onChanged: (val) {
                        controller.setDistance(
                          val,
                          triggerFetch: true,
                          fetchType: 'all',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${controller.distanceKm.round()} km',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                controller.hasLocation
                    ? 'Show items near you'
                    : 'Set your location to enable distance filtering',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: controller.hasLocation ? greyColor : Colors.orange,
                  fontWeight: controller.hasLocation
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';

    // Determine action label based on post type
    // If it's a "give_away" (give), the user can "Take" it.
    // If it's a "taking" (take) request, the user can "Give" it.
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';
    final authController = context.read<AuthController>();
    final isOwner = authController.currentUser?.id == post.userId;
    final actionLabel = isOwner ? 'Offers' : (isTake ? 'Give' : 'Take');

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
                    color: greyColor.withOpacity(0.4),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${post.userName}'s ${isTake ? 'Taking' : 'Giving'}",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 11.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              post.itemName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: context.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.label_outline,
                                  color: Colors.grey,
                                  size: 13.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${post.itemCategory}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                    fontFamily: FontFamily.openSans,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            post.distanceKm != null
                                ? '${post.distanceKm!.toStringAsFixed(1)} km away'
                                : '- km away',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 14 / 9,
              child: Container(
                color: Colors.blue.withOpacity(
                  0.1,
                ), // Fixed withValues to withOpacity for compatibility if needed, or keeping withValues if on new Flutter
                child: imagePath.isNotEmpty
                    ? AppCachedImage(
                        imageUrl: imagePath,
                        fit: BoxFit.fill,
                        width: 1.sw - 44.w,
                        height: (1.sw - 44.w) * 9 / 14,
                        radius: 0,
                        errorWidget:
                            Icon(Icons.image, size: 50.sp, color: Colors.grey),
                      )
                    : Icon(Icons.image, size: 50.sp, color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: post.userImage != null &&
                                      post.userImage!.isNotEmpty
                                  ? AppCachedImage(
                                      imageUrl: post.userImage!,
                                      userName: post.userName,
                                      width: 20.r,
                                      height: 20.r,
                                      fit: BoxFit.cover,
                                      radius: 10.r,
                                    )
                                  : _buildLetterPlaceholder(
                                      post.userName, 20.r),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                "${post.userName}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: context.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // dont show the rating
                        // SizedBox(height: 4.h),
                        // Row(
                        //   children: [
                        //     Text(
                        //       "${post.userRating ?? 4.8} ", // Real rating or fallback
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 12.sp,
                        //         color: context.textColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 4.w),
                        //     ...List.generate(
                        //       5,
                        //       (index) => Icon(
                        //         Icons.star,
                        //         color: amberColor,
                        //         size: 13.sp,
                        //       ),
                        //     ),
                        //     SizedBox(width: 4.w),
                        //     Text(
                        //       "(Person rating)",
                        //       style: TextStyle(
                        //         color: Colors.grey,
                        //         fontSize: 11.sp,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (isOwner) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                          arguments: post.id,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productDetails,
                          arguments: post.id,
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 34.w,
                        vertical: 7.h,
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          color: context.onPrimaryColor,
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

  Widget _buildShimmer(BuildContext context) {
    return Column(
      children: [
        // Distance Section Shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 18.h, width: 80.w),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ShimmerBox(height: 20.h, width: double.infinity),
                  ),
                  SizedBox(width: 10.w),
                  ShimmerBox(height: 18.h, width: 40.w),
                ],
              ),
              SizedBox(height: 8.h),
              ShimmerBox(height: 12.h, width: 120.w),
            ],
          ),
        ),
        Divider(color: context.dividerColor, thickness: 1.h, height: 1.h),
        // Product Card Shimmers
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(height: 11.h, width: 80.w),
                              SizedBox(height: 4.h),
                              ShimmerBox(height: 16.h, width: 150.w),
                            ],
                          ),
                          ShimmerBox(height: 14.h, width: 60.w),
                        ],
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 14 / 9,
                      child: ShimmerBox(
                        height: double.infinity,
                        width: double.infinity,
                        radius: 0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(height: 16.h, width: 120.w),
                              SizedBox(height: 4.h),
                              ShimmerBox(height: 16.h, width: 100.w),
                            ],
                          ),
                          ShimmerBox(height: 35.h, width: 100.w, radius: 6.r),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.trim().isNotEmpty
            ? name.trim().substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          color: context.primaryColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
