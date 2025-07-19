import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:bengkelsampah_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/validation_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Store identifier for reset password screen
      authProvider.currentIdentifier = _identifierController.text;

      if (mounted) {
        Navigator.pushNamed(context, '/reset-password');
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
                SvgPicture.asset('assets/images/ic_forgot.svg', height: 175),
                const SizedBox(height: 30),
                const Text(
                  "Masukkan Email atau Telepon",
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
                  "Kami akan mengirimkan kode pada email atau telepon yang terkait dengan akun Anda",
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
                  label: 'Identifier',
                  hint: 'identifier@example.com',
                  controller: _identifierController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email atau telepon harus diisi';
                    }
                    if (value.contains('@')) {
                      return ValidationHelper.validateEmail(value);
                    }
                    return ValidationHelper.validatePhone(value);
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 50),
                GradientButton(
                  text: 'Lanjutkan',
                  onPressed: () => _handleSubmit(),
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
