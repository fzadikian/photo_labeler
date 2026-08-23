import 'dart:io';
import 'photo_labeler.dart';

Future<void> runCli(List<String> args) async {
  final outputDir = args[0];
  final files = args.sublist(1);
  Directory(outputDir).createSync(recursive: true);

  for (var i = 0; i < files.length; i++) {
    print('Processing ${files[i]} (${i + 1}/${files.length})');
    await overlayMetadata(files[i], outputDir);
  }

  print('Done! ${files.length} image(s) labeled.');
}

