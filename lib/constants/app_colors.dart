import 'package:flutter/material.dart';

class AppColors {
  static const Color color_F8FAFB = Color(0xFFF8FAFB);
  static const Color color_000000 = Color(0xFF000000);
  static const Color color_666D80 = Color(0xFF666D80);
  static const Color color_DFE1E7 = Color(0xFFDFE1E7);
  static const Color color_8CC6BF = Color(0xFF8CC6BF);

  static const Color color_0FB7A6 = Color(0xFF0FB7A6);
  static const Color color_40E0D0 = Color(0xFF40E0D0);
  static const Color color_008B8B = Color(0xFF008B8B);
  static const Color color_0FA39A = Color(0xFF0FA39A);

  static const Color color_F44336 = Color(0xFFF44336);
  static const Color color_FFAB2A = Color(0xFFFFAB2A);
  static const Color color_6C919C = Color(0xFF6C919C);

  static const Color color_212121 = Color(0xFF212121);
  static const Color color_404040 = Color(0xFF404040);
  static const Color color_535353 = Color(0xFF535353);
  static const Color color_6F6F6F = Color(0xFF6F6F6F);
  static const Color color_B3B3B3 = Color(0xFFB3B3B3);
  static const Color color_D9D9D9 = Color(0xFFD9D9D9);
  static const Color color_F6F7FB = Color(0xFFF6F7FB);
  static const Color color_FFFFFF = Color(0xFFFFFFFF);
  static const Color color_F3F3F3 = Color(0xFFF3F3F3);
  static const Color color_E9E9E9 = Color(0xFFE9E9E9);

  static const gradientWhite = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
  );

  static const gradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF40E0D0),
      Color(0xFF0FB7A6),
    ],
  );

  static const gradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.72, 1.0],
    colors: [
      Color(0xFF008B8B),
      Color(0xFF40E0D0),
      Color(0xFF40E0D0),
    ],
  );

  static final gradient3 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 0.11, 0.26, 0.49, 0.69, 1.0],
    colors: [
      const Color(0xFF008B8B),
      const Color(0xFF08938B).withValues(alpha: 0.97),
      const Color(0xFF0FA39A).withValues(alpha: 0.87),
      const Color(0xFF40E0D0).withValues(alpha: 0.78),
      const Color(0xFF20B2AA),
      const Color(0xFF008B8B)
    ],
  );

  static final gradient4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.5, 1.0],
    colors: [
      const Color(0xFF40E0D0),
      const Color(0xFF0FB7A6).withValues(alpha: 0.80),
      const Color(0xFF0FB7A6).withValues(alpha: 0.70)
    ],
  );
}
