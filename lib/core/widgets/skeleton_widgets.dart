import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/util/colors.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 11.h, width: 80.w, radius: 4.r),
                      SizedBox(height: 4.h),
                      ShimmerBox(height: 16.h, width: 140.w, radius: 4.r),
                      SizedBox(height: 4.h),
                      ShimmerBox(height: 10.h, width: 60.w, radius: 4.r),
                    ],
                  ),
                ),
                ShimmerBox(height: 14.h, width: 60.w, radius: 4.r),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 14 / 9,
            child: ShimmerBox(
              height: double.infinity,
              width: double.infinity,
              radius: 0,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShimmerBox(height: 20.r, width: 20.r, radius: 10.r),
                    SizedBox(width: 6.w),
                    ShimmerBox(height: 12.h, width: 80.w, radius: 4.r),
                  ],
                ),
                ShimmerBox(height: 30.h, width: 90.w, radius: 6.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          ShimmerBox(height: 50.r, width: 50.r, radius: 25.r),
          SizedBox(width: 12.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14.h, width: constraints.maxWidth * 0.5, radius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(height: 12.h, width: constraints.maxWidth * 0.8, radius: 4.r),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalProductCardSkeleton extends StatelessWidget {
  const HorizontalProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 154.w, width: 136.w, radius: 12.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(height: 10.h, width: 60.w, radius: 4.r),
                    ShimmerBox(height: 10.h, width: 50.w, radius: 4.r),
                  ],
                ),
                SizedBox(height: 8.h),
                ShimmerBox(height: 18.h, width: 120.w, radius: 4.r),
                SizedBox(height: 8.h),
                ShimmerBox(height: 12.h, width: 100.w, radius: 4.r),
                SizedBox(height: 12.h),
                ShimmerBox(height: 15.h, width: 130.w, radius: 4.r),
                SizedBox(height: 8.h),
                ShimmerBox(height: 15.h, width: 80.w, radius: 4.r),
                SizedBox(height: 12.h),
                ShimmerBox(height: 30.h, width: double.infinity, radius: 6.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
