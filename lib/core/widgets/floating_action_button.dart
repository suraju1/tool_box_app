import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

Widget createFloatingActionButton(
    {required BuildContext context, required String label}) {
  return SizedBox(
    width: 175.w,
    height: 45.h,
    child: FloatingActionButton(
      backgroundColor: context.primaryColor,
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.createGivePost);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          children: [
            Icon(Icons.add, color: context.onPrimaryColor, size: 30.sp),
            Text(
              label,
              style: TextStyle(
                color: context.onPrimaryColor,
                fontSize: 12.sp,
                fontFamily: FontFamily.openSans,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget addFloatingActionButton({required BuildContext context}) {
  return FloatingActionButton(
    backgroundColor: context.primaryColor,
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.createGivePost);
    },
    child: Icon(
      Icons.add,
      color: context.onPrimaryColor,
      size: 28.sp,
    ),
  );
}
