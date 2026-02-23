import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/widgets/filter_bottom_sheet.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchTakePosts();
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
      context.read<TradeController>().loadMoreTakePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can use a Selector or Consumer. Consumer is fine here.
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Consumer<TradeController>(
        builder: (context, controller, child) {
          // Initial loading state (only when list is empty)
          if (controller.isTakeLoading && controller.takePosts.isEmpty) {
            return _buildShimmer(context);
          }

          // Error state
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
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                        itemCount: controller.takePosts.length +
                            (controller.isTakeLoadMoreRunning ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          if (index == controller.takePosts.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // Optional: Add header showing results count if it's the first item
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
              // Create Post Button section
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
                                Icon(Icons.add, color: whiteColor, size: 28.sp),
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Text(
            'Available Items', // Generic title since filtered by "Take"
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
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 15.h),
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
                    decoration: InputDecoration(
                      hintText: 'Search any Product..',
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
              InkWell(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FilterBottomSheet(),
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

  Widget _buildProductCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';
    final imageUrl =
        imagePath.isNotEmpty ? '${ApiConstants.baseUrl2}$imagePath' : '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: post.id,
        );
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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
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
                      Text(
                        "${post.userName}'s Taking",
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: context.subTextColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: greyColor,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '2.5 km away', // Placeholder for distance
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
                      color: context.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Icon(Icons.person, color: defoultColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${post.userName} ",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: context.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                              WidgetSpan(child: SizedBox(width: 4.w)),
                              TextSpan(
                                text: "\u2022 ${post.itemCategory}",
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
                        '4.8', // Placeholder rating
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
                          return Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.sp,
                          );
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
                        arguments: post.id,
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
                        post.postType.toLowerCase() == 'give' ||
                                post.postType.toLowerCase() == 'giving'
                            ? 'Take'
                            : 'Give', // Action Label
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
          padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 15.h),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
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
