import 'dart:io';

void main() async {
  final executable = Platform.isWindows ? 'flutter.bat' : 'flutter';
  var result = await Process.run(executable, ['analyze']);
  String out = result.stdout;

  var lines = out.split('\n');
  List<String> errors = [];
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('undefined')) {
      errors.add(lines[i].trim());
    }
  }
  File('context_errors_clean.txt').writeAsStringSync(errors.join('\n'));
}
