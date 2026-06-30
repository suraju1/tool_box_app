import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class WebSignUpScreen extends StatefulWidget {
  const WebSignUpScreen({super.key});

  @override
  State<WebSignUpScreen> createState() => _WebSignUpScreenState();
}

class _WebSignUpScreenState extends State<WebSignUpScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length != 10) return 'Phone number must be 10 digits';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateDOB(String? value) {
    if (_selectedDate == null) return 'Date of Birth is required';
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) return 'Location is required';
    return null;
  }

  Future<void> _handleRegister() async {
    context.read<AuthController>().clearError();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ToastService.showErrorToast(
          context, 'Please accept the Terms & Privacy Policy');
      return;
    }

    if (_selectedDate == null) {
      ToastService.showErrorToast(context, 'Please select your date of birth');
      return;
    }

    final locationController = context.read<LocationController>();
    final latitude = locationController.latitude ?? 0.0;
    final longitude = locationController.longitude ?? 0.0;

    final authController = context.read<AuthController>();
    final currentUser = authController.currentUser;

    if (currentUser == null) {
      ToastService.showErrorToast(
          context, 'User session invalid. Please login again.');
      return;
    }

    final formattedDate =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

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

    final success = await authController.completeProfile(request);

    if (!mounted) return;

    if (success) {
      final message =
          authController.successMessage ?? 'Profile completed successfully';
      ToastService.showSuccessToast(context, message);

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      context.read<BottomNavBarController>().reset();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.bottomNavBar,
        (route) => false,
      );
    } else {
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
      body: Row(
        children: [
          // Left Pane: Illustration
          Expanded(
            flex: 1,
            child: Container(
              color: context.isDarkMode
                  ? const Color(0xFF151515)
                  : const Color(0xFFE8F0FE),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            size: 100,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          AppLocalizations.of(context)!.completeProfile,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            fontFamily: FontFamily.openSans,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.setUpYourAccountDetails,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: FontFamily.openSans,
                            color: context.subTextColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Pane: Form
          Expanded(
            flex: 1,
            child: Container(
              color: context.surfaceColor,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48.0, vertical: 24.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo_transperant.png',
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.justAFewDetails,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              fontFamily: FontFamily.openSans,
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!
                                .pleaseCompleteYourProfileTo,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: FontFamily.openSans,
                              color: context.subTextColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(
                            label: AppLocalizations.of(context)!.fullName,
                            hint: 'Enter Your Name',
                            icon: Icons.person_outline,
                            controller: _nameController,
                            validator: _validateName,
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: AppLocalizations.of(context)!.emailAddress,
                            hint: 'you@example.com',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: AppLocalizations.of(context)!.dateOfBirth,
                            hint: 'Select your date of birth',
                            icon: Icons.calendar_today_outlined,
                            controller: _dobController,
                            readOnly: true,
                            validator: _validateDOB,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .subtract(const Duration(days: 6570)),
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
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.gender,
                              style: TextStyle(
                                fontSize: 14,
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
                          const SizedBox(height: 16),
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
                                        height: 20,
                                        width: 20,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    context.primaryColor),
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: _fetchUserLocation,
                                        icon: Icon(
                                          Icons.my_location,
                                          color: context.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value!;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      color: context.subTextColor,
                                      fontSize: 14,
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
                          const SizedBox(height: 24),
                          Consumer<AuthController>(
                            builder: (context, authController, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authController.isLoading
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor:
                                        context.primaryColor.withOpacity(0.6),
                                  ),
                                  child: authController.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!
                                              .createAccount,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontFamily.openSans,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            fillColor: context.scaffoldBg,
            filled: true,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: context.subTextColor,
              fontFamily: FontFamily.openSans,
            ),
            prefixIcon: Icon(icon, color: context.subTextColor, size: 20),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : greyColor.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: context.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : greyColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Row(
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
                fontSize: 14,
                color: context.subTextColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
