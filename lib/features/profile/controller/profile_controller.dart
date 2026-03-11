import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/model/user_review_request_model.dart';
import 'package:tool_bocs/features/profile/service/profile_service.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/core/services/firebase_notification_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfileModel? _ownProfile;
  UserProfileModel? _viewedProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get ownProfile => _ownProfile;
  UserProfileModel? get viewedProfile => _viewedProfile;
  UserProfileModel? get userProfile =>
      _viewedProfile ??
      _ownProfile; // Keep for backward compatibility if needed, but preferably use specific ones
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> getUserProfile(int userId, {bool isOwnProfile = true}) async {
    _isLoading = true;
    _errorMessage = null;
    if (!isOwnProfile) {
      _viewedProfile = null; // Clear previous viewed profile
    }
    notifyListeners();

    final response = await _profileService.fetchUserProfile(userId);

    bool success = false;
    if (response.success) {
      if (isOwnProfile) {
        _ownProfile = response.data;
      } else {
        _viewedProfile = response.data;
      }
      success = true;
    } else {
      _errorMessage = response.message;
      success = false;
    }

    _isLoading = false;
    notifyListeners();
    return success;
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
      // Reload profile to show new review/rating if it's being viewed or is own
      if (_viewedProfile?.userDetails.id == userId) {
        getUserProfile(userId, isOwnProfile: false);
      } else if (_ownProfile?.userDetails.id == userId) {
        getUserProfile(userId, isOwnProfile: true);
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
    if (mobile != null) requestData['phone_number'] = mobile;
    if (bio != null) requestData['bio'] = bio;
    if (profileVisibility != null) {
      requestData['profile_visibility'] = profileVisibility;
    }

    final response =
        await _profileService.updateUserProfile(requestData, profileImage);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      // Reload own profile after update
      if (_ownProfile != null) {
        final reloadSuccess = await getUserProfile(_ownProfile!.userDetails.id,
            isOwnProfile: true);
        // Sync both name and profile image to Firestore so chat screens stay up to date
        if (reloadSuccess) {
          FirebaseNotificationService.syncProfileData(
            fullName: _ownProfile?.userDetails.fullName,
            profileImageUrl: _ownProfile?.userDetails.image,
          );
        }
      }
    } else {
      _errorMessage = response.message;
    }
    return response;
  }

  /// Global helper to navigate to user profile with privacy guard
  static Future<void> navigateToUserProfile(
      BuildContext context, int userId) async {
    final controller = context.read<ProfileController>();
    final authController = context.read<AuthController>();

    // If it's own profile, just go to profile tab
    if (authController.currentUser?.id == userId) {
      context.read<BottomNavBarController>().setIndex(4);
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    // Show loading? or just fetch.
    // Let's use a subtle check.
    final success =
        await controller.getUserProfile(userId, isOwnProfile: false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: userId.toString()),
        ),
      );
    } else if (controller.errorMessage == "This profile is private") {
      ToastService.showErrorToast(context, controller.errorMessage!);
    } else {
      ToastService.showErrorToast(
          context, controller.errorMessage ?? "Failed to load profile");
    }
  }
}
