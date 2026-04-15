import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:tool_bocs/core/services/dynamic_link_service.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/routes/navigator_key.dart';

/// Handles incoming deep links and navigates to the appropriate screens.
///
/// Listens for both cold-start (app launched via deep link) and
/// warm-start (deep link received while app is running) scenarios
/// using the `app_links` package.
///
/// Usage:
/// ```dart
/// // In main.dart or splash screen, after Firebase init:
/// await DeepLinkHandler().init();
/// ```
class DeepLinkHandler {
  DeepLinkHandler._();
  static final DeepLinkHandler _instance = DeepLinkHandler._();
  factory DeepLinkHandler() => _instance;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isInitialized = false;

  /// Initialize deep link handling.
  ///
  /// Checks for an initial link (cold start) and sets up a stream
  /// listener for subsequent links (warm start).
  /// Safe to call multiple times — will only initialize once.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('[DeepLinkHandler] Initializing...');

    // Check for initial deep link (cold start)
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('[DeepLinkHandler] Initial link: $initialLink');
        // Delay to allow the app to fully initialize before navigating
        Future.delayed(const Duration(seconds: 3), () {
          _handleDeepLink(initialLink);
        });
      }
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error getting initial link: $e');
    }

    // Listen for incoming links (warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('[DeepLinkHandler] Received link: $uri');
        _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('[DeepLinkHandler] Link stream error: $error');
      },
    );
  }

  /// Process a deep link URI and navigate accordingly.
  void _handleDeepLink(Uri uri) {
    final String url = uri.toString();
    debugPrint('[DeepLinkHandler] Handling deep link: $url');

    // Try to parse a post ID from the link
    final int? postId = DynamicLinkService.parsePostIdFromLink(url);

    if (postId != null) {
      debugPrint('[DeepLinkHandler] Navigating to post: $postId');
      _navigateToProductDetails(postId);
      return;
    }

    debugPrint('[DeepLinkHandler] No matching route for link: $url');
  }

  /// Navigate to the product details screen for the given post ID.
  ///
  /// Uses the global navigator key to push the route without
  /// disrupting the existing navigation stack.
  void _navigateToProductDetails(int postId) {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint(
          '[DeepLinkHandler] Navigator not available, queueing navigation');
      // Retry after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToProductDetails(postId);
      });
      return;
    }

    navigator.pushNamed(
      AppRoutes.productDetails,
      arguments: postId,
    );
  }

  /// Clean up resources. Call this when the app is being disposed.
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
    debugPrint('[DeepLinkHandler] Disposed');
  }
}
