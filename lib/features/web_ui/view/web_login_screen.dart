import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _lastShownError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    try {
      context.read<AuthController>().removeListener(_onAuthStateChanged);
    } catch (_) {}
    _phoneController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    final authController = context.read<AuthController>();

    if (authController.errorMessage != null &&
        authController.errorMessage != _lastShownError) {
      _lastShownError = authController.errorMessage;
      ToastService.showErrorToast(context, authController.errorMessage!);
    }

    if (authController.errorMessage == null) {
      _lastShownError = null;
    }
  }

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

  Future<void> _handleGetOtp() async {
    if (!_validatePhone()) return;

    _lastShownError = null;
    context.read<AuthController>().clearError();

    final authController = context.read<AuthController>();
    await authController.verifyPhoneNumber(_phoneController.text.trim());
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
                  // You can replace this with a real illustration/image
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
                            Icons.handyman_outlined,
                            size: 100,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Join the Community',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            fontFamily: FontFamily.openSans,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Access thousands of tools shared by\npeople around you.',
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
          
          // Right Pane: Login Form
          Expanded(
            flex: 1,
            child: Container(
              color: context.surfaceColor,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo_transperant.png',
                            color: context.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontFamily.openSans,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please enter your phone number to sign in or create a new account.',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: FontFamily.openSans,
                          color: context.subTextColor,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Phone Input
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _phoneError != null
                                ? Colors.red
                                : context.isDarkMode
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.subTextColor,
                                fontFamily: FontFamily.openSans,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            VerticalDivider(
                              thickness: 1,
                              color: _phoneError != null
                                  ? Colors.red
                                  : context.isDarkMode
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(fontSize: 16, color: context.textColor),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                onSubmitted: (_) => _handleGetOtp(),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  hintText: 'Phone Number',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: FontFamily.openSans,
                                    color: context.subTextColor,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (_phoneError != null) {
                                    setState(() => _phoneError = null);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_phoneError != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _phoneError!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontFamily: FontFamily.openSans,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Status Message
                      Consumer<AuthController>(
                        builder: (context, authController, child) {
                          if (authController.statusMessage != null && authController.statusMessage!.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                authController.statusMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.primaryColor,
                                  fontFamily: FontFamily.openSans,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Action Button
                      Consumer<AuthController>(
                        builder: (context, authController, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authController.isSendingOtp ? null : _handleGetOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: context.primaryColor.withOpacity(0.6),
                              ),
                              child: authController.isSendingOtp
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Get OTP',
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
