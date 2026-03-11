import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/profile/model/user_review_request_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<UserProfileModel>> fetchUserProfile(int userId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getUserProfile.replaceAll('{{id}}', userId.toString()),
      );

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

  Future<ApiResponse<dynamic>> updateUserProfile(
      Map<String, dynamic> data, File? imageFile) async {
    try {
      final formData = FormData.fromMap(data);

      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(MapEntry('profile_image',
            await MultipartFile.fromFile(imageFile.path, filename: fileName)));
      }

      final response = await _apiClient.post(
        ApiConstants.updateProfile,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ApiResponse(
          success: data['success'] ?? false,
          message: data['message'] ?? 'Profile updated successfully',
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
}
