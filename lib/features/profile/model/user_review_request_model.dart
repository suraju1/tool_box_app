class UserReviewRequestModel {
  final int userId;
  final int rating;
  final String feedbackLabel;
  final String comment;

  UserReviewRequestModel({
    required this.userId,
    required this.rating,
    required this.feedbackLabel,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'rating': rating,
      'feedback_label': feedbackLabel,
      'comment': comment,
    };
  }
}
