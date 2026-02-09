import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class ProductDetailsScreen extends StatefulWidget {
  final List<String>? images;
  const ProductDetailsScreen({super.key, this.images});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  late final List<String> _imageList;

  @override
  void initState() {
    super.initState();
    _imageList = widget.images ??
        [
          'assets/iphone.png',
          'assets/iphone.png',
          'assets/iphone.png',
          'assets/iphone.png'
        ];
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_imageList.length > 1 && _pageController.hasClients) {
        int nextIndex = (_currentImageIndex + 1) % _imageList.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,
              color: context.textColor, size: 20.sp),
        ),
        centerTitle: true,
        title: Text(
          'IPhone 12 (128GB)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        actions: [
          //report and block
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              // Handle selection
            },
            offset: const Offset(0, 55),
            shape: PopupMenuArrowShape(
              borderRadius: 10.r,
            ),
            color: context.surfaceColor,
            elevation: 4,
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                // padding: EdgeInsets.zero,
                value: 'block',
                height: 40.h,
                child: Center(
                  child: Text(
                    'Block',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                ),
              ),
              PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'report',
                height: 40.h,
                child: Center(
                  child: Text(
                    'Report',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                ),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Icon(
                Icons.more_vert,
                color: context.textColor,
                size: 28.sp,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(height: 1, color: context.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildOwnerProfile(),
            SizedBox(height: 20.h),
            _buildImageCarousel(),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTag('Electronics'),
                  SizedBox(height: 15.h),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.openSans,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'This iPhone 12 is in excellent condition, barely used, with no scratches or dents. It comes with 128GB storage, perfect for all your apps and media. Battery health is at 95%. Includes original box and charging cable. Selling because I upgraded to a newer model. Ready for a new home!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.subTextColor,
                      height: 1.6,
                      fontFamily: FontFamily.openSans,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          border: Border(top: BorderSide(color: context.dividerColor)),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.tradeStep1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: appColor,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Take It',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        Container(
          height: 320.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: _imageList.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      _imageList[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
              if (_imageList.length > 1)
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_imageList.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentImageIndex == index ? 8.w : 6.w,
                        height: _currentImageIndex == index ? 8.w : 6.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildOwnerProfile() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: greyColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
              child: Image.asset(
                'assets/profile2.png',
                width: 56.r,
                height: 56.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Riya',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E1FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Giving',
                          style: TextStyle(
                            color: const Color(0xFF6B4EE0),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(Person rating)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontFamily.openSans,
                          color: context.subTextColor,
                        ),
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
}
