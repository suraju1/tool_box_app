class BlockedUserModel {
  final int id;
  final String fullName;
  final String? location;
  final String? profileImage;
  final String? bio;
  final String avgStars;
  final int totalRatings;
  final String blockedAt;

  BlockedUserModel({
    required this.id,
    required this.fullName,
    this.location,
    this.profileImage,
    this.bio,
    required this.avgStars,
    required this.totalRatings,
    required this.blockedAt,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      location: json['location'],
      profileImage: json['profile_image'],
      bio: json['bio'],
      avgStars: json['avg_stars']?.toString() ?? '0.0',
      totalRatings: json['total_ratings'] ?? 0,
      blockedAt: json['blocked_at'] ?? '',
    );
  }
}
