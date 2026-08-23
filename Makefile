MAGICK_URL := https://github.com/ImageMagick/ImageMagick/releases/download/7.1.2-29/ImageMagick-7.1.2-29-portable-Q16-x64.7z

.PHONY: all linux windows clean

all: linux

linux:
	mkdir -p build lib/src
	@test -f lib/src/magick_bundle.dart || echo "const String bundledMagickGzipBase64 = '';" > lib/src/magick_bundle.dart
	dart pub get
	dart compile exe bin/photo_labeler.dart -o build/photo_labeler

windows:
	mkdir -p build

	curl -L $(MAGICK_URL) -o magick.7z
	7z e magick.7z magick.exe -obuild
	rm -f magick.7z

	dart pub get
	dart run tool/embed_magick.dart build/magick.exe
	dart compile exe bin/photo_labeler.dart -o build/photo_labeler.exe

clean:
	rm -rf build magick.7z lib/src/magick_bundle.dart
