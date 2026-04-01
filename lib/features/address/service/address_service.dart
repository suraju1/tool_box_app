import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/address/model/address_model.dart';

class AddressService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<AddressModel>> saveAddress(AddressModel address) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.saveAddress,
        data: address.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Address saved successfully',
            data: AddressModel.fromJson(data['data']),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to save address',
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

  Future<ApiResponse<List<AddressModel>>> fetchMyAddresses() async {
    try {
      final response = await _apiClient.get(ApiConstants.myAddresses);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> list = data['data'];
          final addresses = list.map((e) => AddressModel.fromJson(e)).toList();
          return ApiResponse(
            success: true,
            message: 'Addresses fetched successfully',
            data: addresses,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch addresses',
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

  Future<ApiResponse<AddressModel>> updateAddress(int id, AddressModel address) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.editAddress.replaceAll('{{id}}', id.toString()),
        data: address.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Address updated successfully',
            data: data['data'] != null ? AddressModel.fromJson(data['data']) : null,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to update address',
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

  Future<ApiResponse<dynamic>> deleteAddress(int id) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.deleteAddress.replaceAll('{{id}}', id.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Address deleted successfully',
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to delete address',
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

  Future<ApiResponse<AddressModel>> getAddressDetails(int id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getAddress.replaceAll('{{id}}', id.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse(
            success: true,
            message: data['message'] ?? 'Address details fetched successfully',
            data: AddressModel.fromJson(data['data']),
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch address details',
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
}
