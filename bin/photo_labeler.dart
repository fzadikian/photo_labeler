import 'dart:io';
import 'package:photo_labeler/photo_labeler.dart';

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: photo_labeler <output_dir> <image> [image ...]');
    exit(1);
  }

  final magick = Platform.isWindows ? 'magick.exe' : 'magick';

  final outputDir = args[0];
  final files     = args.sublist(1);
  Directory(outputDir).createSync(recursive: true);

  for (var i = 0; i < files.length; i++) {
    print('Processing ${files[i]} (${i + 1}/${files.length})');
    await overlayMetadata(magick, files[i], outputDir);
  }

  print('Done! ${files.length} image(s) labeled.');
}
