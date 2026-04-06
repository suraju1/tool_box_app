import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/category_model.dart';
import 'package:tool_bocs/features/trades/model/trade_response_request_model.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/app_price_range_selector.dart';

enum ReturnType { existing, customItem, money, free }

class TradeOfferScreen extends StatefulWidget {
  const TradeOfferScreen({super.key});

  @override
  State<TradeOfferScreen> createState() => _TradeOfferScreenState();
}

class _TradeOfferScreenState extends State<TradeOfferScreen> {
  late TradeController _tradeController;
  ReturnType _selectedReturnType = ReturnType.existing;
  String _customItemCondition = 'New';
  bool _isHomemade = false;
  bool _isStoreBought = false;
  RangeValues _priceRange = const RangeValues(10, 50000);
  bool _isNegotiable = false;

  // Controllers for Custom Item
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  CategoryModel? _selectedCategory;

  // Images logic
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _itemImages = [];

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        if (_itemImages.length + images.length > 5) {
          ToastService.showErrorToast(context, 'Max 5 images allowed');
        } else {
          _itemImages.addAll(images);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _itemImages.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _tradeController = context.read<TradeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tradeController.fetchCategories();
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _tradeController.clearErrorMessage();
    super.dispose();
  }

  Future<void> _handleOfferSubmission() async {
    final tradeController = context.read<TradeController>();
    final post = tradeController.selectedPost;
    if (post == null) return;

    String responseType = 'item';
    double? priceStart;
    double? priceEnd;
    bool? isNegotiable;
    String? itemName;
    String? condition;
    String? description;
    bool? isHomemade;
    bool? isStoreBought;
    int? categoryId = _selectedCategoryId;

    if (_selectedReturnType == ReturnType.money) {
      responseType = 'price';
      priceStart = _priceRange.start;
      priceEnd = _priceRange.end;
      isNegotiable = _isNegotiable;
    } else if (_selectedReturnType == ReturnType.customItem) {
      responseType = 'item';
      itemName = _itemNameController.text.trim();
      description = _descriptionController.text.trim();
      condition = _customItemCondition;
      isHomemade = _isHomemade;
      isStoreBought = _isStoreBought;

      if (itemName.isEmpty) {
        ToastService.showErrorToast(context, 'Please enter item name');
        return;
      }
    } else if (_selectedReturnType == ReturnType.existing) {
      responseType = 'existing';
      if (post.returnType.toLowerCase() == 'price') {
        priceStart = post.priceMin;
        priceEnd = post.priceMax;
        isNegotiable = post.isNegotiable;
      } else {
        itemName = post.returnItemName;
        description = post.returnItemDescription;
        condition = post.returnItemCondition;
      }
    } else if (_selectedReturnType == ReturnType.free) {
      responseType = 'free';
    }

    final request = TradeResponseRequestModel(
      giveawayId: post.id,
      returnType: responseType,
      itemName: itemName,
      categoryId: categoryId,
      condition: condition,
      description: description,
      isHomemade: isHomemade,
      isStoreBought: isStoreBought,
      notifyPoster: true,
      priceRangeStart: priceStart,
      priceRangeEnd: priceEnd,
      isNegotiable: isNegotiable,
      images: _itemImages.map((e) => e.path).toList(),
    );

    log(request.toJson().toString());
    final success = await tradeController.respondToPost(request);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ToastService.showErrorToast(
          context, tradeController.errorMessage ?? 'Submission failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: context.surfaceColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 60.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              'Offer Sent!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your offer has been sent successfully. Please wait for the owner to accept it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.subTextColor,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to details or home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child:
                    Text('OK', style: TextStyle(color: context.onPrimaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonName(bool isGivePost) {
    switch (_selectedReturnType) {
      case ReturnType.existing:
        return isGivePost ? 'Give Specified Return' : 'Take Offered Item';
      case ReturnType.customItem:
        return isGivePost ? 'Offer Custom Item' : 'Request Custom Item';
      case ReturnType.money:
        return isGivePost ? 'Money (Ask for Money)' : 'Ask for Money';
      case ReturnType.free:
        return isGivePost ? 'Ask for Free' : 'Give for Free';
      default:
        return 'Send Offer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final post = tradeController.selectedPost;

    bool isGivePost = post?.postType == 'give';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(
        context,
        post?.itemName ?? 'NA',
        post?.userName ?? '-',
        isGivePost,
      ),
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
                      _buildRecipientCard(post, isGivePost),
                      SizedBox(height: 24.h),
                      Text(
                        isGivePost
                            ? 'Give ( What will you offer in Return? )'
                            : 'Take ( What you want in Return? )',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildReturnOption(
                        type: ReturnType.existing,
                        title: isGivePost
                            ? "Give what ${post?.userName ?? '-'}’s asking for"
                            : "Take what ${post?.userName ?? '-'}’s giving",
                        child: _buildItemPreviewCard(post),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.customItem,
                        title: isGivePost
                            ? "Item You Offer in Return"
                            : "Item You Want in Return",
                        subtitle: isGivePost
                            ? "Fill details of the item you're offering"
                            : "Fill item details you want in return",
                        child: _buildCustomItemForm(),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.money,
                        title: isGivePost
                            ? "Money ( Ask for Money )"
                            : "Ask for Money",
                        subtitle: isGivePost
                            ? "Offer a price for the item"
                            : "Set a custom price for the item",
                        child: _buildMoneyForm(isGivePost),
                      ),
                      SizedBox(height: 12.h),
                      _buildReturnOption(
                        type: ReturnType.free,
                        title: isGivePost ? "Ask for Free" : "Give For Free",
                        subtitle: "Spread some joy in the neighborhood",
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
            child: _buildBottomAction(isGivePost),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String itemName, String userName, bool isGivePost) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor, size: 20.sp),
      ),
      centerTitle: true,
      title: Text(
        isGivePost
            ? 'Take $itemName from $userName'
            : 'Give $itemName to $userName',
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
          color: isActive ? context.primaryColor : greyColorWithOpacity0_4,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildRecipientCard(dynamic post, bool isGivePost) {
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
                              isGivePost ? 'GIVER' : 'TAKER',
                              style: TextStyle(
                                color: context.primaryColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              post?.userName ?? '-',
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
                      '${post?.userName ?? '-'}’s ${isGivePost ? 'Giving' : 'Taking'}',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      post?.itemName ?? 'NA',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: FontFamily.openSans,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildIconLabel(
                        context,
                        Icons.swap_horiz,
                        '${isGivePost ? 'Give' : 'Take'} Type : ',
                        post?.tradeType ?? 'Permanent'),
                    SizedBox(height: 4.h),
                    _buildIconLabel(context, Icons.category_outlined,
                        'Category : ', post?.itemCategory ?? 'Other'),
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
                      image: DecorationImage(
                        image: (post?.itemImages != null &&
                                post!.itemImages.isNotEmpty)
                            ? NetworkImage(AppCachedImage.getFormattedUrl(
                                post.itemImages.first))
                            : (post?.returnItemImages != null &&
                                    post!.returnItemImages.isNotEmpty)
                                ? NetworkImage(AppCachedImage.getFormattedUrl(
                                    post.returnItemImages.first))
                                : const AssetImage('assets/iphone.png')
                                    as ImageProvider,
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
                          '${post?.distanceKm?.toStringAsFixed(1) ?? '0.4'} km away',
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
                ? context.primaryColor.withOpacity(0.1)
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
                      color: isSelected
                          ? context.primaryColor
                          : context.dividerColor,
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
                              color: context.primaryColor,
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

  Widget _buildItemPreviewCard(dynamic post) {
    if (post?.returnType == 'Price') {
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
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.payments_outlined,
                  color: context.primaryColor, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post?.postType == 'give'
                        ? 'Price Offer Requested'
                        : 'Price Offer Provided',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    '₹${post.priceMin?.toStringAsFixed(2) ?? '0'} - ₹${post.priceMax?.toStringAsFixed(2) ?? '0'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
              image: DecorationImage(
                image: (post?.returnItemImages != null &&
                        post!.returnItemImages.isNotEmpty)
                    ? NetworkImage(AppCachedImage.getFormattedUrl(
                        post.returnItemImages.first)) as ImageProvider
                    : (post?.itemImages != null && post!.itemImages.isNotEmpty)
                        ? NetworkImage(AppCachedImage.getFormattedUrl(
                            post.itemImages.first)) as ImageProvider
                        : const AssetImage('assets/iphone.png'),
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
                  post?.returnItemName ??
                      (post?.postType == 'give'
                          ? 'Requested Item'
                          : 'Offered Item'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                  ),
                ),
                Text(
                  post?.returnItemCategory ?? 'Other',
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
        Text('Item Name', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildTextField('Enter item name', controller: _itemNameController),
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
        Text('Description', style: _labelStyle()),
        SizedBox(height: 8.h),
        _buildTextField('Describe your product here...',
            maxLines: 4, controller: _descriptionController),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildCheckbox(context, 'Homemade', _isHomemade, (val) {
              setState(() {
                _isHomemade = val ?? false;
                if (_isHomemade) _isStoreBought = false;
              });
            }),
            SizedBox(width: 20.w),
            _buildCheckbox(context, 'Store bought', _isStoreBought, (val) {
              setState(() {
                _isStoreBought = val ?? false;
                if (_isStoreBought) _isHomemade = false;
              });
            }),
          ],
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
                    color: Colors.grey, size: 30.sp),
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
    );
  }

  Widget _buildMoneyForm(bool isGivePost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        AppPriceRangeSelector(
          initialValues: _priceRange,
          label: isGivePost ? 'Your Price Offer' : 'Desired Price Range',
          onChanged: (val) => setState(() => _priceRange = val),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _isNegotiable,
                activeColor: Colors.green,
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

  TextStyle _labelStyle({double size = 12}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: size.sp,
      fontFamily: FontFamily.openSans,
      color: context.textColor,
    );
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
        hintStyle: TextStyle(
            color: context.subTextColor.withOpacity(0.5), fontSize: 13.sp),
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

  Widget _buildDropdown(String hint) {
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

        return DropdownButtonFormField<CategoryModel>(
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
          ),
          hint: Text(hint,
              style: TextStyle(color: context.subTextColor, fontSize: 13.sp)),
          isExpanded: true,
          value: _selectedCategory,
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
          onChanged: (CategoryModel? val) {
            setState(() {
              _selectedCategory = val;
              _selectedCategoryId = val?.id;
            });
          },
        );
      },
    );
  }

  Widget _buildConditionChip(String label) {
    bool isSelected = _customItemCondition == label;
    return GestureDetector(
      onTap: () => setState(() => _customItemCondition = label),
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

  Widget _buildCheckbox(BuildContext context, String label, bool value,
      ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.w,
          child: Checkbox(
            value: value,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool isGivePost) {
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
      child: Consumer<TradeController>(
        builder: (context, controller, child) {
          final post = controller.selectedPost;
          if (post != null && post.hasResponded) {
            return const SizedBox.shrink();
          }
          return ElevatedButton(
            onPressed: controller.isLoading ? null : _handleOfferSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: controller.isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: context.onPrimaryColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _getButtonName(isGivePost),
                    style: TextStyle(
                      color: context.onPrimaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
