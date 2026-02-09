/// User model representing user data from API
class UserModel {
  final int id;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String location;
  final String latitude;
  final String longitude;
  final int isVerified;
  final int isProfileComplete;
  final int termsAccepted;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    required this.isProfileComplete,
    required this.termsAccepted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toString() ?? '0.0',
      longitude: json['longitude']?.toString() ?? '0.0',
      isVerified: json['is_verified'] ?? 0,
      isProfileComplete: json['is_profile_complete'] ?? 0,
      termsAccepted: json['terms_accepted'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_verified': isVerified,
      'is_profile_complete': isProfileComplete,
      'terms_accepted': termsAccepted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, fullName: $fullName, email: $email)';
  }
}
