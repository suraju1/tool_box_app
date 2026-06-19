import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/core/widgets/app_success_dialog.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/widgets/custom_profile_text_field.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:flutter/services.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Personal Details
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  late final TextEditingController _educationalQualificationController;

  // Controllers for Current Address
  late final TextEditingController _cityController;
  late final TextEditingController _pinCodeController;
  late final TextEditingController _addressController;

  // Controllers for Church Details
  late final TextEditingController _churchNameController;
  late final TextEditingController _pastorNameController;
  late final TextEditingController _churchPhoneController;

  // Controllers for Church Address
  late final TextEditingController _churchCityController;
  late final TextEditingController _churchPinCodeController;
  late final TextEditingController _churchAddressController;

  String? _selectedGender;
  String? _selectedOccupation;
  String? _selectedCountry;
  String? _selectedState;

  File? _selectedImage;
  bool _isInitialized = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _occupations = ['Business Owner', 'Employee', 'Student', 'Other'];
  final List<String> _countries = ['India', 'USA', 'UK', 'Australia', 'Canada'];
  final List<String> _states = ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'Gujarat'];

  @override
  void initState() {
    super.initState();
    _initControllers();
    
    final profileCtrl = context.read<ProfileController>();
    if (profileCtrl.ownProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileCtrl.getUserProfile(null, isOwnProfile: true);
      });
    } else {
      _populateData(profileCtrl.ownProfile!.userDetails);
    }
  }

  void _initControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _educationalQualificationController = TextEditingController();
    
    _cityController = TextEditingController();
    _pinCodeController = TextEditingController();
    _addressController = TextEditingController();
    
    _churchNameController = TextEditingController();
    _pastorNameController = TextEditingController();
    _churchPhoneController = TextEditingController();
    
    _churchCityController = TextEditingController();
    _churchPinCodeController = TextEditingController();
    _churchAddressController = TextEditingController();
  }

  void _populateData(dynamic user) {
    if (user == null || _isInitialized) return;
    
    _fullNameController.text = user.fullName;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _ageController.text = user.age?.toString() ?? '';
    _educationalQualificationController.text = user.educationalQualification ?? '';
    
    _cityController.text = user.city ?? '';
    _pinCodeController.text = user.pinCode ?? '';
    _addressController.text = user.address ?? '';
    
    _churchNameController.text = user.churchName ?? '';
    _pastorNameController.text = user.fatherOrPastorName ?? '';
    _churchPhoneController.text = user.churchPhoneNumber ?? '';
    
    _churchCityController.text = user.churchCity ?? '';
    _churchPinCodeController.text = user.churchPinCode ?? '';
    _churchAddressController.text = user.churchAddress ?? '';
    
    if (_genders.contains(user.gender)) _selectedGender = user.gender;
    if (_occupations.contains(user.occupation)) _selectedOccupation = user.occupation;
    if (_countries.contains(user.country)) _selectedCountry = user.country;
    if (_states.contains(user.state)) _selectedState = user.state;
    
    _isInitialized = true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _educationalQualificationController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _addressController.dispose();
    _churchNameController.dispose();
    _pastorNameController.dispose();
    _churchPhoneController.dispose();
    _churchCityController.dispose();
    _churchPinCodeController.dispose();
    _churchAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile>? images = await AppImagePickerBS.show(context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImage = File(images.first.path);
      });
    }
  }

  Future<void> _onSave(ProfileController controller) async {
    if (_formKey.currentState!.validate()) {
      final response = await controller.updateProfile(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _phoneController.text.trim(), // Can be omitted if strictly read-only
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        occupation: _selectedOccupation,
        educationalQualification: _educationalQualificationController.text.trim(),
        country: _selectedCountry,
        state: _selectedState,
        city: _cityController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        address: _addressController.text.trim(),
        churchName: _churchNameController.text.trim(),
        fatherOrPastorName: _pastorNameController.text.trim(),
        churchPhoneNumber: _churchPhoneController.text.trim(),
        churchCity: _churchCityController.text.trim(),
        churchPinCode: _churchPinCodeController.text.trim(),
        churchAddress: _churchAddressController.text.trim(),
        profileImage: _selectedImage,
      );

      if (context.mounted) {
        if (response.success) {
          AppSuccessDialog.show(
            context,
            message: 'Profile updated successfully',
            onButtonPressed: () {
              Navigator.pop(context);
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(controller.errorMessage ?? 'Update failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final user = controller.ownProfile?.userDetails;

    if (user != null && !_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _populateData(user);
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 320.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF759DFF), Color(0xFF4762C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                SizedBox(height: 20.h),
                _buildProfileHeader(user),
                SizedBox(height: 25.h),
                
                // Form Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    child: controller.isLoading && !_isInitialized
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('Personal Details'),
                                  CustomProfileTextField(
                                    label: 'Full Name',
                                    controller: _fullNameController,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Full name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomProfileTextField(
                                    label: 'Email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val != null && val.isNotEmpty) {
                                        final bool emailValid = RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(val);
                                        if (!emailValid) return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  // Phone with country code prefix
                                  CustomProfileTextField(
                                    label: 'Phone Number',
                                    controller: _phoneController,
                                    readOnly: true, // Read-only as per requirements
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 12.w),
                                        Text(
                                          '91',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down, size: 20.sp, color: Colors.grey),
                                        SizedBox(width: 8.w),
                                      ],
                                    ),
                                  ),
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomProfileTextField(
                                          label: 'Age',
                                          controller: _ageController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          validator: (val) {
                                            if (val != null && val.isNotEmpty && int.tryParse(val) == null) {
                                              return 'Invalid age';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomProfileDropdownField(
                                          label: 'Gender',
                                          value: _selectedGender,
                                          items: _genders,
                                          onChanged: (val) => setState(() => _selectedGender = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  CustomProfileDropdownField(
                                    label: 'Occupation',
                                    value: _selectedOccupation,
                                    items: _occupations,
                                    onChanged: (val) => setState(() => _selectedOccupation = val),
                                  ),
                                  
                                  CustomProfileTextField(
                                    label: 'Educational Qualification',
                                    controller: _educationalQualificationController,
                                  ),
                                  
                                  SizedBox(height: 10.h),
                                  _buildSectionHeader('Current Address'),
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomProfileDropdownField(
                                          label: 'Country',
                                          value: _selectedCountry,
                                          items: _countries,
                                          onChanged: (val) => setState(() => _selectedCountry = val),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomProfileDropdownField(
                                          label: 'State',
                                          value: _selectedState,
                                          items: _states,
                                          onChanged: (val) => setState(() => _selectedState = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomProfileTextField(
                                          label: 'City',
                                          controller: _cityController,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomProfileTextField(
                                          label: 'PIN Code',
                                          controller: _pinCodeController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  CustomProfileTextField(
                                    label: 'Address',
                                    controller: _addressController,
                                  ),
                                  
                                  SizedBox(height: 10.h),
                                  _buildSectionHeader('Church Details'),
                                  
                                  CustomProfileTextField(
                                    label: 'Church Name',
                                    controller: _churchNameController,
                                  ),
                                  
                                  CustomProfileTextField(
                                    label: 'Father Name / Pastor Name',
                                    controller: _pastorNameController,
                                  ),
                                  
                                  CustomProfileTextField(
                                    label: 'Phone Number',
                                    controller: _churchPhoneController,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 12.w),
                                        Text(
                                          '91',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down, size: 20.sp, color: Colors.grey),
                                        SizedBox(width: 8.w),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 10.h),
                                  // This is implicitly Church Address based on Figma labels
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomProfileTextField(
                                          label: 'City',
                                          controller: _churchCityController,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: CustomProfileTextField(
                                          label: 'PIN Code',
                                          controller: _churchPinCodeController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  CustomProfileTextField(
                                    label: 'Church Address',
                                    controller: _churchAddressController,
                                  ),
                                  
                                  SizedBox(height: 30.h),
                                  
                                  // Save Details Button
                                  controller.isLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : GestureDetector(
                                          onTap: () => _onSave(controller),
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 16.h),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30.r),
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF759DFF), Color(0xFF4762C9)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Save Details',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: FontFamily.openSans,
                                              ),
                                            ),
                                          ),
                                        ),
                                  
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60.r),
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 90.r,
                        height: 90.r,
                        fit: BoxFit.cover,
                      )
                    : AppCachedImage(
                        imageUrl: user?.image ?? '',
                        userName: user?.fullName ?? 'User',
                        width: 90.r,
                        height: 90.r,
                        fit: BoxFit.cover,
                        radius: 45.r,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, color: Colors.grey.shade800, size: 16.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          user?.fullName ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
