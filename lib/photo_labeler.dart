import 'dart:io';
import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'src/bundle.dart';
import 'src/extractor.dart';

String get magickExe {
  if (Platform.isWindows) {
    return extractBundledBinary('magick.exe', bundledMagickGzipBase64);
  }
  return 'magick';
}

const supportedMimeTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/tiff',
  'image/heic',
  'image/heif',
};

bool isSupportedImage(String path) {
  final mime = lookupMimeType(path);
  return mime != null && supportedMimeTypes.contains(mime);
}

String frac(String val) {
  final parts = val.split('/');
  if (parts.length != 2) return val;
  final a = double.tryParse(parts[0]);
  final b = double.tryParse(parts[1]);
  if (a == null || b == null || b == 0) return val;
  return (a / b).toStringAsFixed(1);
}

Future<void> overlayMetadata(String inputPath, String outputDir) async {
  final bytes = await File(inputPath).readAsBytes();
  final tags = await readExifFromBytes(bytes);

  String tag(String key) => tags[key]?.printable.trim() ?? '–';

  final model = tag('Image Model');
  final shutter = tag('EXIF ExposureTime');
  final iso = tag('EXIF ISOSpeedRatings');
  final aperture = frac(tag('EXIF FNumber'));
  final fl = tag('EXIF FocalLength');
  final fl35 = tag('EXIF FocalLengthIn35mmFilm');

  final text = '$model | Shutter speed: ${shutter}s | Aperture: f/$aperture | ISO: $iso | FL: ${fl}mm (${fl35}mm equiv)';

  final ext = p.extension(inputPath);
  final outPath = p.join(outputDir, '${p.basenameWithoutExtension(inputPath)}_labeled$ext');

  final width = int.parse(
    (await Process.run(magickExe, ['identify', '-format', '%w', inputPath])).stdout.toString().trim()
  );

  final fontSize = width ~/ 75;
  final padding = width ~/ 120;

  await Process.run(magickExe, [
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
