import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../widgets/custom_buttons.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 27,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ic_bg.webp',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.gradient3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'BengkelSampah',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selamat Datang',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mulai untuk menjadi penyelamat bumi!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      text: 'Daftar',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
