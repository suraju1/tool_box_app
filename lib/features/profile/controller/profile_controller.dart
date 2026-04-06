import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/model/user_review_request_model.dart';
import '../model/blocked_user_model.dart';
import 'package:tool_bocs/features/profile/service/profile_service.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/core/services/firebase_notification_service.dart';
import 'package:tool_bocs/features/profile/model/saved_user_model.dart';
import 'package:tool_bocs/features/profile/model/faq_model.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/core/models/pagination_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfileModel? _ownProfile;
  UserProfileModel? _viewedProfile;
  List<BlockedUserModel> _blockedUsers = [];
  List<SavedUserModel> _savedUsers = [];
  List<FaqModel> _faqs = [];
  List<PostModel> _myPosts = [];
  int _totalMyPostsCount = 0;
  int _totalMyGivesCount = 0;
  int _totalMyTakesCount = 0;
  String _selectedMyPostsFilter = ' All ';
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  Pagination? _myPostsPagination;
  int _currentMyPostsPage = 1;

  UserProfileModel? get ownProfile => _ownProfile;
  UserProfileModel? get viewedProfile => _viewedProfile;
  List<BlockedUserModel> get blockedUsers => _blockedUsers;
  List<SavedUserModel> get savedUsers => _savedUsers;
  List<FaqModel> get faqs => _faqs;
  List<PostModel> get myPosts => _myPosts;
  int get totalMyPostsCount => _totalMyPostsCount;
  int get totalMyGivesCount => _totalMyGivesCount;
  int get totalMyTakesCount => _totalMyTakesCount;
  String get selectedMyPostsFilter => _selectedMyPostsFilter;
  UserProfileModel? get userProfile =>
      _viewedProfile ??
      _ownProfile; // Keep for backward compatibility if needed, but preferably use specific ones
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreMyPosts => _myPostsPagination?.hasNext ?? false;

  Future<void> getBlockedUsers() async {
    _isLoading = true;
    notifyListeners();

    final response = await _profileService.fetchBlockedUsers();

    if (response.success) {
      _blockedUsers = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getSavedUsers() async {
    _isLoading = true;
    notifyListeners();

    final response = await _profileService.fetchSavedUsers();

    if (response.success) {
      _savedUsers = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>> toggleSaveUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    // Determine current status
    bool currentlySaved = false;
    if (_viewedProfile?.userDetails.id == userId) {
      currentlySaved = _viewedProfile?.isSaved ?? false;
    } else {
      currentlySaved = _savedUsers.any((u) => u.id == userId);
    }

    final response = currentlySaved
        ? await _profileService.unsaveUser(userId)
        : await _profileService.saveUser(userId);

    if (response.success) {
      // Update local state for viewed profile
      if (_viewedProfile?.userDetails.id == userId) {
        _viewedProfile = UserProfileModel(
          userDetails: _viewedProfile!.userDetails,
          tradeStats: _viewedProfile!.tradeStats,
          reviews: _viewedProfile!.reviews,
          isSaved: !currentlySaved,
        );
      }
      // Refresh saved list if we are on the saved users screen or need it up to date
      await getSavedUsers();
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ApiResponse<dynamic>> blockUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _profileService.blockUser(userId);

    if (response.success) {
      // Refresh blocked list
      await getBlockedUsers();
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ApiResponse<dynamic>> unblockUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _profileService.unblockUser(userId);

    if (response.success) {
      // Refresh blocked list
      await getBlockedUsers();
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<bool> getUserProfile(int? userId, {bool isOwnProfile = true}) async {
    _isLoading = true;
    _errorMessage = null;
    if (!isOwnProfile) {
      _viewedProfile = null; // Clear previous viewed profile
    }
    notifyListeners();

    final response = isOwnProfile
        ? await _profileService.fetchOwnProfile()
        : await _profileService.fetchOtherProfile(userId ?? 0);

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
    int? showTradeHistory,
    String? gender,
    String? dateOfBirth,
    double? latitude,
    double? longitude,
    bool? termsAccepted,
    File? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> requestData = {
      'user_id': _ownProfile?.userDetails.id,
      'full_name': fullName ?? _ownProfile?.userDetails.fullName,
      'email': email ?? _ownProfile?.userDetails.email,
      'phone_number': mobile ?? _ownProfile?.userDetails.phoneNumber,
      'location': location ?? _ownProfile?.userDetails.location,
      'latitude': latitude ?? _ownProfile?.userDetails.latitude,
      'longitude': longitude ?? _ownProfile?.userDetails.longitude,
      'date_of_birth': dateOfBirth ?? _ownProfile?.userDetails.dateOfBirth,
      'gender': gender ?? _ownProfile?.userDetails.gender,
      'bio': bio ?? _ownProfile?.userDetails.bio,
      'profile_visibility': profileVisibility ?? _ownProfile?.userDetails.profileVisibility,
      'show_trade_history': showTradeHistory ?? _ownProfile?.userDetails.showTradeHistory,
      'terms_accepted': termsAccepted ?? _ownProfile?.userDetails.termsAccepted,
    };

    // 1. Update Profile Image if provided
    if (profileImage != null) {
      final imageResponse = await _profileService.updateProfileImage(profileImage);
      if (!imageResponse.success) {
        _isLoading = false;
        _errorMessage = imageResponse.message;
        notifyListeners();
        return imageResponse;
      }
    }

    // 2. Update General Profile Data
    final response = await _profileService.updateGeneralProfile(requestData);

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
  static void navigateToUserProfile(BuildContext context, int userId) {
    final authController = context.read<AuthController>();

    // If it's own profile, just go to profile tab
    if (authController.currentUser?.id == userId) {
      context.read<BottomNavBarController>().setIndex(4);
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId.toString()),
      ),
    );
  }
  Future<void> getFaqs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.fetchFaqs();

    if (response.success) {
      _faqs = response.data ?? [];
      // Sort by sequence number
      _faqs.sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>> submitFeedback(String message) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.submitFeedback(message);

    if (!response.success) {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<void> getMyPosts(
      {String postType = 'all',
      String label = ' All ',
      bool isRefresh = true}) async {
    if (isRefresh) {
      _myPosts = [];
      _currentMyPostsPage = 1;
      _isLoading = true;
    } else {
      _isPaginationLoading = true;
    }

    _errorMessage = null;
    _selectedMyPostsFilter = label;
    notifyListeners();

    final response = await _profileService.fetchMyPosts(
      postType: postType,
      page: _currentMyPostsPage,
      limit: 10,
    );

    if (response.success && response.data != null) {
      final newPosts = response.data!.data;
      if (isRefresh) {
        _myPosts = newPosts;
      } else {
        _myPosts.addAll(newPosts);
      }

      _myPostsPagination = response.data!.pagination;
      if (_myPostsPagination != null) {
        _currentMyPostsPage = _myPostsPagination!.page + 1;
      }

      // Update counts based on pagination total if available
      final totalFromApi = _myPostsPagination?.total ?? _myPosts.length;
      if (postType == 'all') {
        _totalMyPostsCount = totalFromApi;
        // fallback calculation for gives/takes if we have the full list
        if (_myPostsPagination?.totalPages == 1) {
           _totalMyGivesCount = _myPosts.where((p) => p.postType.toLowerCase() == 'give').length;
           _totalMyTakesCount = _myPosts.where((p) => p.postType.toLowerCase() == 'take').length;
        }
      } else if (postType == 'give') {
        _totalMyGivesCount = totalFromApi;
      } else if (postType == 'take') {
        _totalMyTakesCount = totalFromApi;
      }
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    _isPaginationLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreMyPosts() async {
    if (!hasMoreMyPosts || _isPaginationLoading) return;

    String postType = 'all';
    if (_selectedMyPostsFilter.trim() == 'Gives') postType = 'give';
    if (_selectedMyPostsFilter.trim() == 'Takes') postType = 'take';

    await getMyPosts(
        postType: postType, label: _selectedMyPostsFilter, isRefresh: false);
  }
}
