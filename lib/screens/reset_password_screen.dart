import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:bengkelsampah_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/validation_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Store new password and confirmation
      authProvider.currentPassword = _passwordController.text;
      authProvider.currentConfirmPassword = _confirmPasswordController.text;
      authProvider.currentType = 'forgot';

      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Memproses pengaturan ulang...',
        );
      }

      // Send OTP
      final success = await authProvider.sendOtp(
        authProvider.currentIdentifier!,
        'forgot',
      );

      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        Navigator.pushNamed(context, '/otp');
      } else if (mounted && authProvider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: authProvider.error!,
          onRetry: _handleSubmit,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                SvgPicture.asset('assets/images/ic_reset.svg', height: 175),
                const SizedBox(height: 30),
                const Text(
                  "Masukkan Kata Sandi",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Gunakan kata sandi yang baru untuk mengatur ulang pada akun Anda",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.color_535353,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 20),
                CustomTextField(
                    label: 'Konfirmasi Kata Sandi',
                    hint: '••••••••••••••••',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                    textInputAction: TextInputAction.done),
                const SizedBox(height: 50),
                GradientButton(
                  text: 'Lanjutkan',
                  onPressed: _handleSubmit,
                  height: 40,
                  borderRadius: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
