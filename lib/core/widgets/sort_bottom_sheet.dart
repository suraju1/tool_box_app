import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class SortBottomSheet extends StatefulWidget {
  final String? initialPostType;
  const SortBottomSheet({super.key, this.initialPostType});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  // Two independent sort selections
  String selectedDistanceSort = 'Nearest First';
  String selectedDateSort = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TradeController>();
      setState(() {
        selectedDistanceSort = controller.selectedDistanceSort;
        selectedDateSort = controller.selectedDateSort;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            child: _buildHeader(),
          ),
          Divider(color: context.dividerColor, thickness: 1),

          // Body
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // DISTANCE group
                _buildGroupLabel('DISTANCE'),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    _buildDistancePill('Nearest', 'Nearest First'),
                    _buildDistancePill('Farthest', 'Farthest First'),
                  ],
                ),

                SizedBox(height: 20.h),

                // DATE ADDED group
                _buildGroupLabel('DATE ADDED'),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    _buildDatePill(AppLocalizations.of(context)!.newest, 'Newest First'),
                    _buildDatePill(AppLocalizations.of(context)!.oldest, 'Oldest First'),
                  ],
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),

          // Action Buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode
                      ? Colors.black54
                      : context.dividerColor.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: context.textColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.sortBy,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.textColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }

  Widget _buildGroupLabel(String label) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: context.subTextColor,
          fontFamily: FontFamily.openSans,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// Distance group — selecting one deselects the other distance option
  Widget _buildDistancePill(String label, String value) {
    final isSelected = selectedDistanceSort == value;
    return GestureDetector(
      onTap: () => setState(() {
        // Toggle: tap again to deselect
        selectedDistanceSort = isSelected ? '' : value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.isDarkMode
                    ? Colors.white24
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? context.onPrimaryColor : context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ),
    );
  }

  /// Date group — independent from distance group
  Widget _buildDatePill(String label, String value) {
    final isSelected = selectedDateSort == value;
    return GestureDetector(
      onTap: () => setState(() {
        // Toggle: tap again to deselect
        selectedDateSort = isSelected ? '' : value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.isDarkMode
                    ? Colors.white24
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? context.onPrimaryColor : context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final controller = context.read<TradeController>();
              controller.updateFilters(
                distanceSort: selectedDistanceSort,
                dateSort: selectedDateSort,
              );

              if (widget.initialPostType == 'give') {
                controller.fetchGivePosts(refresh: true);
              } else if (widget.initialPostType == 'take') {
                controller.fetchTakePosts(refresh: true);
              } else {
                controller.fetchHomePosts(refresh: true);
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              AppLocalizations.of(context)!.apply,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.onPrimaryColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDistanceSort = 'Nearest First';
                selectedDateSort = '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF0F2F5),
              foregroundColor: context.textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              AppLocalizations.of(context)!.reset,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
