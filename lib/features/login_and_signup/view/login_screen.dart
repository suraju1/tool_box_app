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

  /// Track last shown error to avoid duplicate toasts
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    // Listen to AuthController changes for async callback errors
    // (verificationFailed fires AFTER await returns, so we need a listener)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    try {
      context.read<AuthController>().removeListener(_onAuthStateChanged);
    } catch (_) {}
    _phoneController.dispose();
    super.dispose();
  }

  /// React to AuthController state changes (handles async Firebase callbacks)
  void _onAuthStateChanged() {
    if (!mounted) return;
    final authController = context.read<AuthController>();

    // Show error toast when a NEW error arrives from async callbacks
    if (authController.errorMessage != null &&
        authController.errorMessage != _lastShownError) {
      _lastShownError = authController.errorMessage;
      debugPrint("[Login] Showing error toast: ${authController.errorMessage}");
      ToastService.showErrorToast(context, authController.errorMessage!);
    }

    // Reset tracking when error is cleared
    if (authController.errorMessage == null) {
      _lastShownError = null;
    }
  }

  String? _phoneError;

  /// Validate phone number
  bool _validatePhone() {
    setState(() {
      _phoneError = null;
    });
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Please enter your phone number';
      });
      return false;
    }
    if (phone.length != 10) {
      setState(() {
        _phoneError = 'Phone number must be 10 digits';
      });
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

    // Clear previous errors and reset tracking
    _lastShownError = null;
    context.read<AuthController>().clearError();

    debugPrint("[Login] User pressed Get OTP for phone: ${_phoneController.text.trim()}");

    // Call Firebase verifyPhoneNumber
    // NOTE: Navigation to OTP screen happens inside codeSent callback in AuthController.
    // Error display happens via _onAuthStateChanged listener above.
    final authController = context.read<AuthController>();
    await authController.verifyPhoneNumber(_phoneController.text.trim());

    debugPrint("[Login] verifyPhoneNumber returned. Callbacks will fire asynchronously.");
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
                Container(
                  width: 140.w,
                  height: 140.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo_transperant.png',
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 60.h),

                // Login title
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontFamily.openSans,
                    color: context.primaryColor,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _phoneError != null
                              ? Colors.red
                              : context.isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : greyColor.withOpacity(0.2),
                        ),
                        boxShadow: context.isDarkMode
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                            color: _phoneError != null
                                ? Colors.red
                                : context.isDarkMode
                                    ? Colors.white10
                                    : greyColor.withOpacity(0.2),
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
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12.h),
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: FontFamily.openSans,
                                  color: context.subTextColor,
                                ),
                              ),
                              onChanged: (value) {
                                if (_phoneError != null) {
                                  setState(() {
                                    _phoneError = null;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_phoneError != null) ...[
                      SizedBox(height: 6.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          _phoneError!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 75.h),

                // Status message while sending OTP
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    if (authController.statusMessage != null && authController.statusMessage!.isNotEmpty) {
                      return Column(
                        children: [
                          Text(
                            authController.statusMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.primaryColor,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),

                // Get OTP button
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed:
                            authController.isSendingOtp ? null : _handleGetOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 4,
                          shadowColor: context.primaryColor.withOpacity(0.4),
                          disabledBackgroundColor:
                              context.primaryColor.withOpacity(0.6),
                        ),
                        child: authController.isSendingOtp
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
                                  color: context.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 30.h),

                // Signup
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       'or ',
                //       style: TextStyle(
                //         fontSize: 14.sp,
                //         color: context.subTextColor,
                //         fontFamily: FontFamily.openSans,
                //       ),
                //     ),
                //     GestureDetector(
                //       onTap: () {
                //         Navigator.pushNamed(context, AppRoutes.signUp);
                //       },
                //       child: Text(
                //         'Signup',
                //         style: TextStyle(
                //           fontSize: 14.sp,
                //           color: context.primaryColor,
                //           fontWeight: FontWeight.w500,
                //           fontFamily: FontFamily.openSans,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
