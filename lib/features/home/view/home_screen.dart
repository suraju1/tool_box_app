import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/location/view/location_selection_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double distance = 5.0;

  @override
  Widget build(BuildContext context) {
    final shimmer = context.watch<ShimmerController>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: shimmer.isLoading
                ? _buildShimmer(context)
                : Column(
                    children: [
                      _buildDistanceSection(context),
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            _buildProductCard(
                              context,
                              title: 'iPhone 12 (128GB)',
                              owner: 'RIYA',
                              category: 'Food Giver',
                              distance: '2.5 km away',
                              rating: '4.8',
                              actionLabel: 'Take',
                            ),
                            SizedBox(height: 12.h),
                            _buildProductCard(
                              context,
                              title: 'iPhone 12 (128GB)',
                              owner: 'RIYA',
                              category: 'Food Giver',
                              distance: '2.5 km away',
                              rating: '4.8',
                              actionLabel: 'Take',
                            ),
                            SizedBox(height: 12.h),
                            _buildProductCard(
                              context,
                              title: 'iPhone 12 (128GB)',
                              owner: 'RIYA',
                              category: 'Food Giver',
                              distance: '2.5 km away',
                              rating: '4.8',
                              actionLabel: 'Take',
                            ),
                          ],
                        ),
                      ),
                    ],
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
              Icon(Icons.location_on_outlined,
                  color: Colors.white, size: 20.sp),
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
                            // decoration: BoxDecoration(
                            //   color: Colors.transparent,
                            //   border: Border.all(color: Colors.white),
                            //   borderRadius: BorderRadius.circular(6),
                            // ),
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
              // Spacer handles pushing remaining items to the right if any
              // or just rely on Expanded taking available space
              /*
              // chat icon
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Icon(Icons.chat_outlined, color: Colors.white, size: 28.sp),
                    Positioned(
                      right: 0.w,
                      top: 0.h,
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
                    )
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              */
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                },
                child: Stack(
                  children: [
                    Icon(Icons.notifications_none_outlined,
                        color: Colors.white, size: 28.sp),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          /*
          SizedBox(height: 18.h),
         
          Row(
            children: [
              Expanded(
                child: Container(
                  // height: 45.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search any Product..',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14.sp),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterBottomSheet(),
                    );
                  },
                  child: Container(
                    height: 47.h,
                    width: 47.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.tune, color: themeColor, size: 24.sp),
                  ),
                ),
              ),
            ],
          ),
          */
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
        borderRadius: BorderRadius.circular(8.r),
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
                style: TextStyle(
                  color: context.textColor,
                ),
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

  Widget _buildProductCard(
    BuildContext context, {
    required String title,
    required String owner,
    required String category,
    required String distance,
    required String rating,
    required String actionLabel,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
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
                        "$owner's Taking",
                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                      ),
                      Text(
                        title,
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
                      Icon(Icons.location_on_outlined,
                          color: Colors.grey, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        distance,
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
                color: Colors.blue.withValues(alpha: 0.1),
                child: Image.asset(
                  "assets/iphone.png",
                  // child: Image.network(
                  //   'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-12-blue-select-2020?wid=940&hei=1112&fmt=png-alpha&.v=1604343704000',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image, size: 50.sp, color: Colors.grey),
                ),
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
                      Row(
                        children: [
                          Icon(Icons.person, color: themeColor, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            "$owner  •  $category",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                color: context.textColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            "$rating ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: context.textColor),
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
                            style:
                                TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, AppRoutes.chat);
                      Navigator.pushNamed(context, AppRoutes.dummyChat);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 34.w, vertical: 7.h),
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
                      child: ShimmerBox(height: 20.h, width: double.infinity)),
                  SizedBox(width: 10.w),
                  ShimmerBox(height: 18.h, width: 40.w),
                ],
              ),
              SizedBox(height: 8.h),
              ShimmerBox(height: 12.h, width: 120.w),
            ],
          ),
        ),
        Divider(
          color: context.dividerColor,
          thickness: 1.h,
          height: 1.h,
        ),
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
                          radius: 0),
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
