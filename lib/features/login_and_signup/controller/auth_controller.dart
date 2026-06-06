import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_exception.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_response_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';
import 'package:tool_bocs/features/login_and_signup/services/auth_service.dart';
import 'package:tool_bocs/core/services/chat_listener.dart';
import 'package:tool_bocs/core/services/firebase_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/routes/navigator_key.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';

/// Controller for authentication state management
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  // Loading states
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _isLoggingIn = false;
  bool _isVerifyingOtp = false;

  // Error state
  String? _errorMessage;
  String? _statusMessage; // Real-time status

  // User data
  UserModel? _currentUser;
  String? _authToken;
  String? _successMessage;

  // Firebase Phone Auth
  String? _verificationId;
  int? _resendToken;
  bool _isSendingOtp = false;
  String?
      _backendOtpCode; // OTP returned by backend /login (used for /verify-otp)

  // Getters
  bool get isSendingOtp => _isSendingOtp;
  String? get verificationId => _verificationId;
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  bool get isLoggingIn => _isLoggingIn;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get errorMessage => _errorMessage;
  String? get statusMessage => _statusMessage;
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  /// Clear error message and status
  void clearError() {
    _errorMessage = null;
    _statusMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Complete user profile
  /// Returns true if profile completion successful
  Future<bool> completeProfile(RegisterRequest request) async {
    _isRegistering = true;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.completeProfile(request);

      if (response.success && response.data != null) {
        // Save success message
        _successMessage = response.message;

        // Save user data and token
        _currentUser = response.data!.user;
        if (response.data!.token.isNotEmpty) {
          _authToken = response.data!.token;
        }

        // Persist to storage
        await _saveAuthData(response.data!);

        // Set auth token in API client
        if (_authToken != null && _authToken!.isNotEmpty) {
          _apiClient.setAuthToken(_authToken!);
        }

        // Start Chat Listener after profile completion
        ChatListener().startListening();
        FirebaseNotificationService().saveTokenToFirestore();

        _isRegistering = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isRegistering = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isRegistering = false;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isRegistering = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify Phone Number — calls backend /login ONLY
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _isSendingOtp = true;
    _errorMessage = null;
    _statusMessage = "Sending OTP...";
    notifyListeners();

    debugPrint("[Auth] verifyPhoneNumber called with: '$phoneNumber'");

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      _statusMessage = null;
      _isSendingOtp = false;
      _errorMessage = "Invalid phone number. Please enter 10 digits.";
      debugPrint("[Auth] Validation failed — length: ${phoneNumber.length}");
      notifyListeners();
      return;
    }

    try {
      debugPrint("[Auth] Calling backend /login...");
      final loginRequest = LoginRequest(phoneNumber: '+91$phoneNumber');
      final loginResponse = await _authService.login(loginRequest);

      if (loginResponse.success && loginResponse.data != null) {
        _backendOtpCode = loginResponse.data!.otpCode;
        debugPrint("[Auth] Backend /login success — OTP stored ✅");

        _isSendingOtp = false;
        _statusMessage = null;
        notifyListeners();

        // Navigate to OTP screen
        debugPrint("[Auth] Navigating to OTP screen for: $phoneNumber");
        navigatorKey.currentState?.pushNamed(
          AppRoutes.otp,
          arguments: phoneNumber,
        );
      } else {
        debugPrint("[Auth] Backend /login failed: ${loginResponse.message}");
        _isSendingOtp = false;
        _statusMessage = null;
        _errorMessage = loginResponse.message;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("[Auth] Backend /login error: $e");
      _isSendingOtp = false;
      _statusMessage = null;
      _errorMessage = "Something went wrong. Please try again.";
      notifyListeners();
    }
  }

  /// Sign in with OTP (SMS Code) using Backend exclusively
  Future<bool> signInWithOtp(String smsCode, String phoneNumber) async {
    _isVerifyingOtp = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint("[Auth] Verifying OTP with backend for phone: $phoneNumber");

    try {
      final fcmToken = await FirebaseNotificationService.getFcmToken() ?? '';

      final request = VerifyOtpRequest(
        phoneNumber: phoneNumber,
        otpCode: smsCode,
        fcmToken: fcmToken,
      );

      final response = await _authService.verifyOtp(request);

      if (response.success && response.data != null) {
        debugPrint("[Auth] Backend /verify-otp success ✅");
        _successMessage = response.message;
        _currentUser = response.data!.user;
        _authToken = response.data!.token;

        await _saveAuthData(response.data!);

        if (_authToken != null) {
          _apiClient.setAuthToken(_authToken!);
        }

        // Sign in anonymously to Firebase for Firestore Chat support
        try {
          if (FirebaseAuth.instance.currentUser == null) {
            await FirebaseAuth.instance.signInAnonymously();
            debugPrint("[Auth] Firebase Anonymous Login Success ✅");
          }
        } catch (e) {
          debugPrint("[Auth] Firebase Anonymous Login Failed: $e");
        }

        ChatListener().startListening();
        FirebaseNotificationService().saveTokenToFirestore();

        _backendOtpCode = null;
        _isVerifyingOtp = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("[Auth] Backend /verify-otp failed: ${response.message}");
        _errorMessage = response.message;
        _isVerifyingOtp = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("[Auth] Error in signInWithOtp: $e");
      _errorMessage = "An unexpected error occurred during sign in.";
      _isVerifyingOtp = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  /// Returns true if verification successful
  Future<bool> verifyOtp(VerifyOtpRequest request) async {
    _isVerifyingOtp = true;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(request);

      if (response.success && response.data != null) {
        // Save success message
        _successMessage = response.message;

        // Save user data and token
        _currentUser = response.data!.user;
        if (response.data!.token.isNotEmpty) {
          _authToken = response.data!.token;
        }

        // Persist to storage
        await _saveAuthData(response.data!);

        // Set auth token in API client
        if (_authToken != null && _authToken!.isNotEmpty) {
          _apiClient.setAuthToken(_authToken!);
        }

        // Start Chat Listener only if profile is complete
        if (response.data!.isProfileComplete) {
          ChatListener().startListening();
          FirebaseNotificationService().saveTokenToFirestore();
        }

        _isVerifyingOtp = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isVerifyingOtp = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isVerifyingOtp = false;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isVerifyingOtp = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save authentication data to storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    if (authResponse.token.isNotEmpty) {
      await StorageService.saveAuthToken(authResponse.token);
    }
    await StorageService.saveUserData(jsonEncode(authResponse.user.toJson()));
    await StorageService.setLoggedIn(true);
  }

  /// Load authentication data from storage
  Future<void> loadAuthData() async {
    final token = await StorageService.getAuthToken();
    final userDataJson = await StorageService.getUserData();

    if (token != null && userDataJson != null) {
      _authToken = token;
      _currentUser = UserModel.fromJson(jsonDecode(userDataJson));
      _apiClient.setAuthToken(token);

      // Ensure Firebase auth for Firestore access (chat listener needs this)
      // If user already signed in via phone auth, use that. Otherwise, anonymous.
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
          debugPrint(
              "[Auth] Signed in to Firebase Anonymously for Firestore access");
        } else {
          debugPrint(
              "[Auth] Firebase user already exists: ${FirebaseAuth.instance.currentUser!.uid}");
        }
      } catch (e) {
        debugPrint("[Auth] Firebase Auth Failed in loadAuthData: $e");
      }

      // Start Chat Listener
      ChatListener().startListening();
      FirebaseNotificationService().saveTokenToFirestore();

      notifyListeners();
    }
  }

  /// Check if user is logged in
  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint("API Logout Failed: $e");
    }

    // Stop Chat Listener
    ChatListener().stopListening();

    _currentUser = null;
    _authToken = null;
    _apiClient.removeAuthToken();
    await StorageService.clearAuthData();

    // Reset Bottom Navigation Bar index to 0
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<BottomNavBarController>(context, listen: false).reset();
    }

    notifyListeners();

    // Navigate to login screen and clear navigation stack from root
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
}
