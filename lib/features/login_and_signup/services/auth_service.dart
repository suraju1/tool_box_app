import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_request_models.dart';
import 'package:tool_bocs/features/login_and_signup/model/auth_response_models.dart';

/// Service class for authentication API calls
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register a new user
  /// Returns RegistrationCheckResponse indicating if phone is already registered
  Future<ApiResponse<RegistrationCheckResponse>> register(
    RegisterRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (data) => RegistrationCheckResponse.fromJson(data),
    );
  }

  /// Login with phone number
  /// Returns RegistrationCheckResponse indicating if phone is registered
  Future<ApiResponse<RegistrationCheckResponse>> login(
    LoginRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
      (data) => RegistrationCheckResponse.fromJson(data),
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
}
