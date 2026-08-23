import 'package:photo_labeler/cli.dart';
import 'package:photo_labeler/zenity.dart';

void main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help') || args.length == 1) {
    print('Usage: photo_labeler <output_dir> <image> [image ...]');
    print('       photo_labeler (runs UI)');
    return;
  }

  if (args.length >= 2) {
    await runCli(args);
  } else {
    await runZenity();
  }
}
