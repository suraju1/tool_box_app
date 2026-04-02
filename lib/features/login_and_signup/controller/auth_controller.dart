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

  // User data
  UserModel? _currentUser;
  String? _authToken;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  bool get isLoggingIn => _isLoggingIn;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
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

        // Start Chat Listener
        try {
          // If backend provides a custom firebase token, use it
          // Otherwise fallback to anonymous for now
          // Note: response.data.firebaseToken is assumed to be the field if added to backend
          // For now, it will likely still be null until backend is updated
          await FirebaseAuth.instance.signInAnonymously();
          debugPrint("Signed in to Firebase Anonymously");
        } catch (e) {
          debugPrint("Firebase Auth Failed: $e");
        }

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

  /// Login with phone number
  /// Returns true if OTP sent successfully
  Future<bool> loginUser(LoginRequest request) async {
    _isLoggingIn = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        _successMessage = response.message;

        // We can access otpCode here if needed for debugging/auto-fill
        // print('OTP: ${response.data!.otpCode}');

        _isLoggingIn = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoggingIn = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggingIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoggingIn = false;
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

        // Start Chat Listener only if profile is complete (meaning fully logged in)
        if (response.data!.isProfileComplete) {
          try {
            // Future-proofing: check for custom token from backend
            // await FirebaseAuth.instance.signInWithCustomToken(customToken);
            await FirebaseAuth.instance.signInAnonymously();
            debugPrint("Signed in to Firebase Anonymously");
          } catch (e) {
            debugPrint("Firebase Auth Failed: $e");
          }
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

      // Start Chat Listener
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint("Signed in to Firebase Anonymously");
      } catch (e) {
        debugPrint("Firebase Auth Failed: $e");
      }
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
