import 'package:tool_bocs/features/trades/model/post_model.dart';

/// Formats post/product content into a shareable text message.
///
/// Produces a visually appealing, emoji-rich message that includes
/// key product details and a link for recipients.
class ShareContentFormatter {
  ShareContentFormatter._();

  /// Format a [PostModel] into a shareable text string.
  ///
  /// Example output:
  /// ```
  /// 🛍️ iPhone 14 Pro Max
  /// 📦 Condition: Like New
  /// 🏷️ Category: Electronics
  /// 🔄 Trade Type: Give
  /// 💰 Return: Price (₹40000 - ₹50000)
  ///
  /// 📝 Barely used iPhone in excellent condition...
  ///
  /// 👉 Check it out on TOOLUCS:
  /// https://toolucs.page.link/post/123
  /// ```
  static String formatPostContent({
    required PostModel post,
    required String link,
  }) {
    final StringBuffer buffer = StringBuffer();

    // Post type indicator
    final bool isTaking = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';
    final String typeEmoji = isTaking ? '📥' : '📤';
    final String typeLabel = isTaking ? 'Looking for' : 'Available';

    // Title line
    buffer.writeln('$typeEmoji $typeLabel: ${post.itemName}');
    buffer.writeln();

    // Core details
    buffer.writeln('📦 Condition: ${post.itemCondition}');
    buffer.writeln('🏷️ Category: ${post.itemCategory}');
    buffer.writeln('🔄 Trade Type: ${post.tradeType}');

    // Price or return item info
    if (post.returnType == 'Price' &&
        post.priceMin != null &&
        post.priceMax != null) {
      buffer.writeln(
        '💰 Price Range: ₹${post.priceMin!.toStringAsFixed(0)} - ₹${post.priceMax!.toStringAsFixed(0)}',
      );
      if (post.isNegotiable) {
        buffer.writeln('🤝 Negotiable');
      }
    } else if (post.returnType == 'Item') {
      buffer.writeln('🔁 Return Type: Item Exchange');
      if (post.returnItemName != null && post.returnItemName!.isNotEmpty) {
        buffer.writeln('↩️ Wants: ${post.returnItemName}');
      }
    } else {
      buffer.writeln('💰 Return Type: ${post.returnType}');
    }

    // User rating if available
    if (post.userRating != null) {
      buffer.writeln('⭐ Rating: ${post.userRating!.toStringAsFixed(1)}');
    }

    // Description (truncated for share message)
    if (post.itemNote.isNotEmpty) {
      buffer.writeln();
      final String description = post.itemNote.length > 150
          ? '${post.itemNote.substring(0, 150)}...'
          : post.itemNote;
      buffer.writeln('📝 $description');
    }

    // Location
    if (post.pickupArea.isNotEmpty) {
      buffer.writeln('📍 ${post.pickupArea}');
    }

    // App link
    buffer.writeln();
    buffer.writeln('👉 Check it out on TOOLUCS:');
    buffer.writeln(link);

    return buffer.toString().trimRight();
  }
}
