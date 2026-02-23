import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tool_bocs/features/trades/model/category_model.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/features/trades/model/post_request_model.dart';
import 'package:tool_bocs/features/trades/service/trade_service.dart';

class TradeController extends ChangeNotifier {
  final TradeService _tradeService = TradeService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Filter State ---
  List<String> _selectedCategories = [];
  String _selectedRating = 'All';
  String _selectedReturnType = 'All';
  String _selectedSort = 'Nearest First';
  String _selectedPostType = 'all';

  List<String> get selectedCategories => _selectedCategories;
  String get selectedRating => _selectedRating;
  String get selectedReturnType => _selectedReturnType;
  String get selectedSort => _selectedSort;
  String get selectedPostType => _selectedPostType;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tradeService.fetchCategories();

      if (response.success) {
        _categories = response.data ?? [];
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

  Future<bool> createPost(PostRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tradeService.createPost(request);

      if (response.success) {
        // Optimistic Update: Add to local list if valid data
        if (response.data != null) {
          try {
            final newPost = PostModel.fromJson(response.data);

            // Add to relevant lists
            if (newPost.postType == 'give') {
              _givePosts.insert(0, newPost);
            } else if (newPost.postType == 'take') {
              _takePosts.insert(0, newPost);
            }
            // Always add to home posts
            _homePosts.insert(0, newPost);
          } catch (e) {
            print("Error parsing created post for optimistic update: $e");
            // Fallback to fetch if parsing fails is not strictly necessary as the user will likely pull to refresh if they see nothing,
            // but the success return will trigger validation.
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Give Posts State ---
  List<PostModel> _givePosts = [];
  bool _isGiveLoading = false;
  int _givePage = 1;
  bool _giveHasNext = true;
  bool _isGiveLoadMoreRunning = false;

  List<PostModel> get givePosts => _applyFilters(_givePosts);
  bool get isGiveLoading => _isGiveLoading;
  bool get giveHasNext => _giveHasNext;
  bool get isGiveLoadMoreRunning => _isGiveLoadMoreRunning;

  // --- Take Posts State ---
  List<PostModel> _takePosts = [];
  bool _isTakeLoading = false;
  int _takePage = 1;
  bool _takeHasNext = true;
  bool _isTakeLoadMoreRunning = false;

  List<PostModel> get takePosts => _applyFilters(_takePosts);
  bool get isTakeLoading => _isTakeLoading;
  bool get takeHasNext => _takeHasNext;
  bool get isTakeLoadMoreRunning => _isTakeLoadMoreRunning;

  // --- Home Posts State (All) ---
  List<PostModel> _homePosts = [];
  bool _isHomeLoading = false;
  int _homePage = 1;
  bool _homeHasNext = true;
  bool _isHomeLoadMoreRunning = false;

  List<PostModel> get homePosts => _applyFilters(_homePosts);
  bool get isHomeLoading => _isHomeLoading;
  bool get homeHasNext => _homeHasNext;
  bool get isHomeLoadMoreRunning => _isHomeLoadMoreRunning;

  final int _limit = 10;
  Timer? _debounceTimer;

  double? _distanceKm; // Null means no distance filter applied
  double? _latitude;
  double? _longitude;

  double get distanceKm => _distanceKm ?? 10.0; // UI fallback
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isDistanceFilterActive => _distanceKm != null;

  void setDistance(double value,
      {bool triggerFetch = false, String fetchType = 'all'}) {
    if (_distanceKm == value) return;
    _distanceKm = value;
    notifyListeners();

    if (triggerFetch) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (fetchType == 'all') {
          fetchHomePosts(refresh: true);
        } else if (fetchType == 'give') {
          fetchGivePosts(refresh: true);
        } else if (fetchType == 'take') {
          fetchTakePosts(refresh: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void setLocation(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void updateFilters({
    List<String>? categories,
    String? rating,
    String? returnType,
    String? sort,
    String? postType,
  }) {
    if (categories != null) _selectedCategories = categories;
    if (rating != null) _selectedRating = rating;
    if (returnType != null) _selectedReturnType = returnType;
    if (sort != null) _selectedSort = sort;
    if (postType != null) _selectedPostType = postType;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategories = [];
    _selectedRating = 'All';
    _selectedReturnType = 'All';
    _selectedSort = 'Nearest First';
    _selectedPostType = 'all';
    _distanceKm = null;
    notifyListeners();
  }

  List<PostModel> _applyFilters(List<PostModel> posts) {
    List<PostModel> filtered = List.from(posts);

    // 1. Filter by Post Type (only for Home posts usually, but safe here)
    if (_selectedPostType != 'all') {
      filtered = filtered
          .where((p) => p.postType.toLowerCase() == _selectedPostType)
          .toList();
    }

    // 2. Filter by Category
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((p) => _selectedCategories.contains(p.itemCategory))
          .toList();
    }

    // 3. Filter by Rating
    if (_selectedRating != 'All') {
      double minRating =
          double.tryParse(_selectedRating.split(' ').first) ?? 0.0;
      filtered =
          filtered.where((p) => (p.userRating ?? 0.0) >= minRating).toList();
    }

    // 4. Filter by Return Type
    if (_selectedReturnType != 'All') {
      filtered = filtered
          .where((p) =>
              p.returnType.toLowerCase() == _selectedReturnType.toLowerCase())
          .toList();
    }

    // 5. Sorting
    if (_selectedSort == 'Nearest First') {
      filtered.sort(
          (a, b) => (a.distanceKm ?? 9999.0).compareTo(b.distanceKm ?? 9999.0));
    } else if (_selectedSort == 'Newest First') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Highest Rated') {
      filtered
          .sort((a, b) => (b.userRating ?? 0.0).compareTo(a.userRating ?? 0.0));
    }

    return filtered;
  }

  // --- Fetch Methods ---

  Future<void> fetchGivePosts({bool refresh = true}) async {
    await _fetchPostsGeneric(
      type: 'give',
      refresh: refresh,
      posts: _givePosts,
      page: _givePage,
      hasNext: _giveHasNext,
      isLoading: _isGiveLoading,
      isLoadMoreRunning: _isGiveLoadMoreRunning,
      latitude: _latitude,
      longitude: _longitude,
      distanceKm: _distanceKm,
      onStart: (loading, loadMore) {
        if (loading != null) _isGiveLoading = loading;
        if (loadMore != null) _isGiveLoadMoreRunning = loadMore;
        if (refresh) _errorMessage = null;
        notifyListeners();
      },
      onSuccess: (newPosts, next, page) {
        if (refresh) {
          _givePosts = newPosts;
        } else {
          _givePosts.addAll(newPosts);
        }
        _giveHasNext = next;
        _givePage = page;
        _isGiveLoading = false;
        _isGiveLoadMoreRunning = false;
        notifyListeners();
      },
      onError: (msg) {
        _errorMessage = msg;
        _isGiveLoading = false;
        _isGiveLoadMoreRunning = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchTakePosts({bool refresh = true}) async {
    await _fetchPostsGeneric(
      type: 'take',
      refresh: refresh,
      posts: _takePosts,
      page: _takePage,
      hasNext: _takeHasNext,
      isLoading: _isTakeLoading,
      isLoadMoreRunning: _isTakeLoadMoreRunning,
      latitude: _latitude,
      longitude: _longitude,
      distanceKm: _distanceKm,
      onStart: (loading, loadMore) {
        if (loading != null) _isTakeLoading = loading;
        if (loadMore != null) _isTakeLoadMoreRunning = loadMore;
        if (refresh) _errorMessage = null;
        notifyListeners();
      },
      onSuccess: (newPosts, next, page) {
        if (refresh) {
          _takePosts = newPosts;
        } else {
          _takePosts.addAll(newPosts);
        }
        _takeHasNext = next;
        _takePage = page;
        _isTakeLoading = false;
        _isTakeLoadMoreRunning = false;
        notifyListeners();
      },
      onError: (msg) {
        _errorMessage = msg;
        _isTakeLoading = false;
        _isTakeLoadMoreRunning = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchHomePosts({
    String type = 'all',
    bool refresh = true,
  }) async {
    await _fetchPostsGeneric(
      type: type,
      refresh: refresh,
      posts: _homePosts,
      page: _homePage,
      hasNext: _homeHasNext,
      isLoading: _isHomeLoading,
      isLoadMoreRunning: _isHomeLoadMoreRunning,
      latitude: _latitude,
      longitude: _longitude,
      distanceKm: _distanceKm,
      onStart: (loading, loadMore) {
        if (loading != null) _isHomeLoading = loading;
        if (loadMore != null) _isHomeLoadMoreRunning = loadMore;
        if (refresh) _errorMessage = null;
        notifyListeners();
      },
      onSuccess: (newPosts, next, page) {
        if (refresh) {
          _homePosts = newPosts;
        } else {
          _homePosts.addAll(newPosts);
        }
        _homeHasNext = next;
        _homePage = page;
        _isHomeLoading = false;
        _isHomeLoadMoreRunning = false;
        notifyListeners();
      },
      onError: (msg) {
        _errorMessage = msg;
        _isHomeLoading = false;
        _isHomeLoadMoreRunning = false;
        notifyListeners();
      },
    );
  }

  // Generic helper to reduce code duplication
  Future<void> _fetchPostsGeneric({
    required String type,
    required bool refresh,
    required List<PostModel> posts,
    required int page,
    required bool hasNext,
    required bool isLoading,
    required bool isLoadMoreRunning,
    double? latitude,
    double? longitude,
    double? distanceKm,
    required Function(bool? isLoading, bool? isLoadMoreRunning) onStart,
    required Function(List<PostModel> newPosts, bool hasNext, int page)
        onSuccess,
    required Function(String message) onError,
  }) async {
    int currentPage = page;

    if (refresh) {
      onStart(true, null);
      currentPage = 1;
    } else {
      if (!hasNext || isLoadMoreRunning) return;
      onStart(null, true);
    }

    try {
      // Root fix: Prioritize real coordinates, fallback to Pune ONLY if both are null
      final double finalLat = latitude ?? 18.5204;
      final double finalLng = longitude ?? 73.8567;

      final response = await _tradeService.getAllPosts(
        type: type,
        page: currentPage,
        limit: _limit,
        latitude: finalLat,
        longitude: finalLng,
        distanceKm: distanceKm,
      );

      if (response.success) {
        final List<PostModel> newPosts = response.data ?? [];
        bool next = true;
        int nextPage = currentPage;

        if (newPosts.length < _limit) {
          next = false;
        } else {
          nextPage++;
        }
        onSuccess(newPosts, next, nextPage);
      } else {
        onError(response.message ?? 'Failed to fetch posts');
      }
    } catch (e) {
      onError('An error occurred: $e');
    }
  }

  Future<void> loadMoreGivePosts() async =>
      await fetchGivePosts(refresh: false);
  Future<void> loadMoreTakePosts() async =>
      await fetchTakePosts(refresh: false);
  Future<void> loadMoreHomePosts() async =>
      await fetchHomePosts(refresh: false);

  PostModel? _selectedPost;
  PostModel? get selectedPost => _selectedPost;

  Future<void> fetchPostDetails(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedPost = null; // Clear previous selection
    notifyListeners();

    try {
      final response = await _tradeService.getPostById(id);

      if (response.success) {
        _selectedPost = response.data;
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
