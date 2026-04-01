import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/trades/model/wallet_history_model.dart';

class WalletService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<WalletHistory>>> getWalletHistory() async {
    try {
      final response = await _apiClient.get(ApiConstants.walletTransactions);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final WalletHistoryResponse walletHistoryResponse =
              WalletHistoryResponse.fromJson(data);
          return ApiResponse(
            success: true,
            message: 'Wallet history fetched successfully',
            data: walletHistoryResponse.walletHistory,
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to fetch wallet history',
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
