import 'package:flutter/material.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/features/subscription/controller/subscription_controller.dart';
import 'package:tool_bocs/features/subscription/model/subscription_model.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';

class MySubscriptionStatusScreen extends StatefulWidget {
  const MySubscriptionStatusScreen({super.key});

  @override
  State<MySubscriptionStatusScreen> createState() =>
      _MySubscriptionStatusScreenState();
}

class _MySubscriptionStatusScreenState
    extends State<MySubscriptionStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionController>().fetchMySubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.subscriptionHistory),
            icon: Icon(Icons.history, color: context.textColor, size: 24.sp),
          ),
        ],
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.mySubscription,
          style: TextStyle(
            color: context.textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.dividerColor),
        ),
      ),
      body: Consumer<SubscriptionController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildLoadingState(context);
          }

          final subscription = controller.mySubscription;

          if (subscription == null) {
            return _buildEmptyState(context, controller);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                _buildCurrentPlanCard(context, subscription),
                SizedBox(height: 20.h),
                _buildCreditStatusCard(context, subscription),
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(context)!.includedBenefits,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.subTextColor,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildBenefitItem(
                    context, AppLocalizations.of(context)!.postVisibilityStatus(subscription.status)),
                _buildBenefitItem(
                    context, AppLocalizations.of(context)!.remainingDaysCount(subscription.remainingDays.toString())),
                _buildBenefitItem(
                    context, AppLocalizations.of(context)!.postPriceAmount(subscription.postPrice.toString())),
                _buildBenefitItem(context,
                    AppLocalizations.of(context)!.totalAllocationCredits(subscription.creditBalance.toString())),
                SizedBox(height: 20.h),
                _buildActionButton(
                  context,
                  label: AppLocalizations.of(context)!.changePlan,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.choosePlan),
                  isPrimary: true,
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          ShimmerBox(height: 200.h, width: double.infinity, radius: 20.r),
          SizedBox(height: 20.h),
          ShimmerBox(height: 100.h, width: double.infinity, radius: 16.r),
          SizedBox(height: 30.h),
          ...List.generate(
              4,
              (index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ShimmerBox(
                        height: 50.h, width: double.infinity, radius: 12.r),
                  )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, SubscriptionController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subscriptions_outlined,
                size: 64.sp, color: context.subTextColor),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.noActiveSubscription,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage ??
                  AppLocalizations.of(context)!.youDontHaveAnyActiveSubscriptionPlan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildActionButton(
              context,
              label: AppLocalizations.of(context)!.viewPlans,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.choosePlan),
              isPrimary: true,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => controller.fetchMySubscription(),
              child:
                  Text(AppLocalizations.of(context)!.retry, style: TextStyle(color: context.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
      BuildContext context, MySubscriptionData subscription) {
    final expiryDate = subscription.endDate.isNotEmpty
        ? DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(subscription.endDate))
        : 'N/A';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: subscription.status.toLowerCase() == 'active'
                      ? context.primaryColor.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  subscription.status.toUpperCase(),
                  style: TextStyle(
                    color: subscription.status.toLowerCase() == 'active'
                        ? context.primaryColor
                        : Colors.orange,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${subscription.name}\n',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.daysPlan(subscription.days.toString()),
                      style: TextStyle(
                        color: context.subTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            AppLocalizations.of(context)!.planText(subscription.name),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          const Divider(height: 15),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.calendar_today,
                    color: context.primaryColor, size: 24.sp),
              ),
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.expiryDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    expiryDate,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditStatusCard(
      BuildContext context, MySubscriptionData subscription) {
    double usage = 0;
    if (subscription.creditBalance > 0) {
      usage = (double.tryParse(subscription.remainingCredit) ?? 0) /
          subscription.creditBalance;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.remainingCredits,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context)!.usagePostsUsed(subscription.usedPosts.toString()),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.subTextColor,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subscription.remainingCredit.split('.').first,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    TextSpan(
                      text: '/${subscription.creditBalance}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Stack(
            children: [
              Container(
                height: 8.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.grey.withOpacity(0.3) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Container(
                height: 8.h,
                width: 1.sw * (usage > 1 ? 1 : usage),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: context.primaryColor, size: 14.sp),
          ),
          SizedBox(width: 15.w),
          Text(
            benefit,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? context.primaryColor : context.surfaceColor,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: context.dividerColor),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? (context.isDarkMode ? Colors.black : Colors.white) : context.textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
