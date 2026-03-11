import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/location/view/map_address_picker_screen.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/app_success_dialog.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _bioController;

  bool _profileVisibility = true;
  bool _showTradeHistory = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileController>().ownProfile?.userDetails;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _mobileController = TextEditingController(text: profile?.phoneNumber ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _profileVisibility = profile?.profileVisibility == 1;
  }

  Future<void> _pickImage() async {
    final List<XFile>? images = await AppImagePickerBS.show(context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImage = File(images.first.path);
      });
    }
  }

  void _updateLocationFromController() {
    final locationController = context.read<LocationController>();
    if (mounted) {
      if (locationController.address != null) {
        setState(() {
          _locationController.text = locationController.address!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(),
                SizedBox(height: 15.h),
                _buildSectionTitle('Personal Information'),
                SizedBox(height: 10.h),
                _buildTextField('Full Name', _nameController),
                _buildTextField('Location', _locationController,
                    icon: Icons.location_on_outlined,
                    readOnly: true, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MapAddressPickerScreen(isPickOnly: true),
                    ),
                  ).then((_) => _updateLocationFromController());
                }),
                _buildTextField('Email Address', _emailController,
                    icon: Icons.email_outlined,
                    helperText: 'Used for notifications and account recovery'),
                _buildTextField('Mobile Number', _mobileController,
                    icon: Icons.phone_android_outlined,
                    helperText: 'Verified mobile number',
                    readOnly: true),
                SizedBox(height: 10.h),
                _buildSectionTitle('Bio'),
                SizedBox(height: 10.h),
                Text(
                  'Tell others about yourself',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.textColor,
                    fontFamily: FontFamily.openSans,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildBioField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w, top: 8.h),
                      child: Text(
                        '${_bioController.text.length}/150',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: greyColor,
                            fontFamily: FontFamily.openSans),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildSectionTitle('Profile Visibility'),
                _buildSwitchTile(
                    'Profile Visibility',
                    'Public: Anyone can view your profile.',
                    _profileVisibility,
                    (val) => setState(() => _profileVisibility = val)),
                // _buildSwitchTile(
                //     'Show Ratings',
                //     'Your ratings are visible to others.',
                //     _showRatings,
                //     (val) => setState(() => _showRatings = val)),
                _buildSwitchTile(
                    'Show Trade History',
                    'Your trade history is hidden from others.',
                    _showTradeHistory,
                    (val) => setState(() => _showTradeHistory = val)),
                SizedBox(height: 20.h),
                _buildSectionTitle('Wallet'),
                SizedBox(height: 10.h),
                _buildWalletCard(),
                SizedBox(height: 15.h),
                _buildSectionTitle('Account Actions'),
                SizedBox(height: 10.h),
                _buildActionText(
                    'Deactivate Account',
                    context.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700),
                _buildActionText('Delete Account', Colors.red),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          _buildSaveButton(controller),
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
        icon: Icon(Icons.arrow_back_ios, color: context.textColor),
      ),
      centerTitle: true,
      title: Text(
        'Edit Profile',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: Divider(height: 1, color: context.dividerColor),
      ),
    );
  }

  Widget _buildProfileImage() {
    final user = context.watch<ProfileController>().ownProfile?.userDetails;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.onPrimaryColor, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60.r),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 120.r,
                          height: 120.r,
                          fit: BoxFit.cover,
                        )
                      : AppCachedImage(
                          imageUrl: user!.image ?? '',
                          userName: user.fullName,
                          width: 120.r,
                          height: 120.r,
                          fit: BoxFit.cover,
                          radius: 60.r,
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: context.isDarkMode
                                ? Colors.black54
                                : Colors.black12,
                            blurRadius: 4)
                      ],
                    ),
                    child: Icon(Icons.camera_alt,
                        color: context.textColor, size: 24.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon,
      String? helperText,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14.sp,
                color: greyColor,
                fontFamily: FontFamily.openSans),
          ),
          SizedBox(height: 4.h),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly
                  ? (context.isDarkMode ? Colors.white10 : Colors.grey.shade100)
                  : context.surfaceColor,
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.grey.shade500, size: 20.sp)
                  : null,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
          ),
          if (helperText != null) ...[
            SizedBox(height: 4.h),
            Text(
              helperText,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                  fontFamily: FontFamily.openSans),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _bioController,
            maxLines: 4,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8.w),
              border: InputBorder.none,
              hintText: 'Enter your bio...',
              hintStyle: TextStyle(
                  fontSize: 10.sp,
                  color: context.textColor.withOpacity(0.5),
                  fontFamily: FontFamily.openSans),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                      fontFamily: FontFamily.openSans),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontFamily: FontFamily.openSans),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                    color: greyColorWithOpacity0_4,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: context.primaryColor, size: 25.sp),
              SizedBox(width: 8.w),
              Text(
                'Wallet Balance',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '₹120.00',
            style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: context.textColor),
          ),
          SizedBox(height: 4.h),
          Text(
            'Wallet balance cannot be edited',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildActionText(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 30.w),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: FontFamily.openSans),
      ),
    );
  }

  Widget _buildSaveButton(ProfileController controller) {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () async {
                final response = await controller.updateProfile(
                  fullName: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : null,
                  location: _locationController.text.isNotEmpty
                      ? _locationController.text
                      : null,
                  email: _emailController.text.isNotEmpty
                      ? _emailController.text
                      : null,
                  mobile: _mobileController.text.isNotEmpty
                      ? _mobileController.text
                      : null,
                  bio: _bioController.text.isNotEmpty
                      ? _bioController.text
                      : null,
                  profileVisibility: _profileVisibility ? 1 : 0,
                  profileImage: _selectedImage,
                );

                if (context.mounted) {
                  if (response.success) {
                    AppSuccessDialog.show(
                      context,
                      message: response.message,
                      onButtonPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(controller.errorMessage ?? 'Update failed')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
                shadowColor: context.primaryColor,
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: context.onPrimaryColor,
                    fontFamily: FontFamily.openSans),
              ),
            ),
    );
  }
}
