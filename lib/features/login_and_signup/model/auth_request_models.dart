/// Request model for user registration
class RegisterRequest {
  final int userId;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String location;
  final double latitude;
  final double longitude;
  final bool termsAccepted;

  RegisterRequest({
    required this.userId,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.termsAccepted,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'terms_accepted': termsAccepted,
    };
  }

  @override
  String toString() {
    return 'RegisterRequest(phoneNumber: $phoneNumber, fullName: $fullName, email: $email)';
  }
}

/// Request model for user login
class LoginRequest {
  final String phoneNumber;

  LoginRequest({required this.phoneNumber});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'LoginRequest(phoneNumber: $phoneNumber)';
  }
}

/// Request model for OTP verification
class VerifyOtpRequest {
  final String phoneNumber;
  final String otpCode;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.otpCode,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    };
  }

  @override
  String toString() {
    return 'VerifyOtpRequest(phoneNumber: $phoneNumber, otpCode: $otpCode)';
  }
}
