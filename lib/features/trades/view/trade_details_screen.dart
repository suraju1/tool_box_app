import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class TradeDetailsScreen extends StatefulWidget {
  const TradeDetailsScreen({super.key});

  @override
  State<TradeDetailsScreen> createState() => _TradeDetailsScreenState();
}

class _TradeDetailsScreenState extends State<TradeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final response = tradeController.selectedResponse;
    final post = tradeController.selectedPost;

    if (response == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('No trade selected')),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainItemCard(response, post),
            SizedBox(height: 14.h),
            _buildSectionTitle('Trade With'),
            SizedBox(height: 8.h),
            _buildUserCard(response),
            SizedBox(height: 14.h),
            _buildSectionTitle('Exchange Details'),
            SizedBox(height: 8.h),
            _buildExchangeCard(response, post),
            SizedBox(height: 14.h),
            _buildSectionTitle('Trade Info'),
            SizedBox(height: 8.h),
            _buildTradeInfoCard(response),
            SizedBox(height: 14.h),
            _buildSectionTitle('Trade Notes'),
            SizedBox(height: 8.h),
            _buildNotesCard(response),
            // SizedBox(height: 24.h),
            // _buildRatingCard(),
            // SizedBox(height: 40.h),
            // _buildReportButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
      ),
      centerTitle: true,
      title: Text(
        'Trade Details',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(10.h),
        child: Divider(
          height: 1.h,
          color: context.dividerColor,
          thickness: 1.h,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  Widget _buildMainItemCard(TradeResponseModel response, dynamic post) {
    final itemName = post?.itemName ?? response.postItemName ?? 'Trade Item';
    final images = post?.itemImages ?? response.postItemImages ?? [];
    final imageUrl = images.isNotEmpty
        ? (images.first.startsWith('http')
            ? images.first
            : '${ApiConstants.baseUrl2}${images.first}')
        : '';
    final isGive = post?.postType == 'give';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          imageUrl.isNotEmpty
              ? AppCachedImage(
                  imageUrl: imageUrl,
                  width: 80.w,
                  height: 80.w,
                  radius: 12.r,
                  fit: BoxFit.cover,
                  errorWidget: Image.asset('assets/iphone.png',
                      width: 80.w, height: 80.w, fit: BoxFit.cover),
                )
              : Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    image: const DecorationImage(
                      image: AssetImage('assets/iphone.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildBadge(
                        isGive ? 'Give' : 'Take',
                        context.isDarkMode
                            ? Colors.blue.withOpacity(0.15)
                            : const Color(0xFFE8F1FF),
                        const Color(0xFF2F80ED)),
                    SizedBox(width: 8.w),
                    _buildBadge(
                        response.status.toUpperCase(),
                        context.isDarkMode
                            ? Colors.green.withOpacity(0.15)
                            : const Color(0xFFE8F9EE),
                        const Color(0xFF27AE60)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildUserCard(TradeResponseModel response) {
    final userName = response.posterName ?? 'User';
    final userRole = 'Partner';
    final userImage = response.posterImage ?? '';
    final imageUrl = userImage.isNotEmpty
        ? (userImage.startsWith('http')
            ? userImage
            : '${ApiConstants.baseUrl2}$userImage')
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            userName: userName,
            width: 56.r,
            height: 56.r,
            radius: 28.r,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
                Text(
                  userRole,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.subTextColor,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                          5,
                          (index) =>
                              Icon(Icons.star, color: amberColor, size: 16.sp)),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final authController = context.read<AuthController>();
              final currentUserId = authController.currentUser?.id;

              // If current user is responder, they want to view poster's profile
              // If current user is poster, they want to view responder's profile
              int partnerId;
              if (currentUserId == response.responderId) {
                partnerId = response.posterUserId;
              } else {
                partnerId = response.responderId;
              }

              ProfileController.navigateToUserProfile(context, partnerId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.onPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(TradeResponseModel response, dynamic post) {
    final isTicketPost = post?.postType == 'give' &&
        (post?.returnType == 'price' || response.responseType == 'price');
    final itemName = isTicketPost
        ? (response.priceRangeStart != null
            ? '${response.priceRangeStart} - ${response.priceRangeEnd} Tickets'
            : 'Tickets')
        : (response.itemName ?? 'Exchange Item');

    final images = response.itemImages;
    final imageUrl = images.isNotEmpty
        ? (images.first.startsWith('http')
            ? images.first
            : '${ApiConstants.baseUrl2}${images.first}')
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.dividerColor),
            ),
            child: imageUrl.isNotEmpty
                ? AppCachedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    radius: 12.r,
                  )
                : Icon(
                    isTicketPost ? Icons.confirmation_number : Icons.inventory,
                    color: context.primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Value',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.subTextColor,
                  ),
                ),
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeInfoCard(TradeResponseModel response) {
    // Note: These fields are currently placeholders as they aren't fully present in the base model
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_outlined,
              'Date: ${response.createdAt.split(' ').first}'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.access_time, 'Status: ${response.status}'),
          // SizedBox(height: 12.h),
          // _buildInfoRow(
          //     Icons.location_on_outlined, 'Payment: ${response.paymentStatus}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: context.subTextColor, size: 20.sp),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: context.subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(TradeResponseModel response) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_outlined,
              color: context.subTextColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              response.itemDescription ?? 'No additional notes provided.',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: context.subTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            'Review and Rating',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.openSans,
              color: context.textColor,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (index) =>
                    Icon(Icons.star, color: context.dividerColor, size: 32.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.dividerColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(
          'Report Trade',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: context.subTextColor,
          ),
        ),
      ),
    );
  }
}
