import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.color_FFFFFF,
          foregroundColor: AppColors.color_0FB7A6,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: AppColors.color_0FB7A6,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FB7A6,
                ),
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.color_FFFFFF,
          side: const BorderSide(color: AppColors.color_FFFFFF, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: AppColors.color_FFFFFF,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_FFFFFF,
                ),
              ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final Gradient? gradient;
  final Color textColor;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 40,
    this.borderRadius = 30,
    this.gradient,
    this.textColor = AppColors.color_FFFFFF,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradient1,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: AppColors.color_FFFFFF,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class OutlinePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const OutlinePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.color_0FA39A,
          side: const BorderSide(color: AppColors.color_0FA39A, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: AppColors.color_0FA39A,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FA39A,
                ),
              ),
      ),
    );
  }
}

class OutlineRedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const OutlineRedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.color_F44336,
          side: const BorderSide(color: AppColors.color_F44336, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: AppColors.color_F44336,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_F44336,
                ),
              ),
      ),
    );
  }
}
