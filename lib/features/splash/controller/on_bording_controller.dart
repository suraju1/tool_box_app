import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_client.dart';
import 'package:tool_bocs/features/splash/model/on_bording_model.dart';

class OnBoardingController extends ChangeNotifier {
  int currentPage = 0;
  List<OnBoardingModel> onBoardingList = [];
  bool isLoading = false;
  String? errorMessage;

  final ApiClient _apiClient = ApiClient();

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  Future<void> fetchOnboardingData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('onboarding');
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        onBoardingList =
            data.map((json) => OnBoardingModel.fromJson(json)).toList();

        // Sort by screen_order if available
        onBoardingList
            .sort((a, b) => (a.screenOrder ?? 0).compareTo(b.screenOrder ?? 0));

        // If sorting isn't needed or order is already correct, you can skip sorting
      } else {
        errorMessage =
            response.data['message'] ?? 'Failed to fetch onboarding data';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
