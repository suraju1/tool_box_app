import 'package:flutter/material.dart';

class BottomNavBarController extends ChangeNotifier {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    // Always recreate PageController to ensure initialPage is 0
    // regardless of whether it has clients or not.
    _pageController.dispose();
    _pageController = PageController(initialPage: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
