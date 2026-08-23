import 'dart:convert';
import 'dart:io';

String encodeBinary(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    print('Error: $path not found.');
    exit(1);
  }
  final bytes = file.readAsBytesSync();
  final compressed = gzip.encode(bytes);
  final b64 = base64Encode(compressed);
  print('Embedded $path');
  return b64;
}

void main(List<String> args) {
  final magickPath = args.isNotEmpty ? args[0] : 'build/magick.exe';
  final zenityPath = args.length > 1 ? args[1] : 'build/zenity.exe';

  final magickB64 = encodeBinary(magickPath);
  final zenityB64 = encodeBinary(zenityPath);

  final outputFile = File('lib/src/bundle.dart');
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync('''
// Generated file - do not edit directly
const String bundledMagickGzipBase64 = '$magickB64';
const String bundledZenityGzipBase64 = '$zenityB64';
''');
}
