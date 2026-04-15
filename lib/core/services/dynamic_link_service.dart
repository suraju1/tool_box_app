import 'dart:collection';
import 'package:flutter/material.dart';

/// Service for generating and parsing deep links for the app.
///
/// Uses a custom URL scheme (`toolucs://`) and HTTPS-based
/// web fallback links. Generated links point to Firebase Hosting
/// which handles redirecting to the app or store as appropriate.
///
/// Link format: https://tool-bocs-prod-v3.web.app/post/{id}
/// Custom scheme: toolucs://post/{id}
class DynamicLinkService {
  DynamicLinkService._();
  static final DynamicLinkService _instance = DynamicLinkService._();
  factory DynamicLinkService() => _instance;

  /// Base URL for web-based deep links.
  /// Hosted on Firebase Hosting — serves a smart redirect page that:
  /// 1. Tries to open the app via custom scheme
  /// 2. Falls back to Play Store / App Store if app not installed
  /// 3. Renders OG meta tags for link previews
  static const String _webLinkBase = 'https://tool-bocs-v2-prod.web.app';

  /// Custom URL scheme for the app.
  static const String _customScheme = 'toolucs';

  /// In-memory cache for generated links to avoid redundant computation.
  final LinkedHashMap<int, String> _linkCache = LinkedHashMap<int, String>();
  static const int _maxCacheSize = 100;

  /// Generate a shareable link for a given post ID.
  ///
  /// Returns a web URL that can be shared and will deep link
  /// into the app when clicked. The link is cached for faster
  /// subsequent access.
  String generateLink({required int postId}) {
    // Return cached link if available
    if (_linkCache.containsKey(postId)) {
      return _linkCache[postId]!;
    }

    final String link = '$_webLinkBase/post/$postId';

    // Cache with LRU eviction
    if (_linkCache.length >= _maxCacheSize) {
      _linkCache.remove(_linkCache.keys.first);
    }
    _linkCache[postId] = link;

    return link;
  }

  /// Generate a custom scheme link (for app-to-app deep linking).
  String generateCustomSchemeLink({required int postId}) {
    return '$_customScheme://post/$postId';
  }

  /// Parse a deep link URL and extract the post ID if valid.
  ///
  /// Supports both web URLs and custom scheme URLs:
  /// - `https://tool-bocs-prod-v3.web.app/post/123`
  /// - `toolucs://post/123`
  ///
  /// Returns null if the URL doesn't match the expected format.
  static int? parsePostIdFromLink(String url) {
    try {
      final Uri uri = Uri.parse(url);

      // Handle custom scheme: toolucs://post/{id}
      if (uri.scheme == _customScheme) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 && segments[0] == 'post') {
          return int.tryParse(segments[1]);
        }
        // toolucs://post/{id} might parse as host='post', path='/{id}'
        if (uri.host == 'post' && uri.pathSegments.isNotEmpty) {
          return int.tryParse(uri.pathSegments.first);
        }
      }

      // Handle web URL: .../app/post/{id}
      if (uri.scheme == 'https' || uri.scheme == 'http') {
        final segments = uri.pathSegments;
        for (int i = 0; i < segments.length - 1; i++) {
          if (segments[i] == 'post') {
            return int.tryParse(segments[i + 1]);
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('[DynamicLinkService] Error parsing link: $e');
      return null;
    }
  }

  /// Clear the link cache.
  void clearCache() {
    _linkCache.clear();
  }
}
