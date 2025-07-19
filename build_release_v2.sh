#!/bin/bash

echo "🚀 Starting Bengkel Sampah Release Build v2.0..."

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
echo "📱 Current version: $CURRENT_VERSION"

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate app icons (if flutter_launcher_icons is configured)
echo "🎨 Generating app icons..."
flutter pub run flutter_launcher_icons:main

# Build release APK
echo "🔨 Building release APK..."
flutter build apk --release

# Build App Bundle (recommended for Play Store)
echo "📦 Building App Bundle..."
flutter build appbundle --release

echo "✅ Build completed!"
echo ""
echo "📱 Files generated:"
echo "   - APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   - App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "📋 Version Information:"
echo "   - Version: $CURRENT_VERSION"
echo "   - Min SDK: 21 (Android 5.0)"
echo "   - Target SDK: 34 (Android 14)"
echo "   - Compile SDK: 34"
echo ""
echo "📋 Next steps:"
echo "   1. Test the APK on a device"
echo "   2. Upload the .aab file to Google Play Console"
echo "   3. Fill in store listing information"
echo "   4. Submit for review"
echo ""
echo "⚠️  Important Notes:"
echo "   - Make sure you have proper keystore configured"
echo "   - Test on different Android versions (5.0+)"
echo "   - Verify all permissions are properly declared" 