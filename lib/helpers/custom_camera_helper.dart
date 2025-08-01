import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_camera.dart';

class CustomCameraHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Show custom camera
  static Future<File?> showCustomCamera(BuildContext context) async {
    try {
      final File? result = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => CustomCamera(
            onImageCaptured: (File imageFile) {
              Navigator.of(context).pop(imageFile);
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return result;
    } catch (e) {
      debugPrint('Custom camera error: $e');
      _showErrorSnackBar(context, 'Gagal membuka kamera: ${e.toString()}');
      return null;
    }
  }

  /// Pick image from gallery with proper error handling
  static Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
      // Handle web platform
      if (UniversalPlatform.isWeb) {
        return await _pickImageFromWeb(context);
      }

      // Handle mobile platforms
      return await _pickImageFromGalleryMobile(context);
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      _showErrorSnackBar(context, 'Gagal mengambil foto: ${e.toString()}');
      return null;
    }
  }

  /// Pick image for web platform
  static Future<File?> _pickImageFromWeb(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.bytes != null) {
        // For web, we return null but the bytes are handled separately
        // This is because web doesn't support File objects the same way
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Web picker error: $e');
      return null;
    }
  }

  /// Pick image from gallery for mobile platforms
  static Future<File?> _pickImageFromGalleryMobile(BuildContext context) async {
    try {
      // Handle permissions for different Android versions
      PermissionStatus status;

      if (UniversalPlatform.isAndroid) {
        // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
        if (await _isAndroid13OrHigher()) {
          status = await Permission.photos.request();
        } else {
          // For Android < 13, use storage permission
          status = await Permission.storage.request();
        }
      } else {
        // For iOS
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        _showErrorSnackBar(
            context, 'Izin galeri diperlukan untuk memilih foto');
        return null;
      }

      // Use file_picker for gallery selection
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          return file;
        } else {
          debugPrint(
              'File picker image file not found: ${result.files.single.path}');
        }
      }

      return null;
    } catch (e) {
      debugPrint('Gallery mobile error: $e');
      _showErrorSnackBar(context, 'Gagal mengambil foto: ${e.toString()}');
      return null;
    }
  }

  /// Check if device is Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (UniversalPlatform.isAndroid) {
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt >= 33; // API level 33 = Android 13
      } catch (e) {
        debugPrint('Error checking Android version: $e');
        // Fallback to permission-based check
        try {
          return await Permission.photos.isGranted ||
              await Permission.storage.isDenied;
        } catch (e) {
          return false;
        }
      }
    }
    return false;
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    // Add delay to ensure context is stable after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.color_FFAB2A,
          ),
        );
      }
    });
  }

  /// Get image bytes for web platform
  static Future<Uint8List?> getWebImageBytes(BuildContext context) async {
    if (!UniversalPlatform.isWeb) return null;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Ensure we get the bytes
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.bytes != null) {
        return result.files.single.bytes;
      }
      return null;
    } catch (e) {
      debugPrint('Web image bytes error: $e');
      _showErrorSnackBar(context, 'Gagal memilih file: ${e.toString()}');
      return null;
    }
  }

  /// Check if web platform supports file picker
  static bool get isWebSupported {
    return UniversalPlatform.isWeb;
  }

  /// Get supported image formats for web
  static List<String> get webSupportedFormats {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  }
}
