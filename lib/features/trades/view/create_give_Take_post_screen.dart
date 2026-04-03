import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/location/view/map_address_picker_screen.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/category_model.dart';
import 'package:tool_bocs/features/trades/model/post_request_model.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/subscription/controller/subscription_controller.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/popup_menu_arrow_shape.dart';

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
  RangeValues _priceRange = const RangeValues(10, 50000);
  bool _isNegotiable = false;
  bool _notifyPartnersOnly = false;
  bool _isHomemade = false;
  bool _isStoreBought = false;
  String _returnSelectedCondition = 'New';
  bool _isReturnHomemade = false;
  bool _isReturnStoreBought = false;
  CategoryModel? _selectedCategory;
  CategoryModel? _selectedReturnCategory;

  // Form Controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemNoteController = TextEditingController();
  final TextEditingController _returnItemNameController =
      TextEditingController();
  final TextEditingController _returnItemDescriptionController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Validation State
  bool _showImageError = false;
  bool _showSourceError = false;
  bool _showReturnImageError = false;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Images
  final List<XFile> _itemImages = [];
  final List<XFile> _returnItemImages = [];

  // Location
  String _pickupAddress = "Detecting location...";
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchCategories();
      context.read<SubscriptionController>().fetchMySubscription();
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    final locationController = context.read<LocationController>();
    await locationController.fetchLocation();
    _updateLocationFromController();
  }

  void _updateLocationFromController() {
    final locationController = context.read<LocationController>();
    if (mounted) {
      if (locationController.address != null) {
        setState(() {
          _pickupAddress = locationController.address!;
          _latitude = locationController.latitude;
          _longitude = locationController.longitude;
          _diameter = locationController.radius;
        });
      } else {
        setState(() {
          _pickupAddress = "Location not found";
        });
      }
    }
  }

  Future<void> _pickImage(bool isReturnItem) async {
    final int currentCount =
        isReturnItem ? _returnItemImages.length : _itemImages.length;
    final int remaining = 5 - currentCount;

    if (remaining <= 0) {
      ToastService.showErrorToast(context, 'Max 5 images allowed');
      return;
    }

    final List<XFile>? images = await AppImagePickerBS.show(context,
        allowMultiple: true, limit: remaining);

    if (images != null && images.isNotEmpty) {
      setState(() {
        if (isReturnItem) {
          if (_returnItemImages.length + images.length > 5) {
            final int toTake = 5 - _returnItemImages.length;
            _returnItemImages.addAll(images.take(toTake));
            ToastService.showErrorToast(
                context, 'Only first $toTake images added (Max 5 allowed)');
          } else {
            _returnItemImages.addAll(images);
          }
        } else {
          if (_itemImages.length + images.length > 5) {
            final int toTake = 5 - _itemImages.length;
            _itemImages.addAll(images.take(toTake));
            ToastService.showErrorToast(
                context, 'Only first $toTake images added (Max 5 allowed)');
          } else {
            _itemImages.addAll(images);
          }
        }
      });
    }
  }

  void _removeImage(int index, bool isReturnItem) {
    setState(() {
      if (isReturnItem) {
        _returnItemImages.removeAt(index);
      } else {
        _itemImages.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemNoteController.dispose();
    _returnItemNameController.dispose();
    _returnItemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //app bar here
              SizedBox(height: 6.h),
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
                  color: context.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: context.primaryColor.withOpacity(0.2), width: 1.5),
                  boxShadow: context.isDarkMode
                      ? []
                      : [
                          BoxShadow(
                            color: context.primaryColor.withOpacity(0.1),
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
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const MapAddressPickerScreen(isPickOnly: true)),
            ).then((_) => _updateLocationFromController());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: context.subTextColor, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _pickupAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: context.textColor),
                  ),
                ),
                Text(
                  'Change',
                  style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp),
                ),
              ],
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
          activeColor: context.primaryColor,
          inactiveColor: context.dividerColor,
          onChanged: (val) {
            setState(() => _diameter = val);
            context.read<LocationController>().setRadius(val);
          },
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
            color: context.isDarkMode
                ? Colors.white10
                : context.dividerColor.withOpacity(0.1),
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
        GestureDetector(
          onTap: _itemImages.length >= 5 ? null : () => _pickImage(false),
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: _showImageError
                      ? Colors.red
                      : (_itemImages.length >= 5
                          ? Colors.grey.withOpacity(0.3)
                          : context.dividerColor),
                  style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: _showImageError
                        ? Colors.red
                        : (_itemImages.length >= 5 ? Colors.grey : Colors.grey),
                    size: 30.sp),
                SizedBox(height: 8.h),
                Text(
                  _showImageError
                      ? 'Photo required'
                      : (_itemImages.length >= 5
                          ? 'Max 5 photos reached'
                          : 'Add up to 5 photos'),
                  style: TextStyle(
                      color: _showImageError
                          ? Colors.red
                          : (_itemImages.length >= 5
                              ? Colors.grey
                              : context.subTextColor),
                      fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (_itemImages.isNotEmpty)
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _itemImages.length,
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
                          image: FileImage(File(_itemImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () => _removeImage(index, false),
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
        _buildTextField('Enter item name',
            controller: _itemNameController,
            validator: (val) => _validateRequired(val, 'Item Name')),
        SizedBox(height: 12.h),
        _buildAddPhotosSection(),
        SizedBox(height: 20.h),
        Text('Category', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildDropdown('Select Category',
            value: _selectedCategory,
            onChanged: (val) => setState(() => _selectedCategory = val)),
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
        _buildTextField('Describe your product here...',
            maxLines: 4,
            controller: _itemNoteController,
            validator: (val) => _validateRequired(val, 'Note')),
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
                    activeColor: Colors.green,
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
                    activeColor: Colors.green,
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
        if (_showSourceError)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 4.w),
            child: Text(
              'Please select at least one option',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
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
                  'Desired Price Range : ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
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
                        activeColor: Colors.green,
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
        _buildTextField('Enter item name',
            controller: _returnItemNameController,
            validator: (val) => _validateRequired(val, 'Return Item Name')),
        SizedBox(height: 20.h),
        // Return Item Images
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Photos', style: _labelStyle(size: 14)),
            SizedBox(height: 15.h),
            GestureDetector(
              onTap:
                  _returnItemImages.length >= 5 ? null : () => _pickImage(true),
              child: Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: _showReturnImageError
                          ? Colors.red
                          : (_returnItemImages.length >= 5
                              ? Colors.grey.withOpacity(0.3)
                              : context.dividerColor),
                      style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: _showReturnImageError
                            ? Colors.red
                            : (_returnItemImages.length >= 5
                                ? Colors.grey
                                : Colors.grey),
                        size: 30.sp),
                    SizedBox(height: 8.h),
                    Text(
                      _showReturnImageError
                          ? 'Photo required'
                          : (_returnItemImages.length >= 5
                              ? 'Max 5 photos reached'
                              : 'Add up to 5 photos'),
                      style: TextStyle(
                          color: _showReturnImageError
                              ? Colors.red
                              : (_returnItemImages.length >= 5
                                  ? Colors.grey
                                  : context.subTextColor),
                          fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            if (_returnItemImages.isNotEmpty)
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
                              image: FileImage(
                                  File(_returnItemImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: GestureDetector(
                            onTap: () => _removeImage(index, true),
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
        ),
        SizedBox(height: 20.h),
        Text('Category', style: _labelStyle()),
        SizedBox(height: 8.h),
        // Note: For return item, we might want another dropdown or reuse logic.
        // For simplicity reusing the same dropdown builder but state management for return category is needed if it's different.
        // The requirements didn't specify return item category selection distinct from the main one in the API provided.
        // Waiting on user clarification for complex return item logic, but for now assuming text field or similar.
        // Actually, the UI shows a dropdown. I should probably add another state variable for return category if needed.
        // checking API: "return_type": "Price" or "Item". If "Item", no specific "return_item_category_id" in the provided API example json.
        // The API only has `item_category_id`. The return item details seem to be less structured in the example JSON?
        // Wait, the API JSON example shows `return_item_images` but NO `return_item_category` etc.
        // However, the UI code I'm replacing HAS these fields.
        // The user said "pass the proper and exact/real data for each field in the given api".
        // The API JSON provided:
        // "return_type": "Price", "price_min": 10...
        // IF return_type is Item, what are the fields? The example JSON showed "Price".
        // I will hide the category dropdown for return item for now or keep it UI-only as it's not in the provided API example for "Give" post.
        // Actually, let's keep the UI fields but maybe they aren't sent if the API doesn't support them?
        // Let's look at the `GiveawayRequestModel` I created. It only has `returnItemImages`.
        // It seems the API example was for "Price" return type.
        // If I switch to "Item" return type, the API likely expects `return_item_name`, `return_item_description` etc.
        // BUT the user provided API response for "Giveaway created" with "Price".
        // I will assume for now I should send what I can.
        // BUt wait, the `GiveawayRequestModel` I created DOES NOT have `returnItemName`, `returnItemCondition` etc.
        // I MISSED adding return item specific fields to the model!
        // The user said "pass the proper and exact/real data for each field in the given api".
        // The API Example:
        // "item_name": "Vintage Wooden Chair11", "item_category": "Furniture"...
        // It DOES NOT show return item fields because `return_type` was "Price".
        // I should probably UPDATE the model to include `return_item_name`, `return_item_condition` etc. to be safe.
        // OR better, I should ask the user? No, I should enable it.
        // I will implement the UI and map it to the model. I need to update the model first?
        // Let's stick to what's in the model for now.
        // Wait, I see I missed adding `returnItemName` etc to the model.
        // I should probably add them.
        // For now, let's just update the UI Binding.
        _buildDropdown('Select Category',
            value: _selectedReturnCategory,
            onChanged: (val) => setState(() => _selectedReturnCategory = val)),
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
        _buildTextField('Describe your product here...',
            maxLines: 4,
            controller: _returnItemDescriptionController,
            validator: (val) =>
                _validateRequired(val, 'Return Item Description')),
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
                    activeColor: Colors.green,
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
                    activeColor: Colors.green,
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

  Widget _buildWalletAndNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
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
              Text('Wallet', style: _labelStyle(size: 14)),
              SizedBox(height: 8.h),
              Consumer<SubscriptionController>(
                builder: (context, subscriptionController, child) {
                  final subscription = subscriptionController.mySubscription;
                  final remainingCredit =
                      subscription?.remainingCredit.split('.').first ?? '0';
                  final postPrice = subscription?.postPrice ?? '0';

                  return Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: context.primaryColor, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('$postPrice Credits per trade',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('Credits: $remainingCredit',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryColor)),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 6.h),
              Divider(color: context.dividerColor),
              SizedBox(height: 6.h),
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
                    activeColor: Colors.green,
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
    return Consumer<TradeController>(
      builder: (context, tradeController, child) {
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: tradeController.isLoading ? null : _onPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleManager.roundedRadius(10.r),
              elevation: 0,
            ),
            child: tradeController.isLoading
                ? CircularProgressIndicator(color: context.onPrimaryColor)
                : Text(
                    'Post Item',
                    style: TextStyle(
                      color: context.onPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _onPost() async {
    setState(() {
      _showImageError = false;
      _showSourceError = false;
      _showReturnImageError = false;
    });

    bool isValid = true;

    // Validate Form Fields (Name, Note, Category, Return Name/Description)
    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    // Validate Images
    if (_itemImages.isEmpty) {
      setState(() => _showImageError = true);
      // ToastService.showErrorToast(context, 'Please add at least 1 photo of the item');
      isValid = false;
    }

    // Validate Source (Homemade/Store Bought)
    if (!_isHomemade && !_isStoreBought) {
      setState(() => _showSourceError = true);
      isValid = false;
    }

    // Validate Return Item Details (if applicable)
    if (!_isPriceSelected) {
      if (_returnItemImages.isEmpty) {
        setState(() => _showReturnImageError = true);
        // ToastService.showErrorToast(context, 'Please add at least 1 photo of the return item');
        isValid = false;
      }
    }

    if (_latitude == null || _longitude == null) {
      ToastService.showErrorToast(context, 'Location not detected');
      isValid = false;
    }

    if (!isValid) {
      if (_showImageError || _showReturnImageError || _showSourceError) {
        ToastService.showErrorToast(context, 'Please fill all required fields');
      }
      return;
    }

    final userId = context.read<AuthController>().currentUser?.id;
    if (userId == null) {
      ToastService.showErrorToast(
          context, 'User not found. Please login again.');
      return;
    }

    final String title = ModalRoute.of(context)!.settings.arguments as String;
    final String postType =
        title.toLowerCase().contains('take') ? 'take' : 'give';

    // Create Request
    final request = PostRequestModel(
      userId: userId,
      pickupArea: _pickupAddress,
      latitude: _latitude!,
      longitude: _longitude!,
      areaDiameter: _diameter,
      tradeType: _isTemporary ? "Temporary" : "Permanent",
      itemName: _itemNameController.text,
      itemCategory: _selectedCategory!.name,
      itemCategoryId: _selectedCategory!.id,
      itemCondition: _selectedCondition,
      itemNote: _itemNoteController.text,
      itemSource: _isHomemade ? "Homemade" : "Store bought",
      returnType: _isPriceSelected ? "Price" : "Item",
      priceMin: _isPriceSelected ? _priceRange.start : null,
      priceMax: _isPriceSelected ? _priceRange.end : null,
      isNegotiable: _isNegotiable,
      walletCredits: (double.tryParse(context
                      .read<SubscriptionController>()
                      .mySubscription
                      ?.postPrice ??
                  '0') ??
              0)
          .toInt(),
      notifyPartnersOnly: _notifyPartnersOnly,
      postType: postType,
      itemImages: _itemImages.map((e) => e.path).toList(),
      returnItemImages:
          _isPriceSelected ? [] : _returnItemImages.map((e) => e.path).toList(),
      returnItemName:
          (!_isPriceSelected && _returnItemNameController.text.isNotEmpty)
              ? _returnItemNameController.text
              : null,
      returnItemCategory:
          _isPriceSelected ? null : _selectedReturnCategory?.name,
      returnItemCategoryId:
          _isPriceSelected ? null : _selectedReturnCategory?.id,
      returnItemCondition: _isPriceSelected ? null : _returnSelectedCondition,
      returnItemNote: (!_isPriceSelected &&
              _returnItemDescriptionController.text.isNotEmpty)
          ? _returnItemDescriptionController.text
          : null,
      returnItemDescription: (!_isPriceSelected &&
              _returnItemDescriptionController.text.isNotEmpty)
          ? _returnItemDescriptionController.text
          : null,
      returnItemSource: _isPriceSelected
          ? null
          : (_isReturnHomemade
              ? 'Homemade'
              : (_isReturnStoreBought ? 'Store bought' : null)),
    );

    final success = await context.read<TradeController>().createPost(request);

    if (success && mounted) {
      ToastService.showSuccessToast(context, 'Giveaway created successfully!');
      Navigator.pop(context);
    } else if (mounted) {
      ToastService.showErrorToast(
          context,
          context.read<TradeController>().errorMessage ??
              "Failed to create post");
    }
  }

  Widget _buildTextField(String hint,
      {IconData? prefixIcon,
      int maxLines = 1,
      TextEditingController? controller,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.surfaceColor,
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
          borderSide: BorderSide(color: context.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildDropdown(String hint,
      {CategoryModel? value, ValueChanged<CategoryModel?>? onChanged}) {
    return Consumer<TradeController>(
      builder: (context, tradeController, child) {
        if (tradeController.isLoading) {
          return Center(
            child: SizedBox(
              height: 20.w,
              width: 20.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: context.primaryColor),
            ),
          );
        }

        if (tradeController.errorMessage != null) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tradeController.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 13.sp),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.red, size: 20.sp),
                  onPressed: () {
                    context.read<TradeController>().fetchCategories();
                  },
                )
              ],
            ),
          );
        }

        return DropdownButtonFormField<CategoryModel>(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          hint: Text(hint,
              style: TextStyle(color: context.subTextColor, fontSize: 13.sp)),
          isExpanded: true,
          value: value,
          validator: (value) => value == null ? 'Category is required' : null,
          items: tradeController.categories.map((category) {
            return DropdownMenuItem<CategoryModel>(
              value: category,
              child: Text(
                category.name,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 14.sp,
                  fontFamily: FontFamily.openSans,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
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
              color: isSelected ? context.onPrimaryColor : context.subTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
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
          const Spacer(),
          PopupMenuButton<void>(
            offset: const Offset(-200, 45),
            shape: PopupMenuArrowShape(borderRadius: 12.r),
            color: Colors.white,
            elevation: 4,
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      '• Ask someone to take something, by creating a post',
                      '• This post will be visible to the "takers" around you',
                      '• In your selected area i.e >10 mtrs / <5kms',
                    ]
                        .map((text) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: const Color(0xFF111311),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              height: 40.h,
              width: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.isDarkMode
                      ? Colors.white24
                      : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                Icons.info_outline,
                color: context.primaryColor,
                size: 22.sp,
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
