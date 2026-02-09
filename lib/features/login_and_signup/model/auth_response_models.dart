import 'package:tool_bocs/features/login_and_signup/model/user_model.dart';

/// Response model for registration check (login/register API)
class RegistrationCheckResponse {
  final bool isRegistered;
  final String phoneNumber;

  RegistrationCheckResponse({
    required this.isRegistered,
    required this.phoneNumber,
  });

  /// Create from JSON
  factory RegistrationCheckResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationCheckResponse(
      isRegistered: json['is_registered'] ?? false,
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'is_registered': isRegistered,
      'phone_number': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'RegistrationCheckResponse(isRegistered: $isRegistered, phoneNumber: $phoneNumber)';
  }
}

/// Response model for authentication (OTP verification)
class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  /// Create from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, token: $token)';
  }
}
