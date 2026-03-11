import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Form state
  // Form state
  String _gender = 'Male';
  bool _agreeToTerms = false;
  DateTime? _selectedDate;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  bool _locationFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get phone number from route arguments if available
    final phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
    if (phoneNumber != null && _phoneController.text.isEmpty) {
      _phoneController.text = phoneNumber;
    }

    // Fetch location automatically (only once)
    if (!_locationFetched) {
      _locationFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchUserLocation();
      });
    }
  }

  /// Fetch user location and update controller
  Future<void> _fetchUserLocation() async {
    final locationController = context.read<LocationController>();
    final success = await locationController.fetchLocation();

    if (mounted) {
      if (success && locationController.address != null) {
        setState(() {
          _locationController.text = locationController.address!;
        });
      } else if (!success) {
        final error =
            locationController.errorMessage ?? 'Unable to fetch location';
        ToastService.showErrorToast(context, error);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  /// Validate name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Validate DOB
  String? _validateDOB(String? value) {
    if (_selectedDate == null) {
      return 'Date of Birth is required';
    }
    return null;
  }

  /// Validate location
  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    return null;
  }

  /// Handle registration
  Future<void> _handleRegister() async {
    // Clear previous errors
    context.read<AuthController>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms acceptance
    if (!_agreeToTerms) {
      ToastService.showErrorToast(
          context, 'Please accept the Terms & Privacy Policy');
      return;
    }

    // Check date of birth
    if (_selectedDate == null) {
      ToastService.showErrorToast(context, 'Please select your date of birth');
      return;
    }

    // Get location from LocationController
    final locationController = context.read<LocationController>();
    final latitude = locationController.latitude ?? 0.0;
    final longitude = locationController.longitude ?? 0.0;

    // Get AuthController
    final authController = context.read<AuthController>();

    // Get user ID from AuthController
    final currentUser = authController.currentUser;
    if (currentUser == null) {
      ToastService.showErrorToast(
          context, 'User session invalid. Please login again.');
      return;
    }

    // Format date as YYYY-MM-DD
    final formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    // Create registration request
    final request = RegisterRequest(
      userId: currentUser.id,
      phoneNumber: _phoneController.text.trim(),
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: formattedDate,
      gender: _gender,
      location: _locationController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      termsAccepted: _agreeToTerms,
    );

    // Call registration API
    final success = await authController.completeProfile(request);

    if (!mounted) return;

    if (success) {
      // Show success message from backend
      final message =
          authController.successMessage ?? 'Profile completed successfully';
      ToastService.showSuccessToast(context, message);

      // Wait a moment for toast to be visible, then navigate
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to Home
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.bottomNavBar,
        (route) => false,
      );
    } else {
      // Show error
      final error = authController.errorMessage;
      if (error != null) {
        ToastService.showErrorToast(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: context.primaryColor,
                    fontFamily: FontFamily.openSans,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Just a few details to get started',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.subTextColor,
                    fontFamily: FontFamily.openSans,
                  ),
                ),
                SizedBox(height: 32.h),
                _buildTextField(
                  label: 'Full Name',
                  hint: 'Enter Your Name',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: _validateName,
                ),
                SizedBox(height: 15.h),
                _buildTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: _validatePhone,
                  readOnly: true,
                ),
                SizedBox(height: 15.h),
                _buildTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 15.h),
                _buildTextField(
                  label: 'Date of Birth',
                  hint: 'Select your date of birth',
                  icon: Icons.calendar_today_outlined,
                  controller: _dobController,
                  readOnly: true,
                  validator: _validateDOB,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now()
                          .subtract(Duration(days: 6570)), // 18 years ago
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildRadioButton('Male'),
                    _buildRadioButton('Female'),
                    _buildRadioButton('Other'),
                  ],
                ),
                SizedBox(height: 10.h),
                Consumer<LocationController>(
                  builder: (context, locationController, child) {
                    return _buildTextField(
                      label: 'Location/Address',
                      hint: 'Detecting location...',
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                      readOnly: true,
                      validator: _validateLocation,
                      suffix: locationController.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      context.primaryColor),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _fetchUserLocation,
                              icon: Icon(
                                Icons.my_location,
                                color: context.primaryColor,
                                size: 20.sp,
                              ),
                            ),
                    );
                  },
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                      activeColor: context.primaryColor,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(
                            color: context.subTextColor,
                            fontSize: 14.sp,
                            fontFamily: FontFamily.openSans,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Privacy Policy',
                              style: TextStyle(
                                color: context.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 4,
                          disabledBackgroundColor:
                              context.primaryColor.withOpacity(0.6),
                        ),
                        child: authController.isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: context.subTextColor,
              fontFamily: FontFamily.openSans,
            ),
            prefixIcon: Icon(icon, color: context.subTextColor, size: 20.sp),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: context.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          onChanged: (String? val) {
            setState(() {
              _gender = val!;
            });
          },
          activeColor: context.primaryColor,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: context.subTextColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ],
    );
  }
}
