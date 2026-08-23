MAGICK_URL := https://github.com/ImageMagick/ImageMagick/releases/download/7.1.2-29/ImageMagick-7.1.2-29-portable-Q16-x64.7z
ZENITY_URL := https://github.com/ncruces/zenity/releases/download/v0.10.15/zenity_win64.zip

.PHONY: all linux windows clean

all: linux

linux:
	mkdir -p build lib/src
	@test -f lib/src/bundle.dart || printf "const String bundledMagickGzipBase64 = '';\nconst String bundledZenityGzipBase64 = '';\n" > lib/src/bundle.dart
	dart pub get
	dart compile exe bin/photo_labeler.dart -o build/photo_labeler

build/magick.exe:
	mkdir -p build
	curl -L $(MAGICK_URL) -o build/magick.7z
	7z e build/magick.7z magick.exe -obuild
	rm -f build/magick.7z

build/zenity.exe:
	mkdir -p build
	curl -L $(ZENITY_URL) -o build/zenity.zip
	7z e build/zenity.zip zenity.exe -obuild
	rm -f build/zenity.zip

windows: build/magick.exe build/zenity.exe
	dart pub get
	dart run tool/embed_binaries.dart build/magick.exe build/zenity.exe
	dart compile exe bin/photo_labeler.dart -o build/photo_labeler.exe

clean:
	rm -rf build lib/src/bundle.dart
