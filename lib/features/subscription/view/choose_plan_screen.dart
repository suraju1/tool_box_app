import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class ChoosePlanScreen extends StatelessWidget {
  const ChoosePlanScreen({super.key});

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
        centerTitle: true,
        title: Text(
          'Subscription',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Unlock premium features and scale your productivity with TOOLUCS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.subTextColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30.h),
            _buildPlanCard(
              context,
              title: 'Basic',
              price: '199',
              credits: '50 Credits Included',
              features: [
                'Standard visibility',
                '10 chats per day',
                'Basic email support',
              ],
              buttonLabel: 'Get Started',
              isPopular: false,
            ),
            SizedBox(height: 15.h),
            _buildPlanCard(
              context,
              title: 'Pro',
              price: '499',
              credits: '200 Credits Included',
              features: [
                'Priority visibility',
                'Unlimited chats',
                'Advanced analytics',
                '24/7 Priority support',
              ],
              buttonLabel: 'Subscribe Now',
              isPopular: true,
            ),
            SizedBox(height: 15.h),
            _buildPlanCard(
              context,
              title: 'Enterprise',
              price: '999',
              credits: '500 Credits Included',
              features: [
                'White-labeling options',
                'Dedicated account manager',
                'Custom API integrations',
              ],
              buttonLabel: 'Get Started',
              isPopular: false,
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String credits,
    required List<String> features,
    required String buttonLabel,
    required bool isPopular,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: isPopular ? context.primaryColor : context.dividerColor,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(23.r),
                    bottomLeft: Radius.circular(15.r),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: context.onPrimaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                    Text(
                      ' /month',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Icon(Icons.stars, color: context.primaryColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      credits,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ...features.map((f) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 18.sp),
                          SizedBox(width: 12.w),
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: context.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 15.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? context.primaryColor : const Color(0xFFE8F1FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        color: isPopular ? Colors.white : context.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
