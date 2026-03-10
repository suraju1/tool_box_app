class StringUtil {
  /// Removes all characters that are outside the Basic Multilingual Plane (BMP).
  /// This includes most emojis and other 4-byte UTF-8 characters which can cause
  /// "Incorrect string value" errors on servers with standard UTF-8 (non-utf8mb4)
  /// database configurations.
  static String sanitizeForSql(String? input) {
    if (input == null || input.isEmpty) return '';

    // Regular expression to match characters outside the BMP (U+0000 to U+FFFF)
    // These are the characters that require 4 bytes in UTF-8.
    final RegExp nonBmpRegex = RegExp(r'[^\u0000-\uFFFF]', unicode: true);

    return input.replaceAll(nonBmpRegex, '').trim();
  }

  /// Alias for sanitizeForSql for better readability in UI context.
  static String removeEmojis(String? input) => sanitizeForSql(input);
}
