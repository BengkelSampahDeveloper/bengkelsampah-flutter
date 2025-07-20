import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/helpers/global_helper.dart';
import 'package:bengkelsampah_app/helpers/name_helper.dart';
import 'package:bengkelsampah_app/providers/profile_provider.dart';
import 'package:bengkelsampah_app/screens/about_screen.dart';
import 'package:bengkelsampah_app/screens/profile_security_screen.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';
import 'points_screen.dart';
import 'profile_settings_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalIdentifierManager _identifierManager = GlobalIdentifierManager();

  @override
  void initState() {
    super.initState();
    _identifierManager.loadIdentifier();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider()..loadProfileData(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          // Show loading dialog if loading
          if (provider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showLoadingDialog(context,
                  message: 'Memuat data...');
            });
          } else {
            // Dismiss loading dialog if not loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
          }

          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showErrorDialog(
                context,
                message: provider.error!,
                onRetry: provider.loadProfileData,
              );
            });
            return const SizedBox.shrink();
          }

          final profileData = provider.profileData;
          final level = profileData?['level'] ?? "-";
          final poin = profileData?['poin']?.toString() ?? "0";

          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.refresh(),
                _identifierManager.loadIdentifier(),
              ]);
            },
            color: AppColors.color_0FB7A6,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 190,
                      decoration: const BoxDecoration(
                        gradient: AppColors.gradient1,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/ic_home_bg.webp',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 190,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient4,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 42),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: ValueListenableBuilder<String>(
                                  valueListenable:
                                      _identifierManager.nameNotifier,
                                  builder: (context, name, child) {
                                    final fullName = name.isNotEmpty
                                        ? name
                                        : (profileData?['nama']?.toString() ??
                                            "User");
                                    final truncatedName =
                                        NameHelper.truncateName(fullName);
                                    return Text(
                                      "$truncatedName!",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    );
                                  },
                                )),
                            const SizedBox(height: 3),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: ValueListenableBuilder<String>(
                                valueListenable:
                                    _identifierManager.identifierNotifier,
                                builder: (context, identifier, child) {
                                  final displayIdentifier =
                                      identifier.isNotEmpty
                                          ? identifier
                                          : (profileData?['identifier'] ?? "-");
                                  return Text(
                                    displayIdentifier,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_FFFFFF,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 33),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: AppColors.gradient2,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_star.webp',
                                          height: 30,
                                          width: 30,
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PointsScreen(),
                                              ),
                                            );
                                          },
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(level,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .color_FFFFFF,
                                                    )),
                                                const Text('Lihat Peringkat',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Poppins',
                                                      color: AppColors
                                                          .color_FFFFFF,
                                                    ))
                                              ]),
                                        )
                                      ]),
                                  const SizedBox(width: 20),
                                  Container(
                                    width: 1,
                                    height: 55,
                                    color: AppColors.color_FFFFFF,
                                  ),
                                  const SizedBox(width: 20),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/ic_point.svg',
                                          height: 30,
                                          width: 30,
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PointsScreen(),
                                              ),
                                            );
                                          },
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    NumberFormatter
                                                        .formatSimpleNumber(
                                                            poin),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .color_FFFFFF,
                                                    )),
                                                const Text('Lihat Poin',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Poppins',
                                                      color: AppColors
                                                          .color_FFFFFF,
                                                    ))
                                              ]),
                                        )
                                      ])
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Pengaturan Aplikasi",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: AppColors.color_535353,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          color: AppColors.color_FFFFFF,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileSettingsScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Pengaturan Profile',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 25,
                                            color: AppColors.color_535353,
                                          )
                                        ],
                                      ),
                                    )),
                                Container(
                                  color: AppColors.color_D9D9D9,
                                  height: 2,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileSecurityScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Pengaturan Keamanan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 25,
                                            color: AppColors.color_535353,
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Informasi Umum",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: AppColors.color_535353,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          color: AppColors.color_FFFFFF,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AboutScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Tentang Kami',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 25,
                                            color: AppColors.color_535353,
                                          )
                                        ],
                                      ),
                                    )),
                                Container(
                                  color: AppColors.color_D9D9D9,
                                  height: 2,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsConditionsScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Syarat & Ketentuan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 25,
                                            color: AppColors.color_535353,
                                          )
                                        ],
                                      ),
                                    )),
                                Container(
                                  color: AppColors.color_D9D9D9,
                                  height: 2,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacyPolicyScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Kebijakan Privasi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 25,
                                            color: AppColors.color_535353,
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 70),
                        const Center(
                          child: Text(
                            'Versi Aplikasi 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: AppColors.color_B3B3B3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: OutlinePrimaryButton(
                            text: "Logout",
                            onPressed: () async {
                              await authProvider.logout();
                              if (!context.mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const OnboardingScreen()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: OutlineRedButton(
                            text: "Delete Account",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Hapus Akun',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.color_404040,
                                    ),
                                  ),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan dan semua data Anda akan dihapus secara permanen.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_535353,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Batal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          color: AppColors.color_535353,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (!context.mounted) return;

                                        // Show loading
                                        DialogHelper.showLoadingDialog(
                                          context,
                                          message: 'Menghapus akun...',
                                        );

                                        try {
                                          // Delete account
                                          final success = await authProvider
                                              .deleteAccount();

                                          if (!context.mounted) return;

                                          // Close loading dialog
                                          Navigator.pop(context);

                                          if (success) {
                                            // Navigate ke onboarding
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const OnboardingScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            // Show error
                                            DialogHelper.showErrorDialog(
                                              context,
                                              message: authProvider.error ??
                                                  'Gagal menghapus akun',
                                            );
                                          }
                                        } catch (e) {
                                          if (!context.mounted) return;

                                          // Close loading dialog
                                          Navigator.pop(context);

                                          DialogHelper.showErrorDialog(
                                            context,
                                            message: 'Terjadi kesalahan: $e',
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          color: AppColors.color_F44336,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
