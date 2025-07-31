import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/screens/points_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'package:bengkelsampah_app/screens/article_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:bengkelsampah_app/providers/home_provider.dart';
import 'package:bengkelsampah_app/providers/navigation_provider.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/helpers/global_helper.dart';
import 'package:bengkelsampah_app/helpers/name_helper.dart';
import 'package:bengkelsampah_app/screens/articles_screen.dart';
import 'package:bengkelsampah_app/screens/events_screen.dart';
import 'package:bengkelsampah_app/screens/bank_sampah_screen.dart';
import 'package:bengkelsampah_app/screens/katalog_screen.dart';
import 'package:bengkelsampah_app/screens/transaksi_screen.dart';
import 'package:bengkelsampah_app/screens/pilahku_screen.dart';
import 'package:bengkelsampah_app/screens/notification_screen.dart';
import 'package:bengkelsampah_app/widgets/custom_bottom_navigation.dart';
import 'package:bengkelsampah_app/services/version_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:universal_platform/universal_platform.dart';

// Wrapper for TransaksiScreen that handles automatic refresh
class TransaksiScreenWrapper extends StatefulWidget {
  const TransaksiScreenWrapper({super.key});

  @override
  State<TransaksiScreenWrapper> createState() => _TransaksiScreenWrapperState();
}

