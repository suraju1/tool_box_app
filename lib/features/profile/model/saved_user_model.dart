class SavedUserModel {
  final int id;
  final String fullName;
  final String? location;
  final String? profileImage;
  final String? bio;
  final String avgStars;
  final int totalRatings;
  final String savedAt;

  SavedUserModel({
    required this.id,
    required this.fullName,
    this.location,
    this.profileImage,
    this.bio,
    required this.avgStars,
    required this.totalRatings,
    required this.savedAt,
  });

  factory SavedUserModel.fromJson(Map<String, dynamic> json) {
    return SavedUserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      location: json['location'],
      profileImage: json['profile_image'],
      bio: json['bio'],
      avgStars: json['avg_stars']?.toString() ?? '0.0',
      totalRatings: json['total_ratings'] ?? 0,
      savedAt: json['saved_at'] ?? '',
    );
  }
}
