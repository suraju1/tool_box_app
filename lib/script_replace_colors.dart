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

      // Simple text replacements
      if (content.contains('defoultColor')) {
        content = content.replaceAll('defoultColor', 'context.primaryColor');
        modified = true;
      }
      if (content.contains('appColor')) {
        content = content.replaceAll('appColor', 'context.primaryColor');
        modified = true;
      }
      if (content.contains('GradientColors.btnGradient')) {
        // We just let it use the fallback solid black defined in GradientColors
        // Or if it was explicitly a gradient it will now just be dark context aware if we update the GradientColors const properly.
        // For now let's just leave the constant since we updated colors.dart to make it black.
      }

      // Let's also fix text colors that might be hardcoded to white on these buttons to use context.colorScheme.onPrimary
      // Example: TextStyle(color: Colors.white) inside exactly a container that had defoultColor
      // This is harder to regex safely, but we added reverseTextColor and onPrimaryColor to ThemeColors.

      if (modified) {
        await entity.writeAsString(content);
        filesModified++;
        print('Updated ${entity.path}');
      }
    }
  }
  print('Replaced colors in $filesModified files.');
}
