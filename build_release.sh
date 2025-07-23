#!/bin/bash
set -e

# Get version from pubspec.yaml
echo "Membaca versi dari pubspec.yaml..."
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
if [ -z "$VERSION" ]; then
  echo "Gagal membaca versi dari pubspec.yaml!"
  exit 1
fi
APPNAME="bengkelsampah_app"

# Build web

echo "\n=== Build Web Release ==="
flutter build web --release
WEB_OUT="${APPNAME}_${VERSION}_web.zip"
cd build/web && zip -r "../$WEB_OUT" . && cd ../..
echo "Web build selesai: build/$WEB_OUT"

# Build APK

echo "\n=== Build APK Release ==="
flutter build apk --release
APK_OUT="${APPNAME}_${VERSION}.apk"
cp build/app/outputs/flutter-apk/app-release.apk "build/$APK_OUT"
echo "APK build selesai: build/$APK_OUT"

# Build App Bundle (AAB)

echo "\n=== Build App Bundle (AAB) Release ==="
flutter build appbundle --release
AAB_OUT="${APPNAME}_${VERSION}.aab"
cp build/app/outputs/bundle/release/app-release.aab "build/$AAB_OUT"
echo "AAB build selesai: build/$AAB_OUT"

echo "\n=== Semua build selesai ==="
echo "- Web:    build/$WEB_OUT"
echo "- APK:    build/$APK_OUT"
echo "- AAB:    build/$AAB_OUT" 