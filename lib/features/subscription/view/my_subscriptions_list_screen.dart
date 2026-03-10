import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class MySubscriptionsListScreen extends StatelessWidget {
  const MySubscriptionsListScreen({super.key});

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
          'My Subscriptions',
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
      body: Column(
        children: [
          _buildActivePlanHeader(context),
          SizedBox(height: 12.h),
          _buildYearFilter(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              children: [
                _buildInvoiceCard(
                  context,
                  title: 'Pro Monthly',
                  invoiceNumber: 'TB-8892',
                  status: 'Completed',
                  period: '12 Jan - 12 Feb 2025',
                  paymentMethod: 'UPI toolucs@axis',
                  credits: '400',
                  statusColor: const Color(0xFF4CAF50),
                ),
                SizedBox(height: 20.h),
                _buildInvoiceCard(
                  context,
                  title: 'Basic Monthly',
                  invoiceNumber: 'TB-8892',
                  status: 'Expired',
                  period: '12 Jan - 12 Feb 2025',
                  paymentMethod: 'UPI toolucs@axis',
                  credits: '400',
                  statusColor: Colors.grey,
                ),
                SizedBox(height: 20.h),
                _buildInvoiceCard(
                  context,
                  title: 'Basic Monthly',
                  invoiceNumber: 'TB-8892',
                  status: 'Expired',
                  period: '12 Jan - 12 Feb 2025',
                  paymentMethod: 'UPI toolucs@axis',
                  credits: '400',
                  statusColor: Colors.grey,
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SizedBox(
          width: double.infinity,
          height: 55.h,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: defoultColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Upgrade to Annual Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivePlanHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: defoultColor,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: defoultColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              height: 150.r,
              width: 150.r,
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Plan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Toolucs Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Next renewal on 12 Mar 2025',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 20.w,
          children: [
            _buildFilterChip('All Years', isActive: true),
            _buildFilterChip('2025', isActive: false),
            _buildFilterChip('2024', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? defoultColor : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
            color: isActive ? defoultColor : Colors.grey.withOpacity(0.2)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: defoultColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context, {
    required String title,
    required String invoiceNumber,
    required String status,
    required String period,
    required String paymentMethod,
    required String credits,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                          ),
                        ),
                        Text(
                          'Invoice #$invoiceNumber',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.subTextColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(context, 'PERIOD', period),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          context, 'PAYMENT METHOD', paymentMethod),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: defoultColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      credits,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Credits',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: defoultColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  status == 'Completed' ? 'View Receipt' : 'Archive',
                  style: TextStyle(
                    color: defoultColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: context.subTextColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
      ],
    );
  }
}
