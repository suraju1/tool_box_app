import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/features/trades/model/category_model.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/features/trades/model/post_request_model.dart';
import 'package:tool_bocs/core/api/api_response.dart';

class TradeService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<CategoryModel>>> fetchCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.getCategoryTypes);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> categoriesJson = data['data'];
          final categories =
              categoriesJson.map((e) => CategoryModel.fromJson(e)).toList();
          return ApiResponse(
              success: true, message: 'Categories fetched', data: categories);
        } else {
          return ApiResponse(
              success: false,
              message: data['message'] ?? 'Failed to fetch categories');
        }
      } else {
        return ApiResponse(
            success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<dynamic>> createPost(PostRequestModel request) async {
    try {
      final formData = await request.toFormData();
      final response = await _apiClient.post(
        ApiConstants.createGiveTakePost,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
              success: true,
              message: data['message'] ?? 'Post created successfully',
              data: data['data']);
        } else {
          return ApiResponse(
              success: false,
              message: data['message'] ?? 'Failed to create post');
        }
      } else {
        return ApiResponse(
            success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<List<PostModel>>> getAllPosts({
    String type = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getAllGiveTakePost,
        data: {
          "type": type,
          "page": page,
          "limit": limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          final posts = list.map((e) => PostModel.fromJson(e)).toList();
          return ApiResponse(
              success: true,
              message: 'Posts fetched successfully',
              data: posts);
        } else {
          return ApiResponse(
              success: false,
              message: data['message'] ?? 'Failed to fetch posts');
        }
      } else {
        return ApiResponse(
            success: false, message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }

  Future<ApiResponse<PostModel>> getPostById(int id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getGiveTakePostById
            .replaceAll('{{postid}}', id.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Post fetched successfully',
            data: PostModel.fromJson(data['data']),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch post details',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'An error occurred: $e');
    }
  }
}
