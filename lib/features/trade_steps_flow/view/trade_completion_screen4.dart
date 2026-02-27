import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/features/chat/view/chat_screen.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';

class TradeCompletionScreen extends StatelessWidget {
  const TradeCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                _buildStepper(context),
                SizedBox(height: 10.h),
                _buildHandshakeBanner(),
                SizedBox(height: 24.h),
                _buildTradeSummary(context),
                SizedBox(height: 16.h),
                _buildChatTicketCard(context),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomAction(context),
          ),
        ],
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
        'Complete the Trade',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Container(
      color: context.scaffoldBg,
      padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
      child: Row(
        children: [
          _buildStepSegment(isActive: true),
          _buildStepSegment(isActive: true),
          _buildStepSegment(isActive: true),
          _buildStepSegment(isActive: true),
        ],
      ),
    );
  }

  Widget _buildStepSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 5.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: isActive ? defoultColor : greyColorWithOpacity0_4,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildHandshakeBanner() {
    return Container(
      width: double.infinity,
      height: 220.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Image.asset(
        'assets/TradeAccepted.png', // Fallback for now
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill,

        colorBlendMode: BlendMode.dstIn,
      ),
    );
  }

  Widget _buildTradeSummary(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final post = tradeController.selectedPost;
    final otherUserId = post?.userId.toString() ?? 'Unknown';
    final otherUserName = post?.userName ?? 'User $otherUserId';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: context.subTextColor,
            fontSize: 16.sp,
            fontFamily: FontFamily.openSans,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$otherUserName ',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: Color(0xFF1E61CC)),
            ),
            const TextSpan(text: 'accepted your offer -\n'),
            const TextSpan(text: 'Taking Icecream from you, Giving you\n'),
            TextSpan(
              text: 'Money ',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: context.textColor),
            ),
            const TextSpan(text: 'in return'),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTicketCard(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final post = tradeController.selectedPost;
    final otherUserId = post?.userId.toString() ?? 'Unknown';
    final otherUserName = post?.userName ?? 'Unknown User';

    return InkWell(
      onTap: () {
        if (post != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUserId: otherUserId,
                otherUserName: otherUserName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No trade selected')),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: greyColorWithOpacity0_4,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white10
                    : const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.chat_bubble_outline,
                  color: const Color(0xFF1E61CC), size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat with $otherUserName',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    'Spend a Ticket (15 mtrs)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: context.textColor, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColorWithOpacity0_4,
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.tradeSuccess);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF215BA3),
          minimumSize: Size(double.infinity, 54.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
        ),
        child: Text(
          'Close Trade',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
