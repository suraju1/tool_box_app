import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/model/user_review_request_model.dart';
import 'package:tool_bocs/features/profile/service/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfileModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getUserProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.fetchUserProfile(userId);

    if (response.success) {
      _userProfile = response.data;
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>> submitReview({
    required int userId,
    required String label,
    required String comment,
  }) async {
    // Dynamic mapping from label to rating
    int rating = 0;
    switch (label) {
      case 'Friendly':
        rating = 5;
        break;
      case 'Professional':
        rating = 4;
        break;
      case 'Smooth':
        rating = 3;
        break;
      case 'Average':
        rating = 2;
        break;
      case 'Unpleasant':
        rating = 1;
        break;
      default:
        rating = 5; // Default safe value
    }

    final request = UserReviewRequestModel(
      userId: userId,
      rating: rating,
      feedbackLabel: label,
      comment: comment,
    );

    _isLoading = true;
    notifyListeners();

    final response = await _profileService.submitUserReview(request);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      // Reload profile to show new review/rating if it's the same user
      if (_userProfile?.userDetails.id == userId) {
        getUserProfile(userId);
      }
    } else {
      _errorMessage = response.message;
    }
    return response;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>> updateProfile({
    String? fullName,
    String? location,
    String? email,
    String? mobile,
    String? bio,
    dynamic profileVisibility,
    File? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> requestData = {};
    if (fullName != null) requestData['full_name'] = fullName;
    if (location != null) requestData['location'] = location;
    if (email != null) requestData['email'] = email;
    if (mobile != null) requestData['mobile_number'] = mobile;
    if (bio != null) requestData['bio'] = bio;
    if (profileVisibility != null) {
      requestData['profile_visibility'] = profileVisibility;
    }

    final response =
        await _profileService.updateUserProfile(requestData, profileImage);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      // Reload profile if we have it loaded
      if (_userProfile != null) {
        getUserProfile(_userProfile!.userDetails.id);
      }
    } else {
      _errorMessage = response.message;
    }
    return response;
  }
}
