import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class CreateGivePostScreen extends StatefulWidget {
  const CreateGivePostScreen({super.key});

  @override
  State<CreateGivePostScreen> createState() => _CreateGivePostScreenState();
}

class _CreateGivePostScreenState extends State<CreateGivePostScreen> {
  double _diameter = 5;
  bool _isTemporary = true;
  String _selectedCondition = 'New';
  bool _isPriceSelected = true;
  RangeValues _priceRange = const RangeValues(10, 100);
  bool _isNegotiable = false;
  bool _notifyPartnersOnly = true;
  bool _isHomemade = false;
  bool _isStoreBought = false;
  String _returnSelectedCondition = 'New';
  bool _isReturnHomemade = false;
  bool _isReturnStoreBought = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //app bar here
            SizedBox(height: 20.h),
            _buildAppBar(),
            Divider(
              color: context.dividerColor,
              thickness: 1,
              height: 10.h,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
                  _buildLocationSection(),
                  SizedBox(height: 20.h),
                  _buildTradeDetailsSection(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            //add item details section
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
                  _buildItemDetailsSection(),
                  // SizedBox(height: 20.h),
                  // _buildReturnSection(),
                  // SizedBox(height: 20.h),
                  // _buildWalletAndNotificationSection(),
                  // SizedBox(height: 30.h),
                  // _buildPostButton(),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            //return section
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: appColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: appColor.withOpacity(0.2), width: 1.5),
                boxShadow: context.isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: appColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
            SizedBox(height: 8.h),
            //wallet section
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
                  _buildWalletAndNotificationSection(),
                ],
              ),
            ),

            //build post button
            SizedBox(height: 20.h),
            _buildPostButton(),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
        SizedBox(height: 12.h),
        Text('Pickup Area', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildTextField('Detect your Location',
            prefixIcon: Icons.location_on_outlined),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 45.h,
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            'Detect GPS',
            style: TextStyle(
              color: context.subTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Area Diameter', style: _labelStyle()),
            Text('${_diameter.toInt()} km', style: _labelStyle()),
          ],
        ),
        SizedBox(height: 15.h),
        Slider(
          value: _diameter,
          min: 1,
          max: 50,
          padding: EdgeInsets.zero,
          activeColor: defoultColor,
          inactiveColor: context.dividerColor,
          onChanged: (val) => setState(() => _diameter = val),
        ),
        SizedBox(height: 15.h),
        Text(
          'Partners within this radius will see your item.',
          style: TextStyle(color: context.subTextColor, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildTradeDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trade Details', style: _labelStyle(size: 14)),
        SizedBox(height: 8.h),
        Text('Trade Type',
            style: TextStyle(color: context.subTextColor, fontSize: 12.sp)),
        SizedBox(height: 12.h),
        Container(
          height: 45.h,
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              _buildToggleButton('Temporary Exchange', _isTemporary, () {
                setState(() => _isTemporary = true);
              }),
              _buildToggleButton('Permanent Exchange', !_isTemporary, () {
                setState(() => _isTemporary = false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Photos', style: _labelStyle(size: 14)),
        SizedBox(height: 15.h),
        Container(
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
              Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30.sp),
              SizedBox(height: 8.h),
              Text(
                'Add up to 5 photos',
                style: TextStyle(color: context.subTextColor, fontSize: 12.sp),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) => _buildSmallPhotoBox()),
        ),
      ],
    );
  }

  Widget _buildItemDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item Details', style: _labelStyle(size: 16)),
        SizedBox(height: 12.h),
        Text('Item Name', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildTextField('Enter item name'),
        SizedBox(height: 12.h),
        _buildAddPhotosSection(),
        SizedBox(height: 20.h),
        Text('Category', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildDropdown('Select Category'),
        SizedBox(height: 16.h),
        Text('Condition', style: _labelStyle()),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildConditionChip('New'),
            _buildConditionChip('Like New'),
            _buildConditionChip('Used'),
          ],
        ),
        SizedBox(height: 16.h),
        Text('Write a Note', style: _labelStyle()),
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
                    value: _isHomemade,
                    activeColor: defoultColor,
                    onChanged: (val) {
                      setState(() {
                        _isHomemade = val ?? false;
                        if (_isHomemade) _isStoreBought = false;
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
                    value: _isStoreBought,
                    activeColor: defoultColor,
                    onChanged: (val) {
                      setState(() {
                        _isStoreBought = val ?? false;
                        if (_isStoreBought) _isHomemade = false;
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
      ],
    );
  }

  Widget _buildReturnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What do you want in return ?', style: _labelStyle(size: 16)),
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
                  'Desired Price Range : \$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                SizedBox(height: 15.h),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 500,
                  padding: EdgeInsets.zero,
                  activeColor: defoultColor,
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
                        activeColor: defoultColor,
                        onChanged: (val) => setState(() => _isNegotiable = val),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('Negotiable',
                        style: TextStyle(
                            color: context.subTextColor, fontSize: 13.sp)),
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
        Text('Item Name', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildTextField('Enter item name'),
        SizedBox(height: 20.h),
        _buildAddPhotosSection(),
        SizedBox(height: 20.h),
        Text('Category', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildDropdown('Select Category'),
        SizedBox(height: 16.h),
        Text('Condition', style: _labelStyle()),
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
        Text('Description', style: _labelStyle()),
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
                    activeColor: defoultColor,
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
                    activeColor: defoultColor,
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
          color: isSelected ? defoultColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
              color: isSelected ? defoultColor : context.dividerColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: defoultColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.subTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletAndNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            // borderRadius: BorderRadius.circular(12.r),
            // border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: greyColorWithOpacity0_4,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wallet', style: _labelStyle(size: 14)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: defoultColor, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('5 rs per trade',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 20.h),
              Text('Notification Settings', style: _labelStyle(size: 14)),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notify Saved Users Only',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          'Only Partners you\'ve traded with before will receive notifications.',
                          style: TextStyle(
                              color: context.subTextColor, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notifyPartnersOnly,
                    activeColor: defoultColor,
                    padding: EdgeInsets.all(8.w),
                    onChanged: (val) =>
                        setState(() => _notifyPartnersOnly = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: defoultColor,
          shape: RoundedRectangleManager.roundedRadius(10.r),
          elevation: 0,
        ),
        child: Text(
          'Post Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
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
          borderSide: BorderSide(color: defoultColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? defoultColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : context.subTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPhotoBox() {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  Widget _buildConditionChip(String label) {
    bool isSelected = _selectedCondition == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? defoultColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
              color: isSelected ? defoultColor : context.dividerColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: defoultColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.subTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle({double size = 12}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size.sp,
      fontFamily: FontFamily.openSans,
      color: context.textColor,
    );
  }

  Widget _buildAppBar() {
    // take teh argument data
    final String title = ModalRoute.of(context)!.settings.arguments as String;
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon:
                Icon(Icons.arrow_back_ios, color: context.textColor, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 45.w),
          Center(
            child: Text(
              title, //'Create Give Post',
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedRectangleManager {
  static RoundedRectangleBorder roundedRadius(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
