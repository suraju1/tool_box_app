import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int postId;
  const ProductDetailsScreen({super.key, required this.postId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchPostDetails(widget.postId);
    });
  }

  void _startAutoPlay(int imageCount) {
    _autoPlayTimer?.cancel(); // Cancel existing timer if any
    if (imageCount <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentImageIndex + 1) % imageCount;
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.textColor,
            size: 20.sp,
          ),
        ),
        centerTitle: true,
        title: Consumer<TradeController>(
          builder: (context, controller, child) {
            return Text(
              controller.selectedPost?.itemName ?? 'Product Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.openSans,
                color: context.textColor,
              ),
            );
          },
        ),
        actions: [
          //report and block
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              // Handle selection
            },
            offset: const Offset(0, 55),
            shape: PopupMenuArrowShape(borderRadius: 10.r),
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
      body: Consumer<TradeController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final post = controller.selectedPost;
          if (post == null) {
            return const Center(child: Text('Post not found'));
          }

          // Start autoplay if not started and multiple images
          if (_autoPlayTimer == null && post.itemImages.length > 1) {
            _startAutoPlay(post.itemImages.length);
          }

          final List<String> images =
              post.itemImages.isNotEmpty ? post.itemImages : [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildOwnerProfile(post),
                SizedBox(height: 20.h),
                if (images.isNotEmpty)
                  _buildImageCarousel(images)
                else
                  Container(
                    height: 320.h,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50.sp,
                      color: Colors.grey,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_buildCategoryTag(post.itemCategory)],
                      ),
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
                        post.itemNote.isNotEmpty
                            ? post.itemNote
                            : 'No description provided.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.subTextColor,
                          height: 1.6,
                          fontFamily: FontFamily.openSans,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: context.dividerColor),
                          boxShadow: context.isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Item Condition',
                              post.itemCondition,
                            ),
                            SizedBox(height: 10.h),
                            _buildDetailRow('Trade Type', post.tradeType),
                            SizedBox(height: 10.h),
                            _buildDetailRow('Return Type', post.returnType),
                            SizedBox(height: 10.h),
                            _buildDetailRow('Location', post.pickupArea),
                            if (post.returnType == 'Price') ...[
                              SizedBox(height: 10.h),
                              _buildDetailRow(
                                'Price Range',
                                '\$${post.priceMin} - \$${post.priceMax}',
                              ),
                            ] else if (post.returnType == 'Item') ...[
                              SizedBox(height: 20.h),
                              Text(
                                'Return Item Details',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.openSans,
                                  color: context.textColor,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              if (post.returnItemImages.isNotEmpty) ...[
                                SizedBox(
                                  height: 100.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.returnItemImages.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 8.w),
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: Image.network(
                                          '${ApiConstants.baseUrl2}${post.returnItemImages[index]}',
                                          height: 100.h,
                                          width: 100.h,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 100.h,
                                            width: 100.h,
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 15.h),
                              ],
                              if (post.returnItemName != null)
                                _buildDetailRow(
                                  'Item Name',
                                  post.returnItemName!,
                                ),
                              if (post.returnItemCategory != null) ...[
                                SizedBox(height: 8.h),
                                _buildDetailRow(
                                  'Category',
                                  post.returnItemCategory!,
                                ),
                              ],
                              if (post.returnItemCondition != null) ...[
                                SizedBox(height: 8.h),
                                _buildDetailRow(
                                  'Condition',
                                  post.returnItemCondition!,
                                ),
                              ],
                              if (post.returnItemDescription != null &&
                                  post.returnItemDescription!.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.subTextColor,
                                        fontFamily: FontFamily.openSans,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      post.returnItemDescription!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: context.textColor,
                                        fontFamily: FontFamily.openSans,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<TradeController>(
        builder: (context, controller, child) {
          final post = controller.selectedPost;
          if (post == null) return const SizedBox.shrink();

          return Container(
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
                (post.postType.toLowerCase() == 'take' ||
                        post.postType.toLowerCase() == 'taking')
                    ? 'Give It'
                    : 'Take It',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imagePath = images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.network(
                      '${ApiConstants.baseUrl2}$imagePath',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/iphone.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: context.subTextColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerProfile(post) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
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
              child: post.userImage != null && post.userImage!.isNotEmpty
                  ? Image.network(
                      '${ApiConstants.baseUrl2}${post.userImage}',
                      width: 56.r,
                      height: 56.r,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/profile2.png',
                        width: 56.r,
                        height: 56.r,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
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
                        post.userName.isNotEmpty
                            ? post.userName
                            : 'User id-${post.userId}',
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
                          (post.postType.toLowerCase() == 'take' ||
                                  post.postType.toLowerCase() == 'taking')
                              ? 'Taking'
                              : 'Giving',
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
                        post.userRating?.toString() ?? '4.8',
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
