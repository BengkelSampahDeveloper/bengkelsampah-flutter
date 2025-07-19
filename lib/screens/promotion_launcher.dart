import 'package:flutter/material.dart';
import 'promotion_video_screen.dart';

class PromotionLauncher extends StatelessWidget {
  const PromotionLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'BengkelSampah',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Promotion Video',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PromotionVideoScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0FB7A6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Start Promotion Video',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap to start the animated promotion video\nPerfect for screen recording!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
