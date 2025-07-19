import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/validation_helper.dart';
import '../helpers/dialog_helper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullnameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Store registration data
      authProvider.currentFullname = _fullnameController.text;
      authProvider.currentPassword = _passwordController.text;
      authProvider.currentConfirmPassword = _confirmPasswordController.text;

      // Show loading dialog
      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Memproses pendaftaran...',
        );
      }

      // Send OTP
      final success = await authProvider.sendOtp(
        _identifierController.text,
        'register',
      );

      // Hide loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        Navigator.pushNamed(context, '/otp');
      } else if (mounted && authProvider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: authProvider.error!,
          onRetry: _handleRegister,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.30,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient4,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.3,
                child: SvgPicture.asset(
                  'assets/images/ic_appbar_auth.svg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'untuk mengakses aplikasi!',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                      const SizedBox(height: 53),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.color_FFFFFF,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 30,
                            left: 25,
                            right: 25,
                            bottom: 50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                label: 'Nama Lengkap',
                                hint: 'Customer Bengkel',
                                controller: _fullnameController,
                                validator: ValidationHelper.validateName,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 25),
                              CustomTextField(
                                label: 'Identifier',
                                hint: 'identifier@example.com',
                                controller: _identifierController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'identifier harus diisi';
                                  }
                                  if (value.contains('@')) {
                                    return ValidationHelper.validateEmail(
                                        value);
                                  }
                                  return ValidationHelper.validatePhone(value);
                                },
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 25),
                              CustomTextField(
                                label: 'Kata Sandi',
                                hint: '••••••••••••••••',
                                controller: _passwordController,
                                isPassword: true,
                                isPasswordVisible: _isPasswordVisible,
                                onTogglePassword: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                validator: ValidationHelper.validatePassword,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 25),
                              CustomTextField(
                                label: 'Konfirmasi Kata Sandi',
                                hint: '••••••••••••••••',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                isPasswordVisible: _isConfirmPasswordVisible,
                                onTogglePassword: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi password harus diisi';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Password dan konfirmasi password tidak sama';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                              ),
                              const SizedBox(height: 50),
                              GradientButton(
                                text: 'Daftar',
                                onPressed: _handleRegister,
                                height: 40,
                                borderRadius: 30,
                              ),
                              const SizedBox(height: 35),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Sudah memiliki akun? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_B3B3B3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_0FB7A6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
