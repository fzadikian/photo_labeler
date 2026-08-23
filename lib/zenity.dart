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
    '--file-filter=Images | *.jpg *.jpeg *.png *.JPG *.JPEG *.PNG',
    '--file-filter=All files | *',
  ]);
  final output = res.stdout.toString().trim();
  if (output.isEmpty) return null;
  final list = output
      .split('|')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return list.isNotEmpty ? list : null;
}

Future<void> showCompletionDialog(int count) async {
  await Process.run(zenityExe, [
    '--info',
    '--title=Photo Labeler',
    '--text=Done! $count image(s) labeled.',
  ]);
}

Future<void> processWithProgress(List<String> files, String outputDir) async {
  final progress = await Process.start(zenityExe, [
    '--progress',
    '--title=Photo Labeler',
    '--text=Starting...',
    '--percentage=0',
    '--auto-close',
  ]);

  for (var i = 0; i < files.length; i++) {
    final name = p.basename(files[i]);
    final pct = ((i / files.length) * 100).toInt();

    print('Processing ${files[i]} (${i + 1}/${files.length})');

    progress.stdin.writeln('$pct');
    progress.stdin.writeln('# Processing $name (${i + 1}/${files.length})...');
    await progress.stdin.flush();

    await overlayMetadata(files[i], outputDir);
  }

  progress.stdin.writeln('100');
  progress.stdin.writeln('# Finished!');
  await progress.stdin.flush();
  await progress.stdin.close();
  await progress.exitCode;

  print('Done! ${files.length} image(s) labeled.');
}

Future<void> runZenity() async {
  final outputDir = await selectDirectory();
  if (outputDir == null) return;

  final files = await selectFiles();
  if (files == null || files.isEmpty) return;

  Directory(outputDir).createSync(recursive: true);
  await processWithProgress(files, outputDir);
  await showCompletionDialog(files.length);
}
