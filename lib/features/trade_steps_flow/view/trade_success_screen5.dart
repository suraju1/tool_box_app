import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/subscription/controller/subscription_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';

class TradeSuccessScreen extends StatelessWidget {
  const TradeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final subscriptionController = context.watch<SubscriptionController>();
    final response = tradeController.selectedResponse;
    final posterName = response?.posterName ?? 'the owner';

    final creditFee =
        subscriptionController.mySubscription?.postPrice.split('.').first ??
            tradeController.lastTradeCompletion?.amount.toString() ??
            '5';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: context.primaryColor, size: 80.sp),
              ),
              SizedBox(height: 32.h),
              Text(
                'Trade Confirmed !',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: FontFamily.openSans,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Your trade request has been sent to $posterName. You can now chat with them to coordinate the handover.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              if (tradeController.lastTradeCompletion != null) ...[
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: context.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Trade ID',
                        '#${tradeController.lastTradeCompletion!.tradeId}',
                        context,
                      ),
                      SizedBox(height: 8.h),
                      _buildDetailRow(
                        'Credit',
                        '$creditFee Credits',
                        context,
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 48.h),
              _buildActionButton(
                context,
                label: 'View Trade Details',
                onPressed: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.tradeDetails),
                isPrimary: true,
              ),
              SizedBox(height: 12.h),
              _buildActionButton(
                context,
                label: 'Go to Home',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.bottomNavBar, (route) => false),
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label,
      required VoidCallback onPressed,
      required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? context.primaryColor : context.surfaceColor,
          side: isPrimary
              ? null
              : BorderSide(color: context.primaryColor, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? context.textColor : context.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: context.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: context.textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
