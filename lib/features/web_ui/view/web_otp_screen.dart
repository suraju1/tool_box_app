import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';

class WebOtpScreen extends StatefulWidget {
  const WebOtpScreen({super.key});

  @override
  State<WebOtpScreen> createState() => _WebOtpScreenState();
}

class _WebOtpScreenState extends State<WebOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
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

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _validateOtp() {
    final otp = _getOtpCode();
    if (otp.length != 6) {
      ToastService.showErrorToast(context, 'Please enter complete 6-digit OTP');
      return false;
    }
    return true;
  }

  Future<void> _handleVerifyOtp() async {
    if (!_validateOtp()) return;

    if (_phoneNumber == null) {
      ToastService.showErrorToast(context, 'Phone number not found. Please try again.');
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.signInWithOtp(_getOtpCode(), _phoneNumber!);

    if (!mounted) return;

    if (success) {
      final user = authController.currentUser;
      if (user != null) {
        context.read<LocationController>().updateFromUserData(
              lat: user.latitude,
              lng: user.longitude,
              address: user.location,
            );
      }

      final message = authController.successMessage ?? 'OTP verified successfully';
      ToastService.showSuccessToast(context, message);

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (user != null && user.isProfileComplete == 1) {
        context.read<BottomNavBarController>().reset();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.bottomNavBar,
          (route) => false,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.signUp,
          arguments: _phoneNumber,
        );
      }
    } else {
      final error = authController.errorMessage;
      if (error != null) {
        ToastService.showErrorToast(context, error);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend || _phoneNumber == null) return;

    final authController = context.read<AuthController>();
    await authController.verifyPhoneNumber(_phoneNumber!);

    if (!mounted) return;

    if (authController.errorMessage != null) {
      ToastService.showErrorToast(context, authController.errorMessage!);
    } else {
      _startTimer();
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      ToastService.showSuccessToast(context, 'OTP resent successfully');
    }
  }

  String _formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
              color: context.isDarkMode ? const Color(0xFF151515) : const Color(0xFFE8F0FE),
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
                            Icons.security,
                            size: 100,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Secure Access',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            fontFamily: FontFamily.openSans,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your security is our top priority. We use secure\nOTP verification to protect your account.',
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
                  Positioned(
                    top: 32,
                    left: 32,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: context.textColor, size: 28),
                      tooltip: 'Back to Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Pane: OTP Form
          Expanded(
            flex: 1,
            child: Container(
              color: context.surfaceColor,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontFamily.openSans,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: FontFamily.openSans,
                            color: context.subTextColor,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Enter the 6-digit verification code sent to\n'),
                            TextSpan(
                              text: _phoneNumber ?? 'your phone number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // 6 OTP input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 50,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.scaffoldBg,
                              border: Border.all(
                                color: _controllers[index].text.isNotEmpty
                                    ? context.primaryColor
                                    : context.isDarkMode
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                width: _controllers[index].text.isNotEmpty ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (event) {
                                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                                  if (_controllers[index].text.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
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
                                    _focusNodes[index - 1].requestFocus();
                                  } else if (value.length > 1) {
                                    String code = value;
                                    _controllers[index].text = "";
                                    for (int i = 0; i < code.length; i++) {
                                      if (index + i < 6) {
                                        _controllers[index + i].text = code[i];
                                      }
                                    }
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
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryColor,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  counterText: '',
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Timer and Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.subTextColor,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Didn't receive code? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.subTextColor,
                                  fontFamily: FontFamily.openSans,
                                ),
                              ),
                              MouseRegion(
                                cursor: _canResend ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                child: GestureDetector(
                                  onTap: _canResend ? _handleResendOtp : null,
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _canResend ? context.primaryColor : greyColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontFamily.openSans,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Action Button
                      Consumer<AuthController>(
                        builder: (context, authController, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authController.isVerifyingOtp ? null : _handleVerifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: context.primaryColor.withOpacity(0.6),
                              ),
                              child: authController.isVerifyingOtp
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Verify Account',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
