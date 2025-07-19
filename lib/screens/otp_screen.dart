import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  int _resendCooldown = 0;
  bool _canResend = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) {
            _resendCooldown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      DialogHelper.showLoadingDialog(
        context,
        message: 'Memproses pendaftaran...',
      );
    }

    final success = await authProvider.sendOtp(
      authProvider.currentIdentifier!,
      authProvider.currentType!,
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP berhasil dikirim ulang')),
      );
      _startResendCooldown();
    } else if (mounted && authProvider.error != null) {
      DialogHelper.showErrorDialog(
        context,
        message: authProvider.error!,
        onRetry: _handleResendOtp,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Memproses pendaftaran...',
        );
      }

      final success = await authProvider.handleOtp(_otpController.text);

      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        if (authProvider.currentType == 'forgot') {
          authProvider.clearCurrentData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah. Silakan login kembali.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        } else {
          authProvider.clearCurrentData();
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (mounted && authProvider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: authProvider.error!,
          onRetry: _handleSubmit,
        );
      }
    }
  }

  String _getMessage() {
    final authProvider = Provider.of<AuthProvider>(context);
    final identifier = authProvider.currentIdentifier ?? '';
    final type = authProvider.currentType ?? '';

    String action = '';
    switch (type) {
      case 'register':
        action = 'registrasi';
        break;
      case 'login':
        action = 'login';
        break;
      case 'forgot':
        action = 'reset password';
        break;
      default:
        action = 'melanjutkan';
    }

    return 'Kami telah mengirimkan kode OTP pada $identifier untuk autentikasi $action';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                SvgPicture.asset('assets/images/ic_otp.svg', height: 175),
                const SizedBox(height: 30),
                const Text(
                  "Masukkan Kode OTP",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getMessage(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.color_535353,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.transparent,
                  autoFocus: true,
                  animationType: AnimationType.scale,
                  textStyle: const TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 32,
                    activeColor: AppColors.color_B3B3B3,
                    inactiveColor: AppColors.color_B3B3B3,
                    selectedColor: AppColors.color_0FB7A6,
                    activeFillColor: Colors.transparent,
                    inactiveFillColor: Colors.transparent,
                    selectedFillColor: Colors.transparent,
                    borderWidth: 3,
                  ),
                  enableActiveFill: true,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onChanged: (value) {},
                  onCompleted: (value) =>
                      authProvider.isLoading ? null : _handleSubmit(),
                ),
                TextButton(
                  onPressed: _canResend ? _handleResendOtp : null,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Kirim ulang kode dalam ',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: AppColors.color_535353,
                          ),
                        ),
                        TextSpan(
                          text: _resendCooldown == 0
                              ? 'sekarang'
                              : "$_resendCooldown detik",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: AppColors.color_0FB7A6,
                          ),
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
    );
  }
}
