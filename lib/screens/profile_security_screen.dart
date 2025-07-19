import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/helpers/global_helper.dart';
import 'package:bengkelsampah_app/providers/detail_profile_provider.dart';
import 'package:bengkelsampah_app/providers/auth_provider.dart';
import 'package:bengkelsampah_app/widgets/custom_text_field.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class ProfileSecurityScreen extends StatefulWidget {
  const ProfileSecurityScreen({super.key});

  @override
  State<ProfileSecurityScreen> createState() => _ProfileSecurityScreenState();
}

class _ProfileSecurityScreenState extends State<ProfileSecurityScreen> {
  final GlobalIdentifierManager _identifierManager = GlobalIdentifierManager();

  @override
  void initState() {
    super.initState();
    _identifierManager.loadIdentifier();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        title: const Text(
          'Pengaturan Keamanan',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _identifierManager.loadIdentifier,
                color: AppColors.color_0FB7A6,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildIdentifierSection(context),
                        const SizedBox(height: 20),
                        _buildPasswordSection(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentifierSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email/No. Telepon',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: AppColors.color_404040,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _identifierManager.identifierNotifier,
                builder: (context, identifier, child) {
                  return Text(
                    identifier,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildEditIdentifierBottomSheet(
                    context,
                    _identifierManager.currentIdentifier,
                  ),
                );
              },
              child: const Text(
                "Ubah",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FB7A6,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.color_D9D9D9,
        ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: AppColors.color_404040,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                "••••••••",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildEditPasswordBottomSheet(context),
                );
              },
              child: const Text(
                "Ubah",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FB7A6,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.color_D9D9D9,
        ),
      ],
    );
  }

  Widget _buildEditIdentifierBottomSheet(
      BuildContext context, String currentIdentifier) {
    return _EditIdentifierBottomSheet(
      currentIdentifier: currentIdentifier,
      identifierManager: _identifierManager,
    );
  }

  Widget _buildEditPasswordBottomSheet(BuildContext context) {
    return _EditPasswordBottomSheet();
  }
}

// Separate StatefulWidget for Edit Identifier Bottom Sheet
class _EditIdentifierBottomSheet extends StatefulWidget {
  final String currentIdentifier;
  final GlobalIdentifierManager identifierManager;

  const _EditIdentifierBottomSheet({
    required this.currentIdentifier,
    required this.identifierManager,
  });

  @override
  State<_EditIdentifierBottomSheet> createState() =>
      _EditIdentifierBottomSheetState();
}

class _EditIdentifierBottomSheetState
    extends State<_EditIdentifierBottomSheet> {
  late final TextEditingController identifierController;
  late final TextEditingController otpController;
  final formKey = GlobalKey<FormState>();
  bool showOtpField = false;
  int resendCooldown = 0;
  bool canResend = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    identifierController =
        TextEditingController(text: widget.currentIdentifier);
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    timer?.cancel();
    identifierController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void startResendCooldown() {
    setState(() {
      resendCooldown = 60;
      canResend = false;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendCooldown > 0) {
            resendCooldown--;
          } else {
            canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> handleSendOtp() async {
    if (!canResend) return;

    // Validate identifier field first
    if (identifierController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email/No. Telepon tidak boleh kosong')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      DialogHelper.showLoadingDialog(
        context,
        message: 'Mengirim OTP...',
      );
    }

    final success = await authProvider.sendOtp(
      identifierController.text.trim(),
      'change',
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (success && mounted) {
      setState(() {
        showOtpField = true;
      });
      startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP berhasil dikirim')),
      );
    } else if (mounted && authProvider.error != null) {
      DialogHelper.showErrorDialog(
        context,
        message: authProvider.error!,
        onRetry: handleSendOtp,
      );
    }
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate() || otpController.text.length != 6) {
      return;
    }

    try {
      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Menyimpan perubahan...',
        );
      }

      final provider = Provider.of<DetailProfileProvider>(
        context,
        listen: false,
      );
      final success = await provider.updateProfile(
        identifier: identifierController.text.trim(),
        otp: otpController.text,
      );

      if (mounted) {
        Navigator.pop(context); // Hide loading
      }

      if (success && mounted) {
        Navigator.pop(context); // Close bottom sheet
        // Update global identifier
        await widget.identifierManager.updateIdentifier(
          identifierController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identifier berhasil diubah')),
        );
      } else if (mounted && provider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: provider.error!,
          onRetry: handleSubmit,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Hide loading
        DialogHelper.showErrorDialog(
          context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Email/No. Telepon',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: identifierController,
                label: 'Email/No. Telepon',
                hint: 'Masukkan email/no. telepon baru',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email/No. Telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (showOtpField) ...[
                const Text(
                  'Masukkan Kode OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 10),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController,
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
                  onChanged: (value) {
                    // Auto submit when 6 digits are entered
                    if (value.length == 6) {
                      handleSubmit();
                    }
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: canResend ? handleSendOtp : null,
                    child: Text(
                      resendCooldown == 0
                          ? 'Kirim ulang OTP'
                          : 'Kirim ulang dalam $resendCooldown detik',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: canResend
                            ? AppColors.color_0FB7A6
                            : AppColors.color_B3B3B3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  if (!showOtpField)
                    Expanded(
                      child: GradientButton(
                        onPressed: handleSendOtp,
                        text: 'Kirim OTP',
                      ),
                    )
                  else
                    Expanded(
                      child: GradientButton(
                        onPressed: handleSubmit,
                        text: 'Simpan',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate StatefulWidget for Edit Password Bottom Sheet
class _EditPasswordBottomSheet extends StatefulWidget {
  @override
  State<_EditPasswordBottomSheet> createState() =>
      _EditPasswordBottomSheetState();
}

class _EditPasswordBottomSheetState extends State<_EditPasswordBottomSheet> {
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  final formKey = GlobalKey<FormState>();
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Menyimpan perubahan...',
        );
      }

      final provider = Provider.of<DetailProfileProvider>(
        context,
        listen: false,
      );
      final success = await provider.updateProfile(
        newPassword: newPasswordController.text,
      );

      if (mounted) {
        Navigator.pop(context); // Hide loading
      }

      if (success && mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
      } else if (mounted && provider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: provider.error!,
          onRetry: handleSubmit,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Hide loading
        DialogHelper.showErrorDialog(
          context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Password',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: newPasswordController,
                label: 'Password Baru',
                hint: 'Masukkan password baru',
                isPassword: true,
                isPasswordVisible: isNewPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    isNewPasswordVisible = !isNewPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password baru tidak boleh kosong';
                  }
                  if (value.length < 8) {
                    return 'Password minimal 8 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Konfirmasi Password Baru',
                hint: 'Masukkan konfirmasi password baru',
                isPassword: true,
                isPasswordVisible: isConfirmPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != newPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: handleSubmit,
                text: 'Simpan',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
