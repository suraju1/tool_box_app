import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class AppImagePickerBS extends StatelessWidget {
  final bool allowMultiple;
  final int? limit;
  const AppImagePickerBS({super.key, this.allowMultiple = false, this.limit});

  static Future<List<XFile>?> show(BuildContext context,
      {bool allowMultiple = false, int? limit}) async {
    return await showModalBottomSheet<List<XFile>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AppImagePickerBS(allowMultiple: allowMultiple, limit: limit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: FontFamily.openSans,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (context.mounted) {
                      Navigator.pop(context, image != null ? [image] : null);
                    }
                  },
                ),
                SizedBox(width: 20.w),
                _buildOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    final picker = ImagePicker();
                    if (allowMultiple) {
                      final List<XFile> images =
                          await picker.pickMultiImage(limit: limit);
                      if (context.mounted) {
                        Navigator.pop(
                            context, images.isNotEmpty ? images : null);
                      }
                    } else {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (context.mounted) {
                        Navigator.pop(context, image != null ? [image] : null);
                      }
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(12.r),
            color: context.isDarkMode
                ? Colors.white10
                : context.dividerColor.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32.sp, color: context.primaryColor),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.openSans,
                  color: context.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
