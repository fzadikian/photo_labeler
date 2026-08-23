import 'dart:convert';
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:path/path.dart' as p;
import 'src/magick_bundle.dart';

String get defaultMagickExecutable {
  if (Platform.isWindows) {
    final tempDir    = Directory(p.join(Directory.systemTemp.path, 'photo_labeler'));
    final tempMagick = File(p.join(tempDir.path, 'magick.exe'));
    if (tempMagick.existsSync() && tempMagick.lengthSync() > 0) {
      return tempMagick.path;
    }
    tempDir.createSync(recursive: true);
    final bytes = gzip.decode(base64Decode(bundledMagickGzipBase64));
    tempMagick.writeAsBytesSync(bytes);
    return tempMagick.path;
  }
  return 'magick';
}

String frac(String val) {
  final parts = val.split('/');
  if (parts.length != 2) return val;
  final a = double.tryParse(parts[0]);
  final b = double.tryParse(parts[1]);
  if (a == null || b == null || b == 0) return val;
  return (a / b).toStringAsFixed(1);
}

Future<void> overlayMetadata(String magick, String inputPath, String outputDir) async {
  final bytes = await File(inputPath).readAsBytes();
  final tags = await readExifFromBytes(bytes);

  String tag(String key) => tags[key]?.printable.trim() ?? '–';

  final model    = tag('Image Model');
  final shutter  = tag('EXIF ExposureTime');
  final iso      = tag('EXIF ISOSpeedRatings');
  final aperture = frac(tag('EXIF FNumber'));
  final fl       = tag('EXIF FocalLength');
  final fl35     = tag('EXIF FocalLengthIn35mmFilm');

  final text = '$model | Shutter speed: ${shutter}s | Aperture: f/$aperture | ISO: $iso | FL: ${fl}mm (${fl35}mm equiv)';

  final ext     = p.extension(inputPath);
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
