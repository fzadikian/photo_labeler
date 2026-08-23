# photo_labeler

Overlays EXIF metadata (camera model, shutter speed, aperture, ISO, focal length) onto photos as a label in the bottom-right corner.  
Requires `imagemagick` (bundled in Windows build).

## Usage

```
photo_labeler <output_dir> <image> [image ...]
```

```
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

The standalone binary will be at `build/photo_labeler.exe` with `imagemagick` embedded.
