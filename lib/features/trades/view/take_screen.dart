import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';

import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/widgets/filter_bottom_sheet.dart';
import 'package:tool_bocs/core/widgets/popup_menu_arrow_shape.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class TakeScreen extends StatefulWidget {
  const TakeScreen({super.key});

  @override
  State<TakeScreen> createState() => _TakeScreenState();
}

class _TakeScreenState extends State<TakeScreen> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationController = context.read<LocationController>();
      final tradeController = context.read<TradeController>();

      // Reset filters when navigating to this screen
      tradeController.resetFilters();

      // Sync user-selected location (loaded from Hive in LocationController)
      tradeController.setLocation(
        locationController.latitude,
        locationController.longitude,
      );

      tradeController.fetchTakePosts();
    });
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<TradeController>().loadMoreTakePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Consumer<TradeController>(
        builder: (context, controller, child) {
          // Proactively sync location from LocationController if it exists but is missing in TradeController
          final locationController = context.read<LocationController>();
          if (locationController.hasLocation && !controller.hasLocation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.setLocation(
                locationController.latitude,
                locationController.longitude,
              );
            });
          }

          if (controller.isTakeLoading && controller.takePosts.isEmpty) {
            return _buildShimmer(context);
          }

          if (controller.errorMessage != null && controller.takePosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage!),
                  ElevatedButton(
                    onPressed: () => controller.fetchTakePosts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 15.h),
                  _buildHeader(context),
                  Divider(
                    color: context.dividerColor,
                    height: 0.h,
                    thickness: 0.5,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await controller.fetchTakePosts(refresh: true);
                      },
                      child: controller.takePosts.isEmpty &&
                              !controller.isTakeLoading
                          ? ListView(
                              children: [
                                SizedBox(height: 100.h),
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
                              padding:
                                  EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 100.h),
                              itemCount: controller.takePosts.length +
                                  (controller.isTakeLoadMoreRunning ? 1 : 0),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 6.h),
                              itemBuilder: (context, index) {
                                if (index == controller.takePosts.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (index == 0) {
                                  return Column(
                                    children: [
                                      _buildResultHeader(
                                        context,
                                        controller.takePosts.length,
                                      ),
                                      _buildProductCard(
                                        context,
                                        controller.takePosts[index],
                                      ),
                                    ],
                                  );
                                }

                                return _buildProductCard(
                                  context,
                                  controller.takePosts[index],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80.h,
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    color: Colors.transparent,
                    // color: context.surfaceColor,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: greyColorWithOpacity0_4,
                    //     offset: const Offset(0, -2),
                    //     blurRadius: 4,
                    //   ),
                    // ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.h),
                      Container(
                        width: 180.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: context.primaryColor,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.createGivePost,
                              arguments: "Create Take Post",
                            ).then((_) {
                              // Refresh logic handled by controller's optimistic update
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,
                                    color: context.onPrimaryColor, size: 28.sp),
                                Text(
                                  "Make a New Post",
                                  style: TextStyle(
                                    color: context.onPrimaryColor,
                                    fontSize: 14.sp,
                                    fontFamily: FontFamily.openSans,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, int count) {
    return Container(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Text(
            'Nearby Items',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const Spacer(),
          Text(
            '(Showing $count Results)',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          8.w, MediaQuery.of(context).padding.top + 6.h, 8.w, 6.h),
      color: context.scaffoldBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF5F7F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: context.isDarkMode
                            ? Colors.white24
                            : Colors.grey.shade300,
                        width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context
                          .read<TradeController>()
                          .setSearchQuery(value, type: 'take');
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      hintText: 'Search what you want to take',
                      hintStyle: TextStyle(
                        color: context.subTextColor,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.subTextColor,
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<void>(
                offset: const Offset(-200, 50),
                shape: PopupMenuArrowShape(borderRadius: 12.r),
                color: Colors.white,
                elevation: 4,
                itemBuilder: (context) => [
                  PopupMenuItem<void>(
                    enabled: false,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          '• See what people are giving around you',
                          '• See existing posts by givers around you',
                          '• Respond to posts, Mention what you can offer in return',
                        ]
                            .map((text) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: const Color(0xFF111311),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.openSans,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                child: Container(
                  margin: EdgeInsets.only(left: 8.w),
                  height: 45.h,
                  width: 45.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF5F7F9),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: context.isDarkMode
                          ? Colors.white24
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: context.primaryColor,
                    size: 22.sp,
                  ),
                ),
              ),
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      const FilterBottomSheet(initialPostType: 'take'),
                ),
                child: _buildFilterButton(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 45.h,
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: SvgPicture.asset(
        'assets/filter_icon.svg',
        width: 24.w,
        height: 24.h,
        colorFilter: ColorFilter.mode(
          context.onPrimaryColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: post.id,
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: [
            BoxShadow(
              color: greyColorWithOpacity0_4,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 136.w,
              height: 154.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: imagePath.isNotEmpty
                  ? AppCachedImage(
                      imageUrl: imagePath,
                      width: 136.w,
                      height: 154.w,
                      fit: BoxFit.cover,
                      radius: 12.r,
                      errorWidget:
                          Image.asset('assets/iphone.png', fit: BoxFit.cover),
                    )
                  : Image.asset('assets/iphone.png', fit: BoxFit.cover),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${post.userName}'s Taking",
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: context.subTextColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.openSans,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: greyColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            post.distanceKm != null
                                ? '${post.distanceKm!.toStringAsFixed(1)} km away'
                                : '- km away',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: context.subTextColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    post.itemName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.openSans,
                      color: context.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.label_outline,
                          size: 13.sp, color: context.subTextColor),
                      SizedBox(width: 4.w),
                      Text(
                        post.itemCategory,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.subTextColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ],
                  ),
                  if (post.itemNote.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      post.itemNote,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: context.subTextColor,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontFamily.openSans,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.person,
                          color: context.primaryColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          post.userName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.textColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.openSans,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  //dont show rating
                  // SizedBox(height: 2.h),
                  // Row(
                  //   children: [
                  //     Text(
                  //       post.userRating?.toString() ?? '4.8',
                  //       style: TextStyle(
                  //         fontSize: 12.sp,
                  //         fontWeight: FontWeight.w600,
                  //         fontFamily: FontFamily.openSans,
                  //         color: context.textColor,
                  //       ),
                  //     ),
                  //     SizedBox(width: 4.w),
                  //     Row(
                  //       children: List.generate(5, (index) {
                  //         return Icon(
                  //           Icons.star,
                  //           color: Colors.amber,
                  //           size: 16.sp,
                  //         );
                  //       }),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 3.h),
                  (() {
                    final authController = context.read<AuthController>();
                    final isOwner =
                        authController.currentUser?.id == post.userId;
                    final actionLabel = isOwner
                        ? 'Offers'
                        : (post.postType.toLowerCase() == 'give' ||
                                post.postType.toLowerCase() == 'giving'
                            ? 'Take'
                            : 'Give');

                    return InkWell(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 34.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          actionLabel,
                          style: TextStyle(
                            color: context.onPrimaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    );
                  })(),
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
        Container(
          padding: EdgeInsets.fromLTRB(8.w, 80.h, 8.w, 4.h),
          color: context.scaffoldBg,
          child: Row(
            children: [
              Expanded(
                child: ShimmerBox(height: 45.h, width: double.infinity),
              ),
              SizedBox(width: 12.w),
              ShimmerBox(height: 45.h, width: 45.h, radius: 8.r),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.dividerColor),
                ),
                child: Row(
                  children: [
                    ShimmerBox(height: 154.w, width: 136.w, radius: 12.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(height: 10.h, width: 60.w),
                              ShimmerBox(height: 10.h, width: 50.w),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 18.h, width: 120.w),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 12.h, width: 100.w),
                          SizedBox(height: 12.h),
                          ShimmerBox(height: 15.h, width: 130.w),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 15.h, width: 80.w),
                          SizedBox(height: 12.h),
                          ShimmerBox(
                            height: 30.h,
                            width: double.infinity,
                            radius: 4.r,
                          ),
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
