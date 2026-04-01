import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TradeHistoryScreen extends StatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen> {
  String selectedFilter = ' All ';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchMyTrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shimmer = context.watch<ShimmerController>();
    final tradeController = context.watch<TradeController>();

    return Scaffold(
      backgroundColor:
          context.isDarkMode ? Colors.black : const Color(0xFFF8F9FB),
      appBar: _buildAppBar(context),
      body: (shimmer.isLoading || tradeController.isMyTradesLoading)
          ? _buildShimmer(context)
          : RefreshIndicator(
              onRefresh: () async {
                await tradeController.fetchMyTrades();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTradeSummary(),
                    _buildFilters(),
                    _buildHistoryList(),
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
        icon: Icon(Icons.arrow_back_ios, color: context.textColor),
      ),
      centerTitle: true,
      title: Text(
        'Trade History',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildTradeSummary() {
    final stats = context.watch<TradeController>().myTradeStats;
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trade Summary',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard('${stats?.totalGives ?? 0}', 'Total Gives',
                  '🎁', Colors.red.shade100),
              _buildSummaryCard('${stats?.totalTakes ?? 0}', 'Total Takes',
                  '📦', Colors.orange.shade100),
              _buildSummaryCard('${stats?.totalTrades ?? 0}', 'Total Trades',
                  '🤝', Colors.blue.shade100),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String count, String label, String emoji, Color bgColor) {
    return Container(
      width: 115.w,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 5.w),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.subTextColor,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterChip(' All '),
          _buildFilterChip(' Gives '),
          _buildFilterChip(' Takes '),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
        String postType = 'all';
        if (label.trim() == 'Gives') postType = 'give';
        if (label.trim() == 'Takes') postType = 'take';
        context.read<TradeController>().fetchMyTrades(postType: postType);
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: isSelected ? context.primaryColor : context.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? context.onPrimaryColor : context.subTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final trades = context.watch<TradeController>().myTrades;

    if (trades.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_outlined, size: 50.sp, color: Colors.grey),
              SizedBox(height: 10.h),
              Text(
                'No trade history found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        bool isGive = trade.postType == 'give';

        String otherUser = isGive
            ? (trade.responderName ?? 'No responder yet')
            : (trade.posterName ?? 'Unknown Giver');
        String roleLabel = isGive ? 'Taker' : 'Giver';

        String dateStr = trade.createdAt;
        try {
          final date = DateTime.parse(trade.createdAt);
          dateStr = "${date.day} ${_getMonth(date.month)} ${date.year}";
        } catch (_) {}

        return _buildHistoryItem(
          trade.id,
          trade.itemName,
          'With $otherUser ($roleLabel)',
          dateStr,
          trade.status[0].toUpperCase() + trade.status.substring(1),
          isGive,
          trade.itemImages.isNotEmpty ? trade.itemImages[0] : '',
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildHistoryItem(int tradeId, String title, String user, String date,
      String status, bool isGive, String imagePath) {
    bool isCompleted = status == 'Completed';
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.tradeDetails,
            arguments: tradeId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(15.r),
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
            Container(
              width: 90.w,
              height: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: imagePath.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image_outlined),
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Image.asset(
                        imagePath.isNotEmpty ? imagePath : 'assets/iphone.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isGive
                              ? Colors.blue.shade400
                              : Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isGive ? 'Give' : 'Take',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.onPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14.sp, color: Colors.grey),
                      SizedBox(width: 5.w),
                      Text(user,
                          style: TextStyle(
                              fontSize: 12.sp, color: context.subTextColor)),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14.sp, color: Colors.grey),
                      SizedBox(width: 5.w),
                      Text(date,
                          style: TextStyle(
                              fontSize: 12.sp, color: context.subTextColor)),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Spacer(),
                      Icon(
                        isCompleted
                            ? Icons.check_circle_outline
                            : Icons.hourglass_top,
                        size: 14.sp,
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.green : Colors.orange,
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

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trade Summary Shimmer
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 24.h, width: 150.w),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) =>
                        ShimmerBox(height: 100.h, width: 115.w, radius: 15.r),
                  ),
                ),
              ],
            ),
          ),
          // Filters Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                ShimmerBox(height: 35.h, width: 60.w, radius: 20.r),
                SizedBox(width: 8.w),
                ShimmerBox(height: 35.h, width: 80.w, radius: 20.r),
                SizedBox(width: 8.w),
                ShimmerBox(height: 35.h, width: 70.w, radius: 20.r),
                const Spacer(),
                ShimmerBox(height: 35.h, width: 80.w, radius: 20.r),
              ],
            ),
          ),
          // History List Shimmer
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    ShimmerBox(height: 100.w, width: 90.w, radius: 10.r),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(height: 20.h, width: 120.w),
                              ShimmerBox(
                                  height: 18.h, width: 50.w, radius: 8.r),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 14.h, width: 100.w),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 14.h, width: 130.w),
                          SizedBox(height: 8.h),
                          ShimmerBox(height: 14.h, width: 80.w),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
