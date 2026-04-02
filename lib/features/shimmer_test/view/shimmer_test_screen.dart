import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/core/widgets/skeleton_widgets.dart';
import 'package:tool_bocs/util/colors.dart';

class ShimmerTestScreen extends StatelessWidget {
  const ShimmerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Shimmer Testing',
          style: TextStyle(color: context.textColor),
        ),
        backgroundColor: context.appBarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Core ShimmerBox Variations'),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(height: 40.h, width: 40.w, radius: 20.r),
                ShimmerBox(height: 40.h, width: 100.w, radius: 8.r),
                ShimmerBox(height: 40.h, width: 150.w, radius: 20.r),
              ],
            ),
            SizedBox(height: 24.h),
            _buildSectionHeader(context, 'Product Card Skeleton (Root Fixed)'),
            SizedBox(height: 12.h),
            const ProductCardSkeleton(),
            SizedBox(height: 12.h),
            const ProductCardSkeleton(),
            SizedBox(height: 24.h),
            _buildSectionHeader(context, 'List Tile Skeleton'),
            SizedBox(height: 12.h),
            const ListTileSkeleton(),
            const ListTileSkeleton(),
            const ListTileSkeleton(),
            SizedBox(height: 40.h),
            Center(
              child: Text(
                'Verify the motion and colors are "Exact"',
                style: TextStyle(
                  color: context.subTextColor,
                  fontStyle: FontStyle.italic,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        Container(
          height: 2.h,
          width: 40.w,
          margin: EdgeInsets.only(top: 4.h),
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(1.r),
          ),
        ),
      ],
    );
  }
}
