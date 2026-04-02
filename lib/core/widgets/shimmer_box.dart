import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tool_bocs/util/colors.dart';

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.height,
    required this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBaseColor,
      highlightColor: context.shimmerHighlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color:
              Colors.white, // White allows the shimmer colors to show cleanly
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
