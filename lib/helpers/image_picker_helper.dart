import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_colors.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Pick image from camera with proper error handling
  static Future<File?> pickImageFromCamera(BuildContext context) async {
    try {
      // Handle web platform
      if (UniversalPlatform.isWeb) {
        return await _pickImageFromWeb(context);
      }

      // Handle mobile platforms
      return await _pickImageFromCameraMobile(context);
    } catch (e) {
      debugPrint('Camera picker error: $e');
      _showErrorSnackBar(
          context, 'Tidak dapat mengakses kamera: ${e.toString()}');
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

  /// Pick image from camera for mobile platforms
  static Future<File?> _pickImageFromCameraMobile(BuildContext context) async {
    try {
      // Request camera permission
      PermissionStatus cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }

      if (cameraStatus.isPermanentlyDenied) {
        _showErrorSnackBar(context,
            'Izin kamera diperlukan. Silakan aktifkan di pengaturan aplikasi.');
        return null;
      }

      if (!cameraStatus.isGranted) {
        _showErrorSnackBar(context, 'Izin kamera ditolak');
        return null;
      }

      // Take photo with error handling
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        // Verify file exists and is accessible
        final file = File(image.path);
        if (await file.exists()) {
          // Add small delay to ensure file is fully written
          await Future.delayed(const Duration(milliseconds: 200));
          return file;
        } else {
          debugPrint('Camera image file not found: ${image.path}');
          return null;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Camera mobile error: $e');
      _showErrorSnackBar(
          context, 'Tidak dapat mengakses kamera: ${e.toString()}');
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

      // Try image_picker first
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        // Verify file exists and is accessible
        final file = File(image.path);
        if (await file.exists()) {
          // Add small delay to ensure file is fully accessible
          await Future.delayed(const Duration(milliseconds: 100));
          return file;
        } else {
          debugPrint('Gallery image file not found: ${image.path}');
        }
      }

      // Fallback to file_picker if image_picker fails
      try {
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
      } catch (e) {
        debugPrint('File picker fallback error: $e');
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
