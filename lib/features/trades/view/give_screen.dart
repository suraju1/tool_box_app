import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/filter_bottom_sheet.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart'; // Import for ScrollDirection
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';

class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends State<GiveScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
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

      tradeController.fetchGivePosts();
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<TradeController>().loadMoreGivePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Builder(builder: (context) {
        // Proactively sync location from LocationController if it exists but is missing in TradeController
        final locationController = context.read<LocationController>();
        final controller = context.read<TradeController>();
        if (locationController.hasLocation && !controller.hasLocation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.setLocation(
              locationController.latitude,
              locationController.longitude,
            );
          });
        }

        return tradeController.isGiveLoading &&
                tradeController.givePosts.isEmpty
            ? _buildShimmer(context)
            : Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(context),
                      Divider(
                        color: context.dividerColor,
                        height: 0.h,
                        thickness: 0.5,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<TradeController>()
                                .fetchGivePosts(refresh: true);
                          },
                          child: tradeController.givePosts.isEmpty &&
                                  !tradeController.isGiveLoading
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
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(
                                      10.w, 8.h, 10.w, 100.h),
                                  itemCount: tradeController.givePosts.length +
                                      1 +
                                      (tradeController.isGiveLoadMoreRunning
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return _buildResultHeader(context,
                                          tradeController.givePosts.length);
                                    }

                                    if (index ==
                                        tradeController.givePosts.length + 1) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(
                                              color: defoultColor),
                                        ),
                                      );
                                    }

                                    final post =
                                        tradeController.givePosts[index - 1];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8.h),
                                      child: _buildProductCard(
                                        context,
                                        id: post.id,
                                        title: post.itemName,
                                        owner: post.userName.isNotEmpty
                                            ? post.userName
                                            : 'User ${post.userId}',
                                        category: post.itemCategory,
                                        distance: post.distanceKm != null
                                            ? '${post.distanceKm!.toStringAsFixed(1)} km away'
                                            : '- km away',
                                        rating: '4.5',
                                        actionLabel:
                                            post.postType.toLowerCase() ==
                                                    'give'
                                                ? 'Take'
                                                : 'Give',
                                        description: post.itemNote,
                                        imagePath: post.itemImages.isNotEmpty
                                            ? post.itemImages.first
                                            : null,
                                        postType: post.postType,
                                      ),
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
                        color: context.surfaceColor,
                        boxShadow: [
                          BoxShadow(
                            color: greyColorWithOpacity0_4,
                            offset: const Offset(0, -2),
                            blurRadius: 4,
                          ),
                        ],
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
                              color: defoultColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.createGivePost,
                                  arguments: "Create Give Post",
                                ).then((_) {
                                  // Refresh logic handled by controller's optimistic update
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 6.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: whiteColor, size: 28.sp),
                                    Text(
                                      "Make a New Post",
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 14.sp,
                                        fontFamily: FontFamily.openSans,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }

  Widget _buildResultHeader(BuildContext context, int count) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h),
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
          10.w, MediaQuery.of(context).padding.top + 8.h, 10.w, 8.h),
      color: context.scaffoldBg,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? Colors.white10
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context
                          .read<TradeController>()
                          .setSearchQuery(value, type: 'give');
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      hintText: 'Search any Product..',
                      hintStyle: TextStyle(
                          color: context.subTextColor, fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search,
                          color: context.subTextColor, size: 20.sp),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      const FilterBottomSheet(initialPostType: 'give'),
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
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: defoultColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: SvgPicture.asset(
        'assets/filter_icon.svg',
        width: 24.w,
        height: 24.h,
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required int id,
    required String title,
    required String owner,
    required String category,
    required String distance,
    required String rating,
    required String actionLabel,
    String? description,
    String? imagePath,
    String? postType,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.productDetails, arguments: id);
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
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
              child: imagePath != null
                  ? AppCachedImage(
                      imageUrl: '${ApiConstants.baseUrl2}$imagePath',
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
                          "$owner's ${postType?.toLowerCase() == 'give' ? 'Giving' : 'Taking'}",
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
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: greyColor),
                          SizedBox(width: 2.w),
                          Text(
                            distance,
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
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.openSans,
                      color: defoultColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      description,
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
                      Icon(Icons.person, color: defoultColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "$owner ",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                              WidgetSpan(
                                child: SizedBox(width: 4.w),
                              ),
                              TextSpan(
                                text: "\u2022 $category",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: context.textColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(Icons.star,
                              color: Colors.amber, size: 16.sp);
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: id,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 34.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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

  Widget _buildShimmer(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10.w, 80.h, 10.w, 8.h),
          color: context.scaffoldBg,
          child: Row(
            children: [
              Expanded(child: ShimmerBox(height: 45.h, width: double.infinity)),
              SizedBox(width: 12.w),
              ShimmerBox(height: 45.h, width: 45.h, radius: 8.r),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.all(10.w),
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
                              radius: 4.r),
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
