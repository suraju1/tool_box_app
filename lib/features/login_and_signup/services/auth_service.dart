import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_response_models.dart';

/// Service class for authentication API calls
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Complete user profile
  /// Returns AuthResponse with user data and JWT token
  Future<ApiResponse<AuthResponse>> completeProfile(
    RegisterRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.completeProfile,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (data) => AuthResponse.fromJson(data),
    );
  }

  /// Login with phone number
  /// Returns LoginResponse with OTP details
  Future<ApiResponse<LoginResponse>> login(
    LoginRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (data) => LoginResponse.fromJson(data),
    );
  }

  /// Verify OTP code
  /// Returns AuthResponse with user data and JWT token
  Future<ApiResponse<AuthResponse>> verifyOtp(
    VerifyOtpRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (data) => AuthResponse.fromJson(data),
    );
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post(ApiConstants.logout);

    return ApiResponse.fromJson(
      response.data,
      null, // No data expected for logout
    );
  }
}
