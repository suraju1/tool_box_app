import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';

/// Response model for login API
class LoginResponse {
  final bool isNewUser;
  final String phoneNumber;
  final String otpCode;

  LoginResponse({
    required this.isNewUser,
    required this.phoneNumber,
    required this.otpCode,
  });

  /// Create from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isNewUser: json['is_new_user'] ?? false,
      phoneNumber: json['phone_number'] ?? '',
      otpCode: json['otp_code'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'is_new_user': isNewUser,
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    };
  }

  @override
  String toString() {
    return 'LoginResponse(isNewUser: $isNewUser, phoneNumber: $phoneNumber, otpCode: $otpCode)';
  }
}

/// Response model for authentication (OTP verification)
class AuthResponse {
  final UserModel user;
  final String token;
  final bool isProfileComplete;

  AuthResponse({
    required this.user,
    required this.token,
    required this.isProfileComplete,
  });

  /// Create from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] ?? '',
      isProfileComplete: json['is_profile_complete'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'is_profile_complete': isProfileComplete,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, token: $token, isProfileComplete: $isProfileComplete)';
  }
}
