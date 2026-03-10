class UserProfileModel {
  final UserDetails userDetails;
  final TradeStats tradeStats;
  final List<Review> reviews;

  UserProfileModel({
    required this.userDetails,
    required this.tradeStats,
    required this.reviews,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userDetails: UserDetails.fromJson(json['user_details'] ?? {}),
      tradeStats: TradeStats.fromJson(json['trade_stats'] ?? {}),
      reviews:
          (json['reviews'] as List?)?.map((e) => Review.fromJson(e)).toList() ??
              [],
    );
  }
}

class UserDetails {
  final int id;
  final String fullName;
  final String? location;
  final String? image;
  final String? bio;
  final String? email;
  final String? phoneNumber;
  final int profileVisibility;
  final String averageRating;
  final int totalReviews;

  UserDetails({
    required this.id,
    required this.fullName,
    this.location,
    this.image,
    this.bio,
    this.email,
    this.phoneNumber,
    this.profileVisibility = 1,
    required this.averageRating,
    required this.totalReviews,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      location: json['location'],
      image: json['image'],
      bio: json['bio'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profileVisibility: json['profile_visibility'] ?? 1,
      averageRating: json['average_rating']?.toString() ?? '0.0',
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}

class TradeStats {
  final int totalGives;
  final int totalTakes;
  final int totalTrades;

  TradeStats({
    required this.totalGives,
    required this.totalTakes,
    required this.totalTrades,
  });

  factory TradeStats.fromJson(Map<String, dynamic> json) {
    return TradeStats(
      totalGives: json['total_gives'] ?? 0,
      totalTakes: json['total_takes'] ?? 0,
      totalTrades: json['total_trades'] ?? 0,
    );
  }
}

class Review {
  final int id;
  final int userId;
  final int reviewerId;
  final String reviewerName;
  final String? reviewerImage;
  final dynamic rating;
  final String? feedbackLabel;
  final String? comment;
  final String createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImage,
    required this.rating,
    this.feedbackLabel,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      reviewerId: json['reviewer_id'] ?? 0,
      reviewerName: json['reviewer_name'] ?? 'User',
      reviewerImage: json['reviewer_image'],
      rating: json['rating'] ?? 0,
      feedbackLabel: json['feedback_label'],
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
