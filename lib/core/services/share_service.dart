import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tool_bocs/core/services/dynamic_link_service.dart';
import 'package:tool_bocs/core/services/share_content_formatter.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';

/// Core service for sharing post/product content across apps.
///
/// Supports text-only sharing and optional image sharing with
/// product images downloaded temporarily for the share sheet.
class ShareService {
  ShareService._();
  static final ShareService _instance = ShareService._();
  factory ShareService() => _instance;

  final DynamicLinkService _linkService = DynamicLinkService();

  /// Share a post with formatted text content.
  ///
  /// Generates a dynamic link, formats the share message
  /// using [ShareContentFormatter], and opens the system share sheet.
  /// Optionally includes the first product image if [includeImage] is true.
  Future<void> sharePost(
    BuildContext context, {
    required PostModel post,
    bool includeImage = false,
  }) async {
    try {
      // Generate dynamic link for this post
      final String shareLink = _linkService.generateLink(postId: post.id);

      // Format the share text content
      final String shareText = ShareContentFormatter.formatPostContent(
        post: post,
        link: shareLink,
      );

      if (includeImage && post.itemImages.isNotEmpty) {
        await _shareWithImage(
          context,
          text: shareText,
          imageUrl: post.itemImages.first,
        );
      } else {
        await _shareTextOnly(text: shareText);
      }

      debugPrint('[ShareService] Post ${post.id} shared successfully');
    } catch (e) {
      debugPrint('[ShareService] Error sharing post: $e');
      // Fallback to text-only share if image sharing fails
      try {
        final shareLink = _linkService.generateLink(postId: post.id);
        final shareText = ShareContentFormatter.formatPostContent(
          post: post,
          link: shareLink,
        );
        await _shareTextOnly(text: shareText);
      } catch (fallbackError) {
        debugPrint('[ShareService] Fallback share also failed: $fallbackError');
        rethrow;
      }
    }
  }

  /// Share text content only via the system share sheet.
  Future<void> _shareTextOnly({required String text}) async {
    await SharePlus.instance.share(
      ShareParams(text: text),
    );
  }

  /// Share content with an image downloaded from [imageUrl].
  ///
  /// Downloads the image to a temporary file, shares it via [XFile],
  /// and cleans up the temp file afterwards to prevent memory leaks.
  Future<void> _shareWithImage(
    BuildContext context, {
    required String text,
    required String imageUrl,
  }) async {
    File? tempFile;
    try {
      // Ensure absolute URL
      final String absoluteUrl = _ensureAbsoluteUrl(imageUrl);

      // Download the image to temp directory
      final http.Response response = await http
          .get(Uri.parse(absoluteUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'share_${DateTime.now().millisecondsSinceEpoch}.jpg';
        tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(response.bodyBytes);

        await SharePlus.instance.share(
          ShareParams(
            text: text,
            files: [XFile(tempFile.path)],
          ),
        );
      } else {
        // If image download fails, share text only
        debugPrint(
            '[ShareService] Image download failed with status: ${response.statusCode}');
        await _shareTextOnly(text: text);
      }
    } catch (e) {
      debugPrint('[ShareService] Image sharing failed: $e');
      // Fallback to text-only
      await _shareTextOnly(text: text);
    } finally {
      // Clean up temp file after a delay (allow share sheet to finish using it)
      if (tempFile != null && await tempFile.exists()) {
        final fileToClean = tempFile;
        Future.delayed(const Duration(seconds: 30), () async {
          try {
            if (await fileToClean.exists()) {
              await fileToClean.delete();
            }
          } catch (_) {}
        });
      }
    }
  }

  /// Ensure the image URL is absolute by prepending the base URL if needed.
  String _ensureAbsoluteUrl(String url) {
    if (url.startsWith('http')) return url;
    // Use the same logic as AppCachedImage
    final path = url.startsWith('/') ? url.substring(1) : url;
    return 'https://updatedtoolbocs.onrender.com/$path';
  }
}
