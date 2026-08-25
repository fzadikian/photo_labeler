import 'dart:io';
import 'package:path/path.dart' as p;
import 'photo_labeler.dart';
import 'src/bundle.dart';
import 'src/extractor.dart';

String get zenityExe {
  if (Platform.isWindows) {
    return extractBundledBinary('zenity.exe', bundledZenityGzipBase64);
  }
  return 'zenity';
}

Future<String?> selectDirectory() async {
  final res = await Process.run(zenityExe, [
    '--file-selection',
    '--directory',
    '--title=Select Output Directory',
  ]);
  final path = res.stdout.toString().trim();
  return path.isNotEmpty ? path : null;
}

Future<List<String>?> selectFiles() async {
  final res = await Process.run(zenityExe, [
    '--file-selection',
    '--multiple',
    '--separator=|',
    '--title=Select Images to Label',
    '--file-filter=Supported Images | *.jpg *.jpeg *.png *.webp *.tif *.tiff *.heic *.heif *.JPG *.JPEG *.PNG *.WEBP *.TIF *.TIFF *.HEIC *.HEIF',
    '--file-filter=All files | *',
  ]);
  final output = res.stdout.toString().trim();
  if (output.isEmpty) return null;
  final list = output
      .split('|')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && isSupportedImage(s))
      .toList();
  return list.isNotEmpty ? list : null;
}

Future<void> showErrorDialog(String message) async {
  await Process.run(zenityExe, [
    '--error',
    '--title=Photo Labeler',
    '--text=$message',
  ]);
}

Future<void> processWithProgress(List<String> files, String outputDir) async {
  final progress = await Process.start(zenityExe, [
    '--progress',
    '--title=Photo Labeler',
    '--text=Starting...',
    '--percentage=0',
    '--no-cancel',
  ]);

  for (var i = 0; i < files.length; i++) {
    final name = p.basename(files[i]);

    progress.stdin.writeln('# Processing $name (${i}/${files.length} completed)...');
    await progress.stdin.flush();

    await overlayMetadata(files[i], outputDir);

    final pct = (((i + 1) / files.length) * 100).toInt();
    progress.stdin.writeln('$pct');
    await progress.stdin.flush();
  }

  progress.stdin.writeln('# Done! ${files.length}/${files.length} images labeled.');
  await progress.stdin.flush();

  await progress.stdin.close();
  await progress.exitCode;
}

Future<void> runZenity() async {
  final outputDir = await selectDirectory();
  if (outputDir == null) {
    await showErrorDialog('No output directory selected.');
    return;
  }

  final files = await selectFiles();
  if (files == null || files.isEmpty) {
    await showErrorDialog('No valid images selected (supported: TIFF, JPEG, HEIC, PNG, WebP).');
    return;
  }

  Directory(outputDir).createSync(recursive: true);
  await processWithProgress(files, outputDir);
}
