import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_version_model.dart';

class VersionService {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.bengkelsampah.app';

  /// Get current app version info
  static Future<PackageInfo> getCurrentVersion() async {
    return await PackageInfo.fromPlatform();
  }

  /// Check if update is required
  static bool isUpdateRequired(AppVersionModel? serverVersion) {
    if (serverVersion == null) return false;

    // For now, we'll use a simple version code comparison
    // In a real app, you might want to use semantic versioning
    return serverVersion.isRequired;
  }

  /// Check if update is available
  static Future<bool> isUpdateAvailable(AppVersionModel? serverVersion) async {
    if (serverVersion == null) return false;

    PackageInfo packageInfo = await getCurrentVersion();
    int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    return currentVersionCode < serverVersion.versionCode;
  }

  /// Show update dialog
  static Future<void> showUpdateDialog(
      BuildContext context, AppVersionModel serverVersion,
      {bool isRequired = false}) async {
    return showDialog(
      context: context,
      barrierDismissible: !isRequired, // Can't dismiss if required
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => !isRequired, // Can't pop if required
          child: AlertDialog(
            title: Text(
              isRequired ? 'Update Wajib' : 'Update Tersedia',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serverVersion.updateMessage ??
                      (isRequired
                          ? 'Versi terbaru wajib diinstall untuk melanjutkan menggunakan aplikasi.'
                          : 'Versi terbaru tersedia dengan fitur baru dan perbaikan.'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Versi terbaru: ${serverVersion.version}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              if (!isRequired)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nanti'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openPlayStore();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Sekarang'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Open Play Store
  static Future<void> _openPlayStore() async {
    final Uri url = Uri.parse(_playStoreUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// Check version and show dialog if needed
  static Future<void> checkVersionAndShowDialog(
    BuildContext context,
    AppVersionModel? serverVersion,
  ) async {
    if (serverVersion == null) return;

    bool updateAvailable = await isUpdateAvailable(serverVersion);
    bool updateRequired = isUpdateRequired(serverVersion);

    if (updateAvailable) {
      await showUpdateDialog(
        context,
        serverVersion,
        isRequired: updateRequired,
      );
    }
  }
}