class _TransaksiScreenWrapperState extends State<TransaksiScreenWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const TransaksiScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
          return Scaffold(
            body: IndexedStack(
              index: navigationProvider.selectedIndex,
              children: const [
                HomeContent(),
                PilahkuScreen(), // Pilahku
                TransaksiScreenWrapper(), // Riwayat with wrapper
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: CustomBottomNavigation(
              currentIndex: navigationProvider.selectedIndex,
              onItemTapped: (index) {
                navigationProvider.markScreenAsInitialized(index);
                navigationProvider.setIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final GlobalIdentifierManager _identifierManager = GlobalIdentifierManager();

  @override
  void initState() {
    super.initState();
    _identifierManager.loadIdentifier();
  }

  String _formatEventDate(String startDatetime, String endDatetime) {
    final start = DateTime.parse(startDatetime);
    final end = DateTime.parse(endDatetime);
    return '${DateFormat('dd MMMM yyyy', 'id_ID').format(start)} - ${DateFormat('dd MMMM yyyy', 'id_ID').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider()..loadHomeData(),
      child: Consumer<HomeProvider>(
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

            // Check for app version update after data is loaded
            if (provider.appVersion != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                VersionService.checkVersionAndShowDialog(
                  context,
                  provider.appVersion,
                );
              });
            }
          }

          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showErrorDialog(
                context,
                message: provider.error!,
                onRetry: provider.loadHomeData,
              );
            });
            return const SizedBox.shrink();
          }

          final user = provider.user;
          final poin = user?['poin']?.toString() ?? "0";
          final setor = user?['setor']?.toString() ?? "0";
          final sampah = user?['sampah']?.toString() ?? "0";
          final xp = int.tryParse(user?['xp']?.toString() ?? "0") ?? 0;
          final nextLevelXp =
              int.tryParse(user?['next_level_xp']?.toString() ?? "1") ?? 1;
          final nextLevel = user?['level'] ?? "-";
          final articles = provider.articles;
          final progress = nextLevelXp > 0 ? xp / nextLevelXp : 0.0;
          final xpToNext = nextLevelXp - xp;

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
                  // BEGIN: Event Carousel Section
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.35, // Kembali ke perhitungan asli
                      child: Builder(
                        builder: (context) {
                          final events = provider.events;
                          if (events.isEmpty) {
                            // Placeholder with app logo
                            return Center(
                              child: Image.asset(
                                'assets/images/big_logo.webp',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/big_logo.webp',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              CarouselSlider.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index, realIdx) {
                                  final event = events[index];
                                  final cover = (event.cover.isNotEmpty)
                                      ? event.cover
                                      : 'assets/images/big_logo.webp';
                                  final isNetwork = event.cover.isNotEmpty &&
                                      (event.cover.startsWith('http') ||
                                          event.cover.startsWith('https'));
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        isNetwork
                                            ? Image.network(
                                                cover,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                  'assets/images/big_logo.webp',
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            : Image.asset(
                                                cover,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                  'assets/images/big_logo.webp',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                        // Gradasi hitam bawah untuk teks event
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.6),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 24,
                                          right: 24,
                                          bottom: 24,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Poppins',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatEventDate(
                                                    event.startDatetime,
                                                    event.endDatetime),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height:
                                      double.infinity, // Gunakan tinggi parent
                                  viewportFraction: 1.0, // Full width
                                  enlargeCenterPage: false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 5),
                                ),
                              ),
                              // Overlay gradasi hitam dari atas screen sampai 3dp di bawah nama user (sekitar 90px)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height:
                                      90, // Atur sesuai kebutuhan, 90px dari atas
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black87,
                                        Colors.black54,
                                        Colors.transparent,
                                      ],
                                      stops: [0.0, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  ValueListenableBuilder<String>(
                                    valueListenable:
                                        _identifierManager.nameNotifier,
                                    builder: (context, name, child) {
                                      final fullName = name.isNotEmpty
                                          ? name
                                          : (user?['name']?.toString() ??
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
                                  ),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationScreen(),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      (provider.user?['unread_notifications'] ??
                                                  0) >
                                              0
                                          ? 'assets/images/ic_notif_any.png'
                                          : 'assets/images/ic_notif_empty.webp',
                                      height: 35,
                                    ),
                                    if ((provider.user?[
                                                'unread_notifications'] ??
                                            0) >
                                        0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            (provider.user?['unread_notifications'] ??
                                                        0) >
                                                    99
                                                ? '99+'
                                                : (provider.user?[
                                                            'unread_notifications'] ??
                                                        0)
                                                    .toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
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
                  // END: Event Carousel Section
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: UniversalPlatform.isWeb
                                ? MediaQuery.of(context).size.height * 0.33
                                : (MediaQuery.of(context).size.height * 0.33) -
                                    (MediaQuery.of(context).padding.top +
                                        MediaQuery.of(context).padding.bottom),
                          ),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: AppColors.gradient2,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 15, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/ic_point.svg',
                                        height: 26,
                                      ),
                                      const SizedBox(width: 8.5),
                                      const Text(
                                        'SampahPoin',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.color_FFFFFF),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            '${NumberFormatter.formatSimpleNumber(poin)} Poin',
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
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PointsScreen(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          side: const BorderSide(
                                            color: AppColors.color_FFFFFF,
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 12,
                                              right: 12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/ic_refresh.svg',
                                              height: 13,
                                            ),
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
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  RichText(
                                      text: const TextSpan(children: [
                                    TextSpan(
                                      text: 'Supported by : ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'PT. Agincourt Resources',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.color_FFFFFF,
                                      ),
                                    ),
                                  ])),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: AppColors.gradient2,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.color_008B8B.withAlpha(80),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 12, bottom: 12, left: 20, right: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/ic_total_send.svg',
                                            height: 30,
                                          ),
                                          const SizedBox(width: 8.5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Setor',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                  color: AppColors.color_FFFFFF,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                '$setor Setoran',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.color_FFFFFF,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/ic_total_trash.svg',
                                            height: 30,
                                          ),
                                          const SizedBox(width: 8.5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Sampah',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                  color: AppColors.color_FFFFFF,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                '$sampah (Unit/Kg)',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.color_FFFFFF,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.color_FFFFFF,
                                border: Border.all(
                                  color: AppColors.color_D9D9D9,
                                  width: 1,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const KatalogScreen(),
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/images/ic_katalog.webp',
                                              height: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Katalog",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.color_404040,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ArticlesScreen(),
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/images/ic_artikel.webp',
                                              height: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Artikel",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.color_404040,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BankSampahScreen(),
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/images/ic_bank.webp',
                                              height: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Bank",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.color_404040,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EventsScreen(),
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/images/ic_event.webp',
                                              height: 44,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Event",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.color_404040,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PointsScreen(),
                                ),
                              );
                            },
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.color_FFFFFF,
                                  border: Border.all(
                                    color: AppColors.color_D9D9D9,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/ic_star.webp",
                                        height: 40,
                                      ),
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
                                      )),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 30,
                                        color: AppColors.color_535353,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Text(
                                "Artikel Terbaru",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: AppColors.color_404040,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ArticlesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.color_0FB7A6
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'Lihat Semua',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.color_0FB7A6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Article List
                          ...articles.map((article) => Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailScreen(
                                            articleId: article.id,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                ),
                                                child: SizedBox(
                                                  height: 160,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    article.cover,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 160,
                                                        decoration:
                                                            const BoxDecoration(
                                                          gradient: AppColors
                                                              .gradient1,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5),
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .article_outlined,
                                                          size: 48,
                                                          color: Colors.white,
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Container(
                                                        height: 160,
                                                        decoration:
                                                            const BoxDecoration(
                                                          gradient: AppColors
                                                              .gradient1,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5),
                                                          ),
                                                        ),
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 15,
                                                left: 15,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.color_0FB7A6,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.2),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    article.category,
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article.title,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.color_404040,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .color_0FB7A6
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const Icon(
                                                        Icons.person_outline,
                                                        size: 14,
                                                        color: AppColors
                                                            .color_0FB7A6,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        article.creator,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .color_6F6F6F,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .color_0FB7A6
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const Icon(
                                                        Icons.access_time,
                                                        size: 14,
                                                        color: AppColors
                                                            .color_0FB7A6,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      DateFormat('dd MMMM yyyy',
                                                              'id_ID')
                                                          .format(
                                                        DateTime.parse(
                                                            article.createdAt),
                                                      ),
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .color_6F6F6F,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Container(
                                                  width: double.infinity,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        AppColors.gradient1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'Baca Artikel',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
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
