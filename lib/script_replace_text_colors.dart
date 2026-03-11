import 'dart:io';

void main() async {
  final dir = Directory('d:/Nikhil Axolotls/Tool Bocs App/tool_bocs/lib');
  int filesModified = 0;

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.contains('colors.dart') &&
        !entity.path.contains('app_theme.dart')) {
      String content = await entity.readAsString();
      bool modified = false;

      // We need to replace hardcoded Colors.white or whiteColor for text inside Buttons
      // But a safer generic approach to support Dark mode properly:
      // We will replace whiteColor/Colors.white with context.colorScheme.onPrimary when it seems related to buttons or primary color backgrounds.
      // Easiest is to replace 'color: Colors.white' with 'color: context.onPrimaryColor' selectively or globally for TextStyles.
      // Since `context.textColor` is already used for normal text, we just need to fix button text.
      // Often button text is written as `color: Colors.white`.

      if (content.contains('color: Colors.white,')) {
        content = content.replaceAll(
            'color: Colors.white,', 'color: context.onPrimaryColor,');
        modified = true;
      }
      if (content.contains('color: Colors.white)')) {
        content = content.replaceAll(
            'color: Colors.white)', 'color: context.onPrimaryColor)');
        modified = true;
      }
      if (content.contains('color: whiteColor,')) {
        content = content.replaceAll(
            'color: whiteColor,', 'color: context.onPrimaryColor,');
        modified = true;
      }
      if (content.contains('color: whiteColor)')) {
        content = content.replaceAll(
            'color: whiteColor)', 'color: context.onPrimaryColor)');
        modified = true;
      }

      if (modified) {
        await entity.writeAsString(content);
        filesModified++;
        print('Updated text colors in ${entity.path}');
      }
    }
  }
  print('Replaced white text colors in $filesModified files.');
}
