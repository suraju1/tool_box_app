import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

import 'package:tool_bocs/features/location/view/map_address_picker_screen.dart';

class LocationSelectionSheet extends StatefulWidget {
  const LocationSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationSelectionSheet(),
    );
  }

  @override
  State<LocationSelectionSheet> createState() => _LocationSelectionSheetState();
}

class _LocationSelectionSheetState extends State<LocationSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildSearchField(),
                SizedBox(height: 20.h),
                _buildUseCurrentLocation(context),
                _buildDivider(),
                _buildOptionItem(
                  icon: Icons.add,
                  title: 'Add new address',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapAddressPickerScreen(),
                      ),
                    );
                  },
                ),
                _buildOptionItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Request address from someone else',
                  iconColor: Colors.green,
                  onTap: () {},
                ),
                // _buildOptionItem(
                //   image:
                //       'assets/icons/zomato.png', // Fallback to icon if image missing
                //   title: 'Import your addresses from Zomato',
                //   onTap: () {},
                // ),
                SizedBox(height: 20.h),
                if (context
                    .watch<LocationController>()
                    .savedAddresses
                    .isNotEmpty) ...[
                  Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...context
                      .watch<LocationController>()
                      .savedAddresses
                      .map((addr) => _buildSavedAddressItem(addr)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select delivery location',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for area, street name...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: defoultColor, size: 22.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildUseCurrentLocation(BuildContext context) {
    final locationController = context.watch<LocationController>();
    return InkWell(
      onTap: () async {
        final success =
            await context.read<LocationController>().fetchLocation();
        if (success && mounted) {
          ToastService.showSuccessToast(
              context, 'Location updated successfully');
          Navigator.pop(context);
        } else if (mounted) {
          ToastService.showErrorToast(context,
              locationController.errorMessage ?? 'Failed to fetch location');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(Icons.my_location, color: defoultColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use current location',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: defoultColor,
                    ),
                  ),
                  Text(
                    locationController.address ??
                        'Enable GPS for accurate location',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    IconData? icon,
    String? image,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? defoultColor, size: 24.sp)
                else if (image != null)
                  Image.asset(image,
                      width: 24.w,
                      height: 24.h,
                      errorBuilder: (c, e, s) => Icon(Icons.location_city,
                          color: Colors.red, size: 24.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
              ],
            ),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildSavedAddressItem(Map<String, String> addr) {
    final locationController = context.watch<LocationController>();
    final isSelected = locationController.address == addr['address'];

    return InkWell(
      onTap: () {
        context.read<LocationController>().setLocation(
              double.parse(addr['lat']!),
              double.parse(addr['lng']!),
              addr['address']!,
            );
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Icon(Icons.home_outlined, color: Colors.grey, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        addr['label']!,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: defoultColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    addr['address']!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }
}
