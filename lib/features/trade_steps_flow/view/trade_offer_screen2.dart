import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';

enum ReturnType { rohanGiving, customItem, money, free }

class TradeOfferScreen extends StatefulWidget {
  const TradeOfferScreen({super.key});

  @override
  State<TradeOfferScreen> createState() => _TradeOfferScreenState();
}

class _TradeOfferScreenState extends State<TradeOfferScreen> {
  ReturnType _selectedReturnType = ReturnType.rohanGiving;
  String _customItemCondition = 'New';
  bool _isHomemade = false;
  bool _isStoreBought = false;
  RangeValues _priceRange = const RangeValues(10, 100);
  bool _isNegotiable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepper(),
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipientCard(),
                      SizedBox(height: 24.h),
                      Text(
                        'Take ( What you want in Return? )',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildReturnOption(
                        type: ReturnType.rohanGiving,
                        title: "Take what Rohan’s giving",
                        child: _buildItemPreviewCard(),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.customItem,
                        title: "Item You Want in Return",
                        subtitle: "Fill item details you want in return",
                        child: _buildCustomItemForm(),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.money,
                        title: "Money ( Ask for Money )",
                        subtitle: "Set a custom price for the item",
                        child: _buildMoneyForm(),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.free,
                        title: "Give For Free",
                        subtitle: "Spread some joy in  the neighbourhood",
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomAction(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
      ),
      centerTitle: true,
      title: Text(
        'Give Icecream to Rohan',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: context.scaffoldBg,
      padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
      child: Row(
        children: [
          _buildStepSegment(isActive: true),
          _buildStepSegment(isActive: true),
          _buildStepSegment(isActive: false),
          _buildStepSegment(isActive: false),
        ],
      ),
    );
  }

  Widget _buildStepSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 5.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: isActive ? defoultColor : greyColorWithOpacity0_4,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildRecipientCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColorWithOpacity0_4,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          
          */
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TAKER',
                              style: TextStyle(
                                color: defoultColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Rohan Sharma',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                fontFamily: FontFamily.openSans,
                                color: context.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Rohan’s Taking',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '1L Vanilla Ice Cream',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: FontFamily.openSans,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildIconLabel(
                        context, Icons.swap_horiz, 'Take Type : ', 'Permanent'),
                    SizedBox(height: 4.h),
                    _buildIconLabel(context, Icons.category_outlined,
                        'Category : ', 'Other'),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 40.h),
                  Container(
                    width: 120.w,
                    height: 120.h,
                    margin: EdgeInsets.only(left: 6.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: const DecorationImage(
                        image: AssetImage('assets/iphone.png'), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.location_on,
                            color: context.subTextColor, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '0.4 miles away',
                          style: TextStyle(
                            color: context.subTextColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildIconLabel(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        // Icon(icon, color: greyColor, size: 14.sp),
        // SizedBox(width: 4.w),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: context.subTextColor,
              fontSize: 11.sp,
              fontFamily: FontFamily.openSans,
            ),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReturnOption({
    required ReturnType type,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    bool isSelected = _selectedReturnType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedReturnType = type),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (context.isDarkMode ? Colors.white10 : const Color(0xFFF1F6FF))
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? defoultColor.withOpacity(0.1)
                : context.dividerColor,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? defoultColor : context.dividerColor,
                      width: 2.w,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: defoultColor,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            if (isSelected) child,
          ],
        ),
      ),
    );
  }

  Widget _buildItemPreviewCard() {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: const DecorationImage(
                image: AssetImage('assets/iphone.png'), // Placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organic Apples (2kg)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                  ),
                ),
                Text(
                  'Food',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomItemForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _buildLabel(context, 'Item Name'),
        SizedBox(height: 8.h),
        _buildTextField(context, 'Enter item name'),
        SizedBox(height: 16.h),
        _buildLabel(context, 'Category'),
        SizedBox(height: 8.h),
        _buildDropdown(context, 'Select Category'),
        SizedBox(height: 16.h),
        _buildLabel(context, 'Condition'),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildConditionChip(context, 'New'),
            _buildConditionChip(context, 'Like New'),
            _buildConditionChip(context, 'Used'),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildCheckbox(context, 'Homemade', _isHomemade, (val) {
              setState(() {
                _isHomemade = val!;
                if (_isHomemade) _isStoreBought = false;
              });
            }),
            SizedBox(width: 20.w),
            _buildCheckbox(context, 'Store bought', _isStoreBought, (val) {
              setState(() {
                _isStoreBought = val!;
                if (_isStoreBought) _isHomemade = false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          'Desired Price Range : \$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        SizedBox(height: 12.h),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 500,
          padding: EdgeInsets.zero,
          activeColor: defoultColor,
          inactiveColor: context.dividerColor,
          onChanged: (val) => setState(() => _priceRange = val),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _isNegotiable,
                activeColor: defoultColor,
                onChanged: (val) => setState(() => _isNegotiable = val),
              ),
            ),
            Text(
              'Negotiable',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint) {
    return Container(
      // height: 44.h,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: context.subTextColor.withOpacity(0.5), fontSize: 13.sp),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String hint) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint,
              style: TextStyle(
                  color: context.subTextColor.withOpacity(0.5),
                  fontSize: 13.sp)),
          Icon(Icons.keyboard_arrow_down, color: context.subTextColor),
        ],
      ),
    );
  }

  Widget _buildConditionChip(BuildContext context, String label) {
    bool isSelected = _customItemCondition == label;
    return GestureDetector(
      onTap: () => setState(() => _customItemCondition = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? defoultColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: isSelected ? defoultColor : context.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? whiteColor : context.subTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, String label, bool value,
      ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
          height: 20.w,
          child: Checkbox(
            value: value,
            activeColor: defoultColor,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
        SizedBox(width: 8.w),
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
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                  color: greyColorWithOpacity0_4,
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.tradeStart);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: defoultColor,
          minimumSize: Size(double.infinity, 50.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
        ),
        child: Text(
          'Give Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
