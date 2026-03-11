import 'dart:async';
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
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Changed from 4 to 6 OTP digits
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  String? _phoneNumber;
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get phone number from route arguments
    _phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Start countdown timer for resend OTP
  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  /// Get OTP code from controllers
  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  /// Validate OTP
  bool _validateOtp() {
    final otp = _getOtpCode();
    if (otp.length != 6) {
      ToastService.showErrorToast(context, 'Please enter complete 6-digit OTP');
      return false;
    }
    return true;
  }

  /// Handle OTP verification
  Future<void> _handleVerifyOtp() async {
    // Validate OTP
    if (!_validateOtp()) {
      return;
    }

    if (_phoneNumber == null) {
      ToastService.showErrorToast(
          context, 'Phone number not found. Please try again.');
      return;
    }

    // Clear previous errors
    context.read<AuthController>().clearError();

    // Create verify OTP request
    final request = VerifyOtpRequest(
      phoneNumber: _phoneNumber!,
      otpCode: _getOtpCode(),
    );

    // Call verify OTP API
    final authController = context.read<AuthController>();
    final success = await authController.verifyOtp(request);

    if (!mounted) return;

    if (success) {
      // Sync location data if available in user profile
      final user = authController.currentUser;
      if (user != null) {
        context.read<LocationController>().updateFromUserData(
              lat: user.latitude,
              lng: user.longitude,
              address: user.location,
            );
      }

      // Show success message from backend
      final message =
          authController.successMessage ?? 'OTP verified successfully';
      ToastService.showSuccessToast(context, message);

      // Wait a moment for toast to be visible, then navigate
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // Check if profile is complete
      if (user != null && user.isProfileComplete == 1) {
        // Reset Bottom Navigation Bar state to Home
        context.read<BottomNavBarController>().reset();

        // Navigate to home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.bottomNavBar,
          (route) => false,
        );
      } else {
        // Navigate to complete profile screen (SignUp)
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signUp,
          arguments: _phoneNumber,
        );
      }
    } else {
      // Show error
      final error = authController.errorMessage;
      if (error != null) {
        ToastService.showErrorToast(context, error);
      }
    }
  }

  /// Handle resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend || _phoneNumber == null) {
      return;
    }

    // Clear previous errors
    context.read<AuthController>().clearError();

    // Create login request to resend OTP
    final request = LoginRequest(phoneNumber: _phoneNumber!);

    // Call login API to resend OTP
    final authController = context.read<AuthController>();
    await authController.loginUser(request);

    if (!mounted) return;

    if (authController.errorMessage != null) {
      ToastService.showErrorToast(context, authController.errorMessage!);
    } else {
      // Restart timer
      _startTimer();
      // Clear OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      // Show success toast
      ToastService.showSuccessToast(context, 'OTP resent successfully');
    }
  }

  /// Format remaining time
  String _formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: context.textColor),
                  iconSize: 24.sp,
                ),
              ),
              SizedBox(height: 110.h),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Enter the verification code we just sent on\nyour phone number.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.subTextColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 48.h),
              // 6 OTP input fields
              // 6 OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      border: Border.all(
                        color: _controllers[index].text.isNotEmpty
                            ? context.primaryColor
                            : context.isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : greyColor.withOpacity(0.2),
                        width: _controllers[index].text.isNotEmpty ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
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
                    child: KeyboardListener(
                      focusNode:
                          FocusNode(), // Dummy node to receive events bubbling up
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace) {
                          if (_controllers[index].text.isEmpty && index > 0) {
                            // Move focus to previous field and clear it to allow easy re-typing
                            _focusNodes[index - 1].requestFocus();
                            // Optional: Clear previous field when backspacing into it?
                            // Usually "Move to prev" is enough, user can backspace again to clear.
                            // But usually users expect backspace to delete the prev char immediately
                            // if the current was empty? Let's stick to just moving focus.
                            // Actually, let's select the text in previous so typing replaces it?
                            // No, standard is just move focus.
                          }
                        }
                      },
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            // Handled by KeyboardListener mostly, but fallback for 1->0 transition
                            _focusNodes[index - 1].requestFocus();
                          } else if (value.length > 1) {
                            // Handle paste
                            String code = value;
                            // Reset current controller to first digit or empty (we will loop)
                            _controllers[index].text = "";

                            // Distribute
                            for (int i = 0; i < code.length; i++) {
                              if (index + i < 6) {
                                _controllers[index + i].text = code[i];
                              }
                            }

                            // Move focus to last filled
                            int nextIndex = index + code.length;
                            if (nextIndex >= 6) nextIndex = 5;
                            _focusNodes[nextIndex].requestFocus();
                            setState(() {});
                          }
                          setState(() {});
                        },
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          // Removed LengthLimitingTextInputFormatter to allow paste
                        ],
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: context.primaryColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          // Make entire box tappable/centered
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          counterText: '',
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 48.h),
              Text(
                _formatTime(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.subTextColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.subTextColor,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _handleResendOtp : null,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _canResend ? context.primaryColor : greyColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48.h),
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed:
                          authController.isLoading ? null : _handleVerifyOtp,
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
                      child: authController.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Verify',
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
            ],
          ),
        ),
      ),
    );
  }
}
