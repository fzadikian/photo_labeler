import 'dart:io';
import 'package:exif/exif.dart';
import 'package:path/path.dart' as p;

Future<void> overlayMetadata(String magick, String inputPath, String outputDir) async {
  final bytes = await File(inputPath).readAsBytes();
  final tags = await readExifFromBytes(bytes);

  String tag(String key) => tags[key]?.printable.trim() ?? '–';

  final model    = tag('Image Model');
  final shutter  = tag('EXIF ExposureTime');
  final iso      = tag('EXIF ISOSpeedRatings');
  final aperture = tag('EXIF FNumber');
  final fl       = tag('EXIF FocalLength');
  final fl35     = tag('EXIF FocalLengthIn35mmFilm');

  final text = '$model | Shutter: ${shutter}s | f/$aperture | ISO $iso | FL: $fl ($fl35 equiv)';

  final ext     = p.extension(inputPath).toLowerCase();
  final outPath = p.join(outputDir, '${p.basenameWithoutExtension(inputPath)}_labeled$ext');

  final width = int.parse(
    (await Process.run(magick, ['identify', '-format', '%w', inputPath])).stdout.toString().trim()
  );

  final fontSize = width ~/ 75;
  final padding  = width ~/ 120;

  await Process.run(magick, [
    inputPath,
    '-gravity',    'SouthEast',
    '-fill',       'white',
    '-undercolor', '#00000080',
    '-pointsize',  '$fontSize',
    '-annotate',   '+$padding+$padding',
    text,
    outPath,
  ]);
}

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
