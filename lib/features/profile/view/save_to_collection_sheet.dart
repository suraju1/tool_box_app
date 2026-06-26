import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class SaveToCollectionBottomSheet extends StatefulWidget {
  final int userId;

  const SaveToCollectionBottomSheet({super.key, required this.userId});

  static Future<void> show(BuildContext context, int userId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToCollectionBottomSheet(userId: userId),
    );
  }

  @override
  State<SaveToCollectionBottomSheet> createState() => _SaveToCollectionBottomSheetState();
}

class _SaveToCollectionBottomSheetState extends State<SaveToCollectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().getCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final collections = profileController.collections;
    final isLoading = profileController.isLoading && collections.isEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Save to Collection',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: context.primaryColor))
                : collections.isEmpty
                    ? Center(
                        child: Text(
                          'No collections found.',
                          style: TextStyle(color: context.subTextColor),
                        ),
                      )
                    : ListView.separated(
                        itemCount: collections.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          return InkWell(
                            onTap: () async {
                              final response = await context
                                  .read<ProfileController>()
                                  .addCollectionItem(collection.id, 'profile', widget.userId);
                              if (context.mounted) {
                                Navigator.pop(context);
                                if (response.success) {
                                  ToastService.showSuccessToast(context, 'User saved to ${collection.name}');
                                } else {
                                  ToastService.showErrorToast(context, response.message ?? 'Failed to save');
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: context.surfaceColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: context.dividerColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.folder, color: context.primaryColor),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      collection.name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.add, color: context.textColor),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
