import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';

class TradeReturnSearchScreen extends StatefulWidget {
  const TradeReturnSearchScreen({super.key});

  @override
  State<TradeReturnSearchScreen> createState() =>
      _TradeReturnSearchScreenState();
}

class _TradeReturnSearchScreenState extends State<TradeReturnSearchScreen> {
  bool isPriceTab = true;
  RangeValues priceRange = const RangeValues(10, 50000);
  bool isNegotiable = false;

  bool _isPriceSelected = true;
  RangeValues _priceRange = const RangeValues(10, 50000);
  bool _isNegotiable = false;
  String _returnSelectedCondition = 'New';
  bool _isReturnHomemade = false;
  bool _isReturnStoreBought = false;
  final List<XFile> _returnItemImages = [];

  Future<void> _pickImage() async {
    final List<XFile>? images =
        await AppImagePickerBS.show(context, allowMultiple: true);
    if (images != null && images.isNotEmpty) {
      setState(() {
        if (_returnItemImages.length + images.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Max 5 images allowed')),
          );
        } else {
          _returnItemImages.addAll(images);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _returnItemImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: context.dividerColor),
                      boxShadow: context.isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                color: greyColorWithOpacity0_4,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        _buildReturnSection(),
                        // SizedBox(height: 20.h),
                        // _buildWalletAndNotificationSection(),
                        // SizedBox(height: 30.h),
                        // _buildPostButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
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
        'Take It',
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
          _buildStepSegment(isActive: false),
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
          color: isActive ? context.primaryColor : greyColorWithOpacity0_4,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildReturnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What do you want in return ?',
            style: _labelStyle(context, size: 16)),
        SizedBox(height: 16.h),
        Container(
          height: 45.h,
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              _buildToggleButton('Price', _isPriceSelected, () {
                setState(() => _isPriceSelected = true);
              }),
              _buildToggleButton('Item', !_isPriceSelected, () {
                setState(() => _isPriceSelected = false);
              }),
            ],
          ),
        ),
        if (_isPriceSelected) ...[
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: context.dividerColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desired Price Range : ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: context.textColor),
                ),
                SizedBox(height: 15.h),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 200000,
                  padding: EdgeInsets.zero,
                  activeColor: context.primaryColor,
                  inactiveColor: context.dividerColor,
                  onChanged: (val) => setState(() => _priceRange = val),
                ),
                SizedBox(height: 25.h),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      child: Switch(
                        value: _isNegotiable,
                        activeColor: context.primaryColor,
                        onChanged: (val) => setState(() => _isNegotiable = val),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('Negotiable',
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          _buildReturnItemDetailsSection(),
        ]
      ],
    );
  }

  Widget _buildReturnItemDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text('Item Name', style: _labelStyle(context)),
        SizedBox(height: 8.h),
        _buildTextField('Enter item name'),
        SizedBox(height: 20.h),
        _buildAddPhotosSection(),
        SizedBox(height: 20.h),
        Text('Category', style: _labelStyle(context)),
        SizedBox(height: 8.h),
        _buildDropdown('Select Category'),
        SizedBox(height: 16.h),
        Text('Condition', style: _labelStyle(context)),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildReturnConditionChip('New'),
            _buildReturnConditionChip('Like New'),
            _buildReturnConditionChip('Used'),
          ],
        ),
        SizedBox(height: 16.h),
        Text('Description', style: _labelStyle(context)),
        SizedBox(height: 8.h),
        _buildTextField('Describe your product here...', maxLines: 4),
        SizedBox(height: 12.h),
        Row(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24.w,
                  width: 24.w,
                  child: Checkbox(
                    value: _isReturnHomemade,
                    activeColor: context.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _isReturnHomemade = val ?? false;
                        if (_isReturnHomemade) _isReturnStoreBought = false;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Homemade',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.openSans,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20.w),
            Row(
              children: [
                SizedBox(
                  height: 24.w,
                  width: 24.w,
                  child: Checkbox(
                    value: _isReturnStoreBought,
                    activeColor: context.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _isReturnStoreBought = val ?? false;
                        if (_isReturnStoreBought) _isReturnHomemade = false;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Store bought',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.openSans,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildReturnConditionChip(String label) {
    bool isSelected = _returnSelectedCondition == label;
    return GestureDetector(
      onTap: () => setState(() => _returnSelectedCondition = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
              color: isSelected ? context.primaryColor : context.dividerColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: context.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.onPrimaryColor : context.subTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {IconData? prefixIcon, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.subTextColor, fontSize: 13.sp),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: context.subTextColor, size: 20.sp)
            : null,
        filled: true,
        fillColor: context.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: context.primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Photos', style: _labelStyle(context, size: 14)),
        SizedBox(height: 15.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: context.dividerColor, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: context.subTextColor, size: 30.sp),
                SizedBox(height: 8.h),
                Text(
                  'Add up to 5 photos',
                  style:
                      TextStyle(color: context.subTextColor, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
        if (_returnItemImages.isNotEmpty) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _returnItemImages.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: FileImage(File(_returnItemImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close,
                              size: 12, color: context.onPrimaryColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (context.isDarkMode ? Colors.white38 : Colors.black54),
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint,
              style: TextStyle(color: context.subTextColor, fontSize: 13.sp)),
          isExpanded: true,
          items: [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context, {double size = 12}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size.sp,
      fontFamily: FontFamily.openSans,
      color: context.textColor,
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
          Navigator.pushNamed(context, AppRoutes.tradeOffer);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          minimumSize: Size(double.infinity, 56.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: TextStyle(
              color: context.onPrimaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp),
        ),
      ),
    );
  }
}
