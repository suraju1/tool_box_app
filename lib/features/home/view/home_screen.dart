import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/location/view/location_selection_sheet.dart';
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double distance = 5.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchHomePosts();
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
    // Keeping ShimmerController for now if it's used globally, but TradeController has its own loading state.
    // We can use TradeController's loading state for the list part.
    // final shimmer = context.watch<ShimmerController>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<TradeController>(
              builder: (context, controller, child) {
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
                      _buildDistanceSection(context),
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16.w),
                          itemCount: controller.homePosts.length +
                              (controller.isHomeLoadMoreRunning ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
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
        top: MediaQuery.of(context).padding.top + 20.h,
        left: 16.w,
        right: 16.w,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
        color: themeColor, // Use themeColor from colors.dart
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Consumer<LocationController>(
                builder: (context, locationController, child) {
                  return Expanded(
                    child: InkWell(
                      onTap: () => LocationSelectionSheet.show(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              locationController.address ?? 'NA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Container(
                            //width: 20.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            margin: EdgeInsets.only(right: 25.w),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              InkWell(
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
                      color: Colors.white,
                      size: 28.sp,
                    ),
                    Positioned(
                      right: 0.w,
                      top: 2.h,
                      child: Container(
                        width: 15.w,
                        height: 15.h,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          '1',
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
              ),
            ],
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  // distance section
  Widget _buildDistanceSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        // borderRadius: BorderRadius.circular(8.r), // Removed radius to match flat look if desired in list
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
                  value: distance,
                  min: 0,
                  max: 50,
                  activeColor: defoultColor,
                  inactiveColor: Colors.grey.shade200,
                  thumbColor: defoultColor,
                  onChanged: (val) => setState(() => distance = val),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '${distance.round()} km',
                style: TextStyle(color: context.textColor),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            'Show items near you',
            style: TextStyle(fontSize: 10.sp, color: greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';
    final imageUrl =
        imagePath.isNotEmpty ? '${ApiConstants.baseUrl2}$imagePath' : '';

    // Determine action label based on post type
    // If it's a "give_away" (give), the user can "Take" it.
    // If it's a "taking" (take) request, the user can "Give" it.
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';
    final actionLabel = isTake ? 'Give' : 'Take';

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
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${post.userName}'s ${isTake ? 'Taking' : 'Giving'}",
                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                      ),
                      Text(
                        post.itemName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '2.5 km away', // Placeholder distance
                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image, size: 50.sp, color: Colors.grey),
                      )
                    : Icon(Icons.image, size: 50.sp, color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: themeColor, size: 16.sp),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                "${post.userName}  •  ${post.itemCategory}",
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
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              "${post.userRating ?? 4.8} ", // Real rating or fallback
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            ...List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                color: amberColor,
                                size: 13.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "(Person rating)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: post.id,
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeColor,
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
                          color: Colors.white,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
            padding: EdgeInsets.all(16.w),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.dividerColor),
                ),
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
}
