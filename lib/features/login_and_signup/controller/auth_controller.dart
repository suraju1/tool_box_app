import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_exception.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_response_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';
import 'package:tool_bocs/features/login_and_signup/services/auth_service.dart';

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

  /// Register a new user
  /// Returns true if registration initiated successfully (OTP sent)
  /// Returns false if phone number already registered
  Future<bool> registerUser(RegisterRequest request) async {
    _isRegistering = true;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(request);

      if (response.success && response.data != null) {
        // Save success message
        _successMessage = response.message;

        // Check if phone is already registered
        if (response.data!.isRegistered) {
          // Phone already registered, should go to OTP screen
          _isRegistering = false;
          _isLoading = false;
          notifyListeners();
          return true; // Proceed to OTP
        } else {
          // Registration successful, OTP sent
          _isRegistering = false;
          _isLoading = false;
          notifyListeners();
          return true; // Proceed to OTP
        }
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
  /// Returns true if user is registered (proceed to OTP)
  /// Returns false if user is not registered (proceed to signup)
  Future<bool> loginUser(LoginRequest request) async {
    _isLoggingIn = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        final isRegistered = response.data!.isRegistered;

        if (isRegistered) {
          _successMessage = response.message;
        } else if (response.message.isNotEmpty) {
          _errorMessage = response.message;
        }

        _isLoggingIn = false;
        _isLoading = false;
        notifyListeners();
        return isRegistered;
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
        _authToken = response.data!.token;

        // Persist to storage
        await _saveAuthData(response.data!);

        // Set auth token in API client for future requests
        _apiClient.setAuthToken(_authToken!);

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
    await StorageService.saveAuthToken(authResponse.token);
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
      notifyListeners();
    }
  }

  /// Check if user is logged in
  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    _apiClient.removeAuthToken();
    await StorageService.clearAuthData();
    notifyListeners();
  }
}
