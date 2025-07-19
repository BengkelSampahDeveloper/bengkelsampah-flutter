import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_535353,
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_D9D9D9,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.color_B3B3B3),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.color_B3B3B3),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.color_B3B3B3),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: isPassword
                ? IconButton(
                    icon: isPasswordVisible
                        ? ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [Color(0xFF40E0D0), Color(0xFF0FB7A6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: SvgPicture.asset(
                              'assets/images/ic_eyeopen.svg',
                              color: Colors.white,
                            ),
                          )
                        : SvgPicture.asset("assets/images/ic_eyeclose.svg"),
                    onPressed: onTogglePassword,
                  )
                : null,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: AppColors.color_404040,
          ),
        ),
      ],
    );
  }
}
