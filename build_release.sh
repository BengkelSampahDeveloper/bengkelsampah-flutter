#!/bin/bash

echo "🚀 Starting Bengkel Sampah Release Build Process..."

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

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
echo "📋 Next steps:"
echo "   1. Test the APK on a device"
echo "   2. Upload the .aab file to Google Play Console"
echo "   3. Fill in store listing information"
echo "   4. Submit for review" 