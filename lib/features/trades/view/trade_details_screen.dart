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
  final int? tradeId;
  const TradeDetailsScreen({super.key, this.tradeId});

  @override
  State<TradeDetailsScreen> createState() => _TradeDetailsScreenState();
}

class _TradeDetailsScreenState extends State<TradeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.tradeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TradeController>()
            .fetchTradeHistoryDetails(widget.tradeId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final response = tradeController.selectedResponse;
    final isLoading = tradeController.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (response == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No trade selected'),
              if (tradeController.errorMessage != null)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    tradeController.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.tradeId != null) {
            await context
                .read<TradeController>()
                .fetchTradeHistoryDetails(widget.tradeId!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainItemCard(response),
              SizedBox(height: 14.h),
              _buildSectionTitle('Trade With'),
              SizedBox(height: 8.h),
              _buildUserCard(response),
              SizedBox(height: 14.h),
              _buildSectionTitle('Exchange Details'),
              SizedBox(height: 8.h),
              _buildExchangeCard(response),
              SizedBox(height: 14.h),
              _buildSectionTitle('Trade Info'),
              SizedBox(height: 8.h),
              _buildTradeInfoCard(response),
              SizedBox(height: 14.h),
              _buildSectionTitle('Trade Notes'),
              SizedBox(height: 8.h),
              _buildNotesCard(response),
              SizedBox(height: 20.h),
            ],
          ),
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

  Widget _buildMainItemCard(TradeResponseModel response) {
    final itemName =
        response.postItemName ?? response.givingItemName ?? 'Trade Item';
    final images = response.postItemImages.isNotEmpty
        ? response.postItemImages
        : (response.givingItemImages ?? []);
    final imageUrl = images.isNotEmpty
        ? (images.first.startsWith('http')
            ? images.first
            : '${ApiConstants.baseUrl2}${images.first}')
        : '';
    final isGive = response.postType == 'give' || response.postType == 'giving';

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
                )
              : Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: context.dividerColor.withOpacity(0.1),
                  ),
                  child: Icon(Icons.image, color: context.dividerColor),
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
                        response.status == 'completed'
                            ? (context.isDarkMode
                                ? Colors.green.withOpacity(0.15)
                                : const Color(0xFFE8F9EE))
                            : (context.isDarkMode
                                ? Colors.orange.withOpacity(0.15)
                                : const Color(0xFFFFF4E8)),
                        response.status == 'completed'
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF2994A)),
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
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;

    // Identify the partner
    final isPoster = currentUserId == response.posterUserId;
    final partnerName =
        isPoster ? (response.responderName) : (response.posterName ?? 'Poster');
    final partnerImage = isPoster
        ? (response.responderImage ?? '')
        : (response.posterImage ?? '');

    final imageUrl = partnerImage.isNotEmpty
        ? (partnerImage.startsWith('http')
            ? partnerImage
            : '${ApiConstants.baseUrl2}$partnerImage')
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
            userName: partnerName,
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
                  partnerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
                Text(
                  isPoster ? 'Responder' : 'Poster',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.subTextColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              int partnerId =
                  isPoster ? response.responderId : response.posterUserId;
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

  Widget _buildExchangeCard(TradeResponseModel response) {
    final isTicketTrade =
        response.responseType == 'price' || response.postReturnType == 'Price';

    String exchangeLabel = 'Exchange Item';
    String exchangeValue =
        response.itemName ?? response.givingItemName ?? 'Item';
    IconData exchangeIcon = Icons.inventory_2_outlined;

    if (isTicketTrade) {
      exchangeLabel = 'Exchange Tickets';
      if (response.offerPrice != null && response.offerPrice! > 0) {
        exchangeValue = '${response.offerPrice} Tickets';
      } else if (response.priceRangeStart != null) {
        exchangeValue =
            '${response.priceRangeStart} - ${response.priceRangeEnd} Tickets';
      } else if (response.paymentAmount != null) {
        exchangeValue = '${response.paymentAmount} Tickets';
      } else {
        exchangeValue = 'Tickets';
      }
      exchangeIcon = Icons.confirmation_number_outlined;
    }

    final images = response.itemImages.isNotEmpty
        ? response.itemImages
        : (response.givingItemImages ?? []);
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
            child: imageUrl.isNotEmpty && !isTicketTrade
                ? AppCachedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    radius: 8.r,
                  )
                : Icon(exchangeIcon, color: context.primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exchangeLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.subTextColor,
                  ),
                ),
                Text(
                  exchangeValue,
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
    String formattedDate = response.createdAt;
    if (formattedDate.contains('T')) {
      formattedDate = formattedDate.split('T').first;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_outlined, 'Date: $formattedDate'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.access_time_outlined,
              'Status: ${response.status.toUpperCase()}'),
          if (response.meetingType != null) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.handshake_outlined,
                'Meeting: ${response.meetingType!.replaceAll('_', ' ').toUpperCase()}'),
          ],

          //dont show this
          // if (response.paymentAmount != null ||
          //     (response.offerPrice != null && response.offerPrice! > 0)) ...[
          //   SizedBox(height: 12.h),
          //   _buildInfoRow(Icons.payments_outlined,
          //       'Final Amount: ${response.paymentAmount ?? response.offerPrice} Tickets'),
          // ],
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
    String notes = response.itemDescription ?? 'No additional notes provided.';
    if (response.rejectedReason != null) {
      notes = 'Rejected Reason: ${response.rejectedReason}\n\n$notes';
    }

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
              notes,
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
}
