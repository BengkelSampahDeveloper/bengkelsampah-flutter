import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../providers/points_provider.dart';
import '../widgets/custom_progressbar.dart';
import '../widgets/half_circle.dart';
import 'package:intl/intl.dart';

class PromotionVideoScreen extends StatefulWidget {
  const PromotionVideoScreen({super.key});

  @override
  State<PromotionVideoScreen> createState() => _PromotionVideoScreenState();
}

class _PromotionVideoScreenState extends State<PromotionVideoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentScreen = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _fadeController.forward();
    _slideController.forward();

    // Screen 0: Onboarding (0-3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    _transitionToScreen(1);

    // Screen 1: Home (3-7 seconds)
    await Future.delayed(const Duration(seconds: 4));
    _transitionToScreen(2);

    // Screen 2: Points (7-10 seconds)
    await Future.delayed(const Duration(seconds: 3));
    _transitionToScreen(3);

    // Screen 3: Coming Soon (10-12 seconds)
    await Future.delayed(const Duration(seconds: 2));
    _resetAnimation();
  }

  void _transitionToScreen(int screenIndex) {
    if (!_isTransitioning) {
      setState(() {
        _isTransitioning = true;
      });

      _fadeController.reverse().then((_) {
        setState(() {
          _currentScreen = screenIndex;
        });

        _fadeController.forward();
        _slideController.forward();
        _scaleController.forward();

        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isTransitioning = false;
          });
        });
      });
    }
  }

  void _resetAnimation() {
    setState(() {
      _currentScreen = 0;
    });
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _startAnimation();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 0:
        return _buildOnboardingScreen();
      case 1:
        return _buildHomeScreen();
      case 2:
        return _buildPointsScreen();
      case 3:
        return _buildComingSoonScreen();
      default:
        return _buildOnboardingScreen();
    }
  }

  Widget _buildOnboardingScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
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
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.color_FFFFFF,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_FFFFFF,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Mulai untuk menjadi penyelamat bumi!',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: AppColors.color_FFFFFF,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_FFFFFF,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.color_FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_FFFFFF,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider()..loadHomeData(),
          child: Consumer<HomeProvider>(
            builder: (context, provider, _) {
              final user = provider.user;
              final poin = user?['poin']?.toString() ?? "0";
              final setor = user?['setor']?.toString() ?? "0";
              final sampah = user?['sampah']?.toString() ?? "0";
              final xp = int.tryParse(user?['xp']?.toString() ?? "0") ?? 0;
              final nextLevelXp =
                  int.tryParse(user?['next_level_xp']?.toString() ?? "1") ?? 1;
              final nextLevel = user?['level'] ?? "-";
              final progress = nextLevelXp > 0 ? xp / nextLevelXp : 0.0;
              final xpToNext = nextLevelXp - xp;

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.26,
                        decoration:
                            const BoxDecoration(gradient: AppColors.gradient1),
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
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 42),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      "User!",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Image.asset('assets/images/ic_notif_empty.webp',
                                    height: 35),
                              ],
                            ),
                            const SizedBox(height: 33),
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: AppColors.gradient2,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            'assets/images/ic_point.svg',
                                            height: 26),
                                        const SizedBox(width: 8.5),
                                        const Text(
                                          'SampahPoin',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.color_FFFFFF,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Poin Aktif',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                color: AppColors.color_FFFFFF,
                                              ),
                                            ),
                                            Text(
                                              '$poin Poin',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.color_FFFFFF,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                                color: AppColors.color_FFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/images/ic_refresh.svg',
                                                  height: 13),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Cek Poin',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins",
                                                  color: AppColors.color_FFFFFF,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.color_FFFFFF,
                                border:
                                    Border.all(color: AppColors.color_D9D9D9),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/ic_katalog.webp',
                                              height: 44),
                                          const SizedBox(height: 8),
                                          const Text("Katalog",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.color_404040)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/ic_artikel.webp',
                                              height: 44),
                                          const SizedBox(height: 8),
                                          const Text("Artikel",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.color_404040)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/ic_bank.webp',
                                              height: 44),
                                          const SizedBox(height: 8),
                                          const Text("Bank",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.color_404040)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/ic_event.webp',
                                              height: 44),
                                          const SizedBox(height: 8),
                                          const Text("Event",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.color_404040)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.color_FFFFFF,
                                border:
                                    Border.all(color: AppColors.color_D9D9D9),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                    Image.asset("assets/images/ic_star.webp",
                                        height: 40),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$xpToNext XP jadi pahlawan $nextLevel!",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.color_404040,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            width: double.infinity,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: AppColors.color_B3B3B3,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Stack(
                                              children: [
                                                FractionallySizedBox(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  widthFactor:
                                                      progress.clamp(0.0, 1.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          AppColors.gradient1,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        size: 30,
                                        color: AppColors.color_535353),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPointsScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ChangeNotifierProvider<PointsProvider>(
          create: (_) => PointsProvider()..loadPointsData(),
          child: Consumer<PointsProvider>(
            builder: (context, provider, _) {
              final pointsData = provider.pointsData;
              final poin = pointsData?['poin']?.toString() ?? "0";
              final xp =
                  int.tryParse(pointsData?['xp']?.toString() ?? "0") ?? 0;
              final currentLevel = pointsData?['current_level'];
              final levels = pointsData?['levels'] as List<dynamic>? ?? [];

              final List<ProgressStep> steps = levels.map((level) {
                return ProgressStep(
                  title: level['nama'] ?? '',
                  xp: int.tryParse(level['xp']?.toString() ?? "0") ?? 0,
                );
              }).toList();

              return Container(
                color: AppColors.color_008B8B,
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 62),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 29,
                              width: 29,
                              decoration: BoxDecoration(
                                color: AppColors.color_FFFFFF
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Center(
                                child: Icon(Icons.chevron_left,
                                    size: 16, color: AppColors.color_FFFFFF),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "XP and Poin",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_FFFFFF,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              bottom: 0,
                              child: Image.asset(
                                  'assets/images/ic_point_left.webp',
                                  height: 100)),
                          Positioned(
                              right: 0,
                              bottom: 0,
                              child: Image.asset(
                                  'assets/images/ic_point_right.webp',
                                  height: 120)),
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: HalfCircleUp(
                                width: double.infinity,
                                height: 50,
                                color: AppColors.color_FFFFFF),
                          ),
                          Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                  child: SvgPicture.asset(
                                      'assets/images/ic_shadow_star.svg'))),
                          Positioned(
                              bottom: 22,
                              left: 0,
                              right: 0,
                              child: Center(
                                  child: Image.asset(
                                      'assets/images/ic_star.webp',
                                      height: 85))),
                        ],
                      ),
                    ),
                    Container(
                      color: AppColors.color_FFFFFF,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(
                            currentLevel?['nama'] ?? 'Pemula',
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.color_404040,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              child: Text(
                                'Total : $xp XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: AppColors.color_FFFFFF,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomProgressBar(currentXP: xp, steps: steps),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/ic_point_bg.webp'),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total poin saat ini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_FFFFFF,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          'assets/images/ic_point.svg',
                                          height: 25,
                                          width: 25),
                                      const SizedBox(width: 7),
                                      Text(
                                        "$poin Poin",
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.color_FFFFFF,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.gradient1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child:
                      Image.asset('assets/images/big_logo.webp', height: 120),
                ),
                const SizedBox(height: 40),
                const Text(
                  'COMING SOON',
                  style: TextStyle(
                    fontSize: 48,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: AppColors.color_FFFFFF,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BengkelSampah',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_FFFFFF,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mulai untuk menjadi penyelamat bumi!',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: AppColors.color_FFFFFF,
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.color_FFFFFF.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.color_FFFFFF),
                    value: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
