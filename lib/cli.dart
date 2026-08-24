import 'dart:io';
import 'photo_labeler.dart';

Future<void> runCli(List<String> args) async {
  final outputDir = args[0];
  final files = args.sublist(1).where(isSupportedImage).toList();
  if (files.isEmpty) {
    print('Error: No valid image files provided (supported: TIFF, JPEG, HEIC, PNG, WebP).');
    exit(1);
  }

  if (FileSystemEntity.isFileSync(outputDir)) {
    print('Error: "$outputDir" is a file, not a directory.');
    exit(1);
  }

  try {
    Directory(outputDir).createSync(recursive: true);
  } catch (e) {
    print('Error: Could not create output directory "$outputDir": $e');
    exit(1);
  }

  for (var i = 0; i < files.length; i++) {
    print('Processing ${files[i]} (${i + 1}/${files.length})');
    await overlayMetadata(files[i], outputDir);
  }

  print('Done! ${files.length} image(s) labeled.');
}
