import 'package:flutter/material.dart';
import 'package:tool_bocs/features/trades/model/wallet_history_model.dart';
import 'package:tool_bocs/features/trades/service/wallet_service.dart';

class WalletController extends ChangeNotifier {
  final WalletService _walletService = WalletService();

  List<WalletHistory> _walletHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WalletHistory> get walletHistory => _walletHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWalletHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _walletService.getWalletHistory();

      if (response.success) {
        _walletHistory = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
