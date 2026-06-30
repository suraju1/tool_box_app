import 'dart:io';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/core/widgets/app_price_range_selector.dart';

class WebTradeReturnSearchScreen extends StatefulWidget {
  const WebTradeReturnSearchScreen({super.key});

  @override
  State<WebTradeReturnSearchScreen> createState() =>
      _WebTradeReturnSearchScreenState();
}

class _WebTradeReturnSearchScreenState
    extends State<WebTradeReturnSearchScreen> {
  bool _isPriceSelected = true;
  RangeValues _priceRange = const RangeValues(10, 50000);
  bool _isNegotiable = false;
  String _returnSelectedCondition = 'New';
  bool _isReturnHomemade = false;
  bool _isReturnStoreBought = false;
  final List<XFile> _returnItemImages = [];

  Future<void> _pickImage() async {
    final int remaining = 5 - _returnItemImages.length;
    if (remaining <= 0) {
      ToastService.showErrorToast(context, 'Max 5 images allowed');
      return;
    }

    final List<XFile>? images = await AppImagePickerBS.show(context,
        allowMultiple: true, limit: remaining);

    if (images != null && images.isNotEmpty) {
      setState(() {
        if (_returnItemImages.length + images.length > 5) {
          final int toTake = 5 - _returnItemImages.length;
          _returnItemImages.addAll(images.take(toTake));
          ToastService.showErrorToast(
              context, 'Only first $toTake images added (Max 5 allowed)');
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: context.dividerColor.withOpacity(0.5)),
                      boxShadow: context.isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.step1Of4,
                          style: TextStyle(
                            color: context.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.whatDoYouWantIn1,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: context.textColor,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? Colors.white10
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(height: 32),
                        if (_isPriceSelected)
                          _buildPriceSection()
                        else
                          _buildReturnItemDetailsSection(),
                        const SizedBox(height: 48),
                        _buildBottomAction(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: context.textColor),
      ),
      centerTitle: false,
      title: Text(
        AppLocalizations.of(context)!.takeIt,
        style: TextStyle(
          color: context.textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.dividerColor.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              _buildStepSegment(isActive: true),
              _buildStepSegment(isActive: false),
              _buildStepSegment(isActive: false),
              _buildStepSegment(isActive: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepSegment({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? context.primaryColor
              : context.dividerColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        color: context.scaffoldBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.setYourAcceptablePriceRange,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          AppPriceRangeSelector(
            initialValues: _priceRange,
            onChanged: (val) => setState(() => _priceRange = val),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Switch(
                  value: _isNegotiable,
                  activeColor: Colors.green,
                  onChanged: (val) => setState(() => _isNegotiable = val),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.negotiable,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.allowBuyersToMakeCounter,
                        style: TextStyle(
                            color: context.subTextColor, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemDetailsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Form)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Item Name'),
              const SizedBox(height: 8),
              _buildTextField('Enter item name'),
              const SizedBox(height: 24),
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildDropdown('Select Category'),
              const SizedBox(height: 24),
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField('Describe your product here...', maxLines: 4),
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Right Column (Images & Condition)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Condition'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildReturnConditionChip('New'),
                  _buildReturnConditionChip('Like New'),
                  _buildReturnConditionChip('Used'),
                ],
              ),
              const SizedBox(height: 32),
              _buildLabel('Type'),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isReturnHomemade,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _isReturnHomemade = val ?? false;
                            if (_isReturnHomemade) _isReturnStoreBought = false;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.homemade,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _isReturnStoreBought,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _isReturnStoreBought = val ?? false;
                            if (_isReturnStoreBought) _isReturnHomemade = false;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.storeBought,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildLabel('Photos (${_returnItemImages.length}/5)'),
              const SizedBox(height: 12),
              _buildAddPhotosSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  Widget _buildReturnConditionChip(String label) {
    bool isSelected = _returnSelectedCondition == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _returnSelectedCondition = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    isSelected ? context.primaryColor : context.dividerColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : context.subTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
        hintStyle: TextStyle(color: context.subTextColor, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: context.subTextColor, size: 20)
            : null,
        filled: true,
        fillColor: context.scaffoldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.dividerColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.dividerColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: _returnItemImages.length >= 5
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _returnItemImages.length >= 5 ? null : _pickImage,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white10
                    : context.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _returnItemImages.length >= 5
                      ? Colors.grey.withOpacity(0.3)
                      : context.dividerColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: _returnItemImages.length >= 5
                          ? Colors.grey
                          : context.subTextColor,
                      size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _returnItemImages.length >= 5
                        ? 'Max 5 photos reached'
                        : 'Click to add photos',
                    style: TextStyle(
                        color: _returnItemImages.length >= 5
                            ? Colors.grey
                            : context.subTextColor,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_returnItemImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              _returnItemImages.length,
              (index) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: kIsWeb
                            ? NetworkImage(_returnItemImages[index].path)
                                as ImageProvider
                            : FileImage(File(_returnItemImages[index].path)),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                          color: context.dividerColor.withOpacity(0.5)),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4)
                            ],
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? context.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: context.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (context.isDarkMode ? Colors.white54 : Colors.black54),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint,
              style: TextStyle(color: context.subTextColor, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 240,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.tradeOffer);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            AppLocalizations.of(context)!.continueText,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
