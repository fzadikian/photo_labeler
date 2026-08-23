import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

String extractBundledBinary(String filename, String base64Data) {
  final tempDir = Directory(p.join(Directory.systemTemp.path, 'photo_labeler'));
  final tempFile = File(p.join(tempDir.path, filename));
  if (tempFile.existsSync() && tempFile.lengthSync() > 0) {
    return tempFile.path;
  }
  tempDir.createSync(recursive: true);
  final bytes = gzip.decode(base64Decode(base64Data));
  tempFile.writeAsBytesSync(bytes);
  return tempFile.path;
}
