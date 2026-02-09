import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Validate phone number
  bool _validatePhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ToastService.showErrorToast(context, 'Please enter your phone number');
      return false;
    }
    if (phone.length != 10) {
      ToastService.showErrorToast(context, 'Phone number must be 10 digits');
      return false;
    }
    return true;
  }

  /// Handle login/get OTP
  Future<void> _handleGetOtp() async {
    // Validate phone
    if (!_validatePhone()) {
      return;
    }

    // Clear previous errors
    context.read<AuthController>().clearError();

    // Create login request
    final request = LoginRequest(phoneNumber: _phoneController.text.trim());

    // Call login API
    final authController = context.read<AuthController>();
    final isRegistered = await authController.loginUser(request);

    if (!mounted) return;

    if (authController.errorMessage != null) {
      // Show error
      ToastService.showErrorToast(context, authController.errorMessage!);
      return;
    }

    if (isRegistered) {
      // Show success message from backend
      final message = authController.successMessage ?? 'OTP sent successfully';
      ToastService.showSuccessToast(context, message);

      // Wait a moment for toast to be visible, then navigate
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // User is registered, navigate to OTP screen
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: _phoneController.text.trim(),
      );
    } else {
      // User is not registered, show message and navigate to signup
      ToastService.showErrorToast(context, 'Phone number not registered');

      // Wait a moment for toast to be visible, then navigate
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to signup screen with phone number
      Navigator.pushNamed(
        context,
        AppRoutes.signUp,
        arguments: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 120.w,
                  height: 120.h,
                ),

                SizedBox(height: 60.h),

                // Login title
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: defoultColor,
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Please Enter Your Phone Number',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.openSans,
                    color: context.subTextColor,
                  ),
                ),

                SizedBox(height: 30.h),

                // Phone input
                Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: greyColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16.w),
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: context.subTextColor,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      VerticalDivider(
                        thickness: 1.w,
                        color: greyColor.withOpacity(0.5),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                              fontSize: 16.sp, color: context.textColor),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                            FilteringTextInputFormatter.deny(RegExp(r'^91')),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.h),
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: FontFamily.openSans,
                              color: context.subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 75.h),

                // Get OTP button
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading ? null : _handleGetOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: defoultColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 4,
                          shadowColor: defoultColor.withOpacity(0.5),
                          disabledBackgroundColor:
                              defoultColor.withOpacity(0.6),
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
                                'Get OTP',
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

                // Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'or ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.subTextColor,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: defoultColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.openSans,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
