# photo_labeler

Overlays EXIF metadata (camera model, shutter speed, aperture, ISO, focal length) onto photos as a label in the bottom-right corner.  
On Linux, `imagemagick` and `zenity` are required.

## Usage

### UI

Run without arguments (or double-click the binary):

```bash
photo_labeler
```

### Command Line

```bash
photo_labeler <output_dir> <image> [image ...]
```

```bash
photo_labeler ./labeled photo1.jpg photo2.jpg photo3.png
```

## Building

Requires [Dart SDK](https://dart.dev/get-dart) 3.0 or later.

### Linux

```bash
make linux
```

The binary will be at `build/photo_labeler`.

### Windows

Requires `curl` and `7-Zip` on PATH. Downloads the portable `imagemagick` binary automatically.

```bash
make windows
```

The standalone binary will be at `build/photo_labeler.exe` with `imagemagick` and `zenity` embedded.

## Acknowledgements & Third-Party Licenses

The Windows standalone release bundles:
- [ImageMagick](https://imagemagick.org/) (ImageMagick License, ImageMagick Studio LLC)
- [ncruces/zenity](https://github.com/ncruces/zenity) (MIT License, Nuno Cruces)

Dart package dependencies:
- [exif](https://github.com/bigflood/dartexif) (MIT License, bigflood)
- [path](https://github.com/dart-lang/core/tree/main/pkgs/path) (BSD-3-Clause, The Dart Authors)
- [mime](https://github.com/dart-lang/tools/tree/main/pkgs/mime) (BSD-3-Clause, The Dart Authors)
