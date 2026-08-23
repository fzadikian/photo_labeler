import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final inputPath = args.isNotEmpty ? args[0] : 'build/magick.exe';
  final file      = File(inputPath);
  if (!file.existsSync()) {
    print('Error: $inputPath not found.');
    exit(1);
  }

  final bytes      = file.readAsBytesSync();
  final compressed = gzip.encode(bytes);
  final b64        = base64Encode(compressed);

  final outputFile = File('lib/src/magick_bundle.dart');
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync("const String bundledMagickGzipBase64 = '$b64';\n");
  print('Embedded $inputPath.');
}
