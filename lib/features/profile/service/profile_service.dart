import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/model/user_review_request_model.dart';
import '../model/blocked_user_model.dart';

import 'package:tool_bocs/features/profile/model/saved_user_model.dart';
import 'package:tool_bocs/features/profile/model/faq_model.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<UserProfileModel>> fetchOwnProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.getUserProfile);
      _logProfileApiResponse('OWN PROFILE', response.data);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Profile fetched successfully',
            data: UserProfileModel.fromJson(data['data']),
          );
        } else {
          return ApiResponse(
            success: false,
            message:
                data['error'] ?? data['message'] ?? 'Failed to fetch profile',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<UserProfileModel>> fetchOtherProfile(int userId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getOtherProfile.replaceFirst('{{id}}', userId.toString()),
      );
      _logProfileApiResponse('OTHER PROFILE $userId', response.data);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Profile fetched successfully',
            data: UserProfileModel.fromJson(data['data']),
          );
        } else {
          return ApiResponse(
            success: false,
            message:
                data['error'] ?? data['message'] ?? 'Failed to fetch profile',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }


  Future<ApiResponse<dynamic>> submitUserReview(
      UserReviewRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.submitUserReview,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ??
              data['msg'] ??
              data['error'] ??
              'Review submitted successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> updateGeneralProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.completeProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        return ApiResponse(
          success: resData['success'] ?? false,
          message: resData['message'] ?? 'Profile updated successfully',
          data: resData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> updateProfileImage(dynamic imageFile) async {
    try {
      final formData = FormData();
      final String path = imageFile.path;
      final fileName = path.split(RegExp(r'[\\/]')).last;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        formData.files.add(MapEntry(
            'profile_image',
            MultipartFile.fromBytes(bytes, filename: fileName)));
      } else {
        formData.files.add(MapEntry(
            'profile_image',
            await MultipartFile.fromFile(path, filename: fileName)));
      }

      final response = await _apiClient.post(
        ApiConstants.updateProfile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data; boundary=${formData.boundary}',
        ),
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        return ApiResponse(
          success: resData['success'] ?? false,
          message: resData['message'] ?? 'Profile image updated successfully',
          data: resData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> blockUser(int userId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.blockUser.replaceFirst('{{id}}', userId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'User blocked successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> unblockUser(int userId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.unblockUser.replaceFirst('{{id}}', userId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'User unblocked successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<BlockedUserModel>>> fetchBlockedUsers() async {
    try {
      final response = await _apiClient.get(ApiConstants.listBlockedUser);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> blockedData = data['data'];
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Blocked users fetched successfully',
            data: blockedData.map((e) => BlockedUserModel.fromJson(e)).toList(),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch blocked users',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> saveUser(int userId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.userSave.replaceFirst('{{id}}', userId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'User saved successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> unsaveUser(int userId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.unsaveUser.replaceFirst('{{id}}', userId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'User unsaved successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<SavedUserModel>>> fetchSavedUsers() async {
    try {
      final response = await _apiClient.get(ApiConstants.listSaveUser);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> savedData = data['data'];
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Saved users fetched successfully',
            data: savedData.map((e) => SavedUserModel.fromJson(e)).toList(),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch saved users',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  Future<ApiResponse<List<FaqModel>>> fetchFaqs() async {
    try {
      final response = await _apiClient.get(ApiConstants.faqs);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> faqData = data['data'];
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'FAQs fetched successfully',
            data: faqData.map((e) => FaqModel.fromJson(e)).toList(),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch FAQs',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<dynamic>> submitFeedback(String message) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.feedback,
        data: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'Feedback submitted successfully',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<PostResponseModel>> fetchMyPosts(
      {String postType = 'all', int page = 1, int limit = 10}) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (postType != 'all') {
        queryParameters['type'] = postType;
      }
      queryParameters['page'] = page;
      queryParameters['limit'] = limit;

      final response = await _apiClient.get(
        ApiConstants.getMyPosts,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'My posts fetched successfully',
            data: PostResponseModel.fromJson(data),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch my posts',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  void _logProfileApiResponse(String title, dynamic data) {
    if (!kDebugMode) return;

    String output;
    try {
      output = const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      output = data.toString();
    }

    const chunkSize = 800;
    debugPrint('================ $title API RESPONSE START ================');
    for (var i = 0; i < output.length; i += chunkSize) {
      final end =
          i + chunkSize < output.length ? i + chunkSize : output.length;
      debugPrint(output.substring(i, end));
    }
    debugPrint('================ $title API RESPONSE END ==================');
  }
}
