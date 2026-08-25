import 'dart:ffi';
import 'dart:io';
import 'package:photo_labeler/cli.dart';
import 'package:photo_labeler/zenity.dart';

void hideConsoleOnWindows() {
  if (Platform.isWindows) {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    final freeConsole = kernel32.lookupFunction<Int32 Function(), int Function()>('FreeConsole');
    freeConsole();
  }
}

void main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help') || args.length == 1) {
    print('Usage: photo_labeler <output_dir> <image> [image ...]');
    print('       photo_labeler (runs UI)');
    return;
  }

  if (args.length >= 2) {
    await runCli(args);
  } else {
    hideConsoleOnWindows();
    await runZenity();
  }
}
