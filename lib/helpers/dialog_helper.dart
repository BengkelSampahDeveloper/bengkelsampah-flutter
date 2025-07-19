import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/loading.dart';

class DialogHelper {
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? 'Error',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.color_6F6F6F,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.color_0FB7A6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> showLoadingDialog(
    BuildContext context, {
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoAndSpinner(
                imageAssets: 'assets/images/small_logo.png',
                arcColor: AppColors.color_0FB7A6,
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showDeleteDialog(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? 'Delete',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.color_6F6F6F,
              ),
            ),
          ),
          if (onDelete != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.color_0FB7A6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
