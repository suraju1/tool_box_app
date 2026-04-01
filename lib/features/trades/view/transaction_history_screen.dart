import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/wallet_controller.dart';
import 'package:tool_bocs/features/trades/model/wallet_history_model.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().fetchWalletHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Consumer<WalletController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => controller.fetchWalletHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.walletHistory.isEmpty) {
            return Center(
              child: Text(
                'No transactions found',
                style: TextStyle(
                  color: context.textColor.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchWalletHistory(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              itemCount: controller.walletHistory.length,
              itemBuilder: (context, index) {
                final transaction = controller.walletHistory[index];
                return _buildTransactionCard(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor),
      ),
      centerTitle: true,
      title: Text(
        'Transaction History',
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

  Widget _buildTransactionCard(WalletHistory transaction) {
    final post = transaction.post;
    final imageUrl =
        (post?.images.isNotEmpty ?? false) ? post!.images.first : '';

    // Parse date
    DateTime? date;
    String formattedDate = transaction.deductionDate;
    try {
      date = DateTime.parse(transaction.deductionDate);
      formattedDate =
          DateFormat('dd MMM yyyy • hh:mm a').format(date.toLocal());
    } catch (e) {
      // Use raw string if parsing fails
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColorWithOpacity0_4,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.w,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  ),
          ),
          SizedBox(width: 12.w),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post?.name ?? 'Transaction',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
                if (post?.category != null || post?.type != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      if (post?.type != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: (post!.type.toLowerCase() == 'give' ||
                                    post.type.toLowerCase() == 'giving')
                                ? const Color(0xFFE3F2FD)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            post.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: FontFamily.openSans,
                              color: (post.type.toLowerCase() == 'give' ||
                                      post.type.toLowerCase() == 'giving')
                                  ? const Color(0xFF1976D2)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      if (post?.category != null)
                        Expanded(
                          child: Text(
                            post!.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontFamily.openSans,
                              color: context.textColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontFamily.openSans,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Amount
          Text(
            '—₹${transaction.amount}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.openSans,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }
}
