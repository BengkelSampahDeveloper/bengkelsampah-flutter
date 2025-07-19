import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn = await _apiService.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_FFFFFF,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/big_logo.webp',
                width: 147,
                height: 147,
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bengkel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        foreground: Paint()
                          ..shader = AppColors.gradient1.createShader(
                              const Rect.fromLTWH(0, 0, 100, 100)),
                      ),
                    ),
                    const TextSpan(
                      text: 'Sampah',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: AppColors.color_212121,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
          const Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Text(
              'Supported by : PT. Agincourt Resources',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.color_40E0D0,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      )),
    );
  }
}
