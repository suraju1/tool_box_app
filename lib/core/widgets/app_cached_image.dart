import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final String? userName;
  final double? height;
  final double? width;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final BoxFit fit;
  final double radius;
  final Widget? errorWidget;
  final Color? placeholderBgColor;
  final Color? placeholderTextColor;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.userName,
    this.height,
    this.width,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.fit = BoxFit.cover,
    this.radius = 12,
    this.errorWidget,
    this.placeholderBgColor,
    this.placeholderTextColor,
  });

  /// Helper to get the correct absolute URL from a path
  static String getFormattedUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Remove leading slash if present to avoid double slashes
    final path = url.startsWith('/') ? url.substring(1) : url;
    return '${ApiConstants.baseUrl2}$path';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    final absoluteUrl = getFormattedUrl(imageUrl);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate memory cache dimensions if not provided but display dimensions are available
    // We multiply by pixelRatio to ensure sharpness on high-density screens
    // Added isFinite check to prevent "Infinity or NaN toInt" crash
    final int? calculatedMemCacheWidth = memCacheWidth ??
        (width != null && width! > 0 && width!.isFinite
            ? (width! * pixelRatio).round()
            : null);
    final int? calculatedMemCacheHeight = memCacheHeight ??
        (height != null && height! > 0 && height!.isFinite
            ? (height! * pixelRatio).round()
            : null);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: absoluteUrl,
        height: height,
        width: width,
        fit: fit,
        memCacheWidth: calculatedMemCacheWidth,
        memCacheHeight: calculatedMemCacheHeight,
        maxWidthDiskCache: maxWidthDiskCache ?? 1200,
        maxHeightDiskCache: maxHeightDiskCache ?? 1200,
        fadeOutDuration: const Duration(milliseconds: 200),
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => ShimmerBox(
          height: height ?? double.infinity,
          width: width ?? double.infinity,
          radius: radius,
        ),
        errorWidget: (context, url, error) => _buildErrorWidget(context),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (userName != null && userName!.isNotEmpty) {
      return _buildLetterPlaceholder(context);
    }
    return errorWidget ??
        Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
  }

  Widget _buildLetterPlaceholder(BuildContext context) {
    final firstLetter = userName!.trim().isNotEmpty
        ? userName!.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: placeholderBgColor ??
            Theme.of(context).primaryColor.withOpacity(0.1),
        shape: radius >= 40 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius >= 40 ? null : BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: TextStyle(
          color: placeholderTextColor ?? Theme.of(context).primaryColor,
          fontSize: (height ?? 40) * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
