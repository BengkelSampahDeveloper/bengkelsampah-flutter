import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/widgets/custom_progressbar.dart';
import 'package:bengkelsampah_app/widgets/half_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/points_provider.dart';
import '../helpers/dialog_helper.dart';
import '../helpers/global_helper.dart';
import '../models/point_history_model.dart';
import 'package:intl/intl.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasShownLoadingDialog = false;
  bool _hasShownErrorDialog = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    try {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<PointsProvider>();
        if (provider.hasMoreHistory && !provider.isLoadingHistory) {
          provider.loadMoreHistory();
        }
      }
    } catch (e) {
      // Handle scroll error silently to prevent crashes
      debugPrint('Scroll error: $e');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    if (!_hasShownLoadingDialog) {
      _hasShownLoadingDialog = true;
      DialogHelper.showLoadingDialog(context, message: 'Memuat data...');
    }
  }

  void _hideLoadingDialog(BuildContext context) {
    if (_hasShownLoadingDialog) {
      _hasShownLoadingDialog = false;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _showErrorDialog(
      BuildContext context, String error, VoidCallback onRetry) {
    if (!_hasShownErrorDialog) {
      _hasShownErrorDialog = true;
      DialogHelper.showErrorDialog(
        context,
        message: error,
        onRetry: () {
          _hasShownErrorDialog = false;
          onRetry();
        },
      );
    }
  }

  void _resetDialogStates() {
    _hasShownLoadingDialog = false;
    _hasShownErrorDialog = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      floatingActionButton: Container(
        width: 120,
        height: 35,
        child: FloatingActionButton(
          onPressed: () async {
            final Uri url = Uri.parse(
                'https://wa.me/6282168231808?text=Halo%2C%20saya%20ingin%20bertanya%20terkait%20Bengkel%20Sampah.');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat membuka link WhatsApp'),
                    backgroundColor: AppColors.color_FFAB2A,
                  ),
                );
              }
            }
          },
          backgroundColor: AppColors.color_0FB7A6,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat,
                color: AppColors.color_FFFFFF,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                'Tukar poin',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_FFFFFF,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ChangeNotifierProvider<PointsProvider>(
        create: (_) {
          final provider = PointsProvider();
          // Delay the initial load to prevent immediate crash
          Future.delayed(const Duration(milliseconds: 100), () {
            provider.loadPointsData(refresh: true);
          });
          return provider;
        },
        child: Consumer<PointsProvider>(
          builder: (context, provider, _) {
            try {
              // Handle loading state with dialog
              if (provider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    _showLoadingDialog(context);
                  } catch (e) {
                    debugPrint('Error showing loading dialog: $e');
                  }
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    _hideLoadingDialog(context);
                  } catch (e) {
                    debugPrint('Error hiding loading dialog: $e');
                  }
                });
              }

              // Handle error state with dialog
              if (provider.error != null && !provider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    _showErrorDialog(context, provider.error!, () {
                      _resetDialogStates();
                      provider.clearError();
                      provider.loadPointsData(refresh: true);
                    });
                  } catch (e) {
                    debugPrint('Error showing error dialog: $e');
                  }
                });
              }

              // Always show the page with data (or empty values if no data)
              final pointsData = provider.pointsData;

              // Use empty values if data is null or loading
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

              // Find next level XP and name
              int nextLevelXp = 0;
              String? nextLevelName;
              for (var level in levels) {
                final levelXp =
                    int.tryParse(level['xp']?.toString() ?? "0") ?? 0;
                if (levelXp > xp) {
                  nextLevelXp = levelXp;
                  nextLevelName = level['nama'];
                  break;
                }
              }

              return RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppColors.color_0FB7A6,
                  child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                          color: AppColors.color_008B8B,
                          width: double.infinity,
                          child: Column(
                            children: [
                              const SizedBox(height: 62),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 26),
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                            height: 29,
                                            width: 29,
                                            decoration: BoxDecoration(
                                              color: AppColors.color_FFFFFF
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.chevron_left,
                                                size: 16,
                                                color: AppColors.color_FFFFFF,
                                              ),
                                            )),
                                      ),
                                    ),
                                    const Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 29,
                                          child: Center(
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
                                        )),
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
                                            height: 100,
                                          )),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Image.asset(
                                          'assets/images/ic_point_right.webp',
                                          height: 120,
                                        ),
                                      ),
                                      const Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: HalfCircleUp(
                                            width: double.infinity,
                                            height: 50,
                                            color: AppColors.color_FFFFFF,
                                          )),
                                      Positioned(
                                          bottom: 20,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: SvgPicture.asset(
                                                'assets/images/ic_shadow_star.svg'),
                                          )),
                                      Positioned(
                                        bottom: 22,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/ic_star.webp',
                                            height: 85,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                  color: AppColors.color_FFFFFF,
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              'Total : $xp XP',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                color: AppColors.color_FFFFFF,
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 12),
                                      CustomProgressBar(
                                        currentXP: xp,
                                        steps: steps,
                                      ),
                                      const SizedBox(height: 15),
                                      if (nextLevelXp > 0)
                                        Text(
                                          '${nextLevelXp - xp} XP lagi untuk jadi pahlawan $nextLevelName!',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            color: AppColors.color_404040,
                                          ),
                                        ),
                                      const SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30),
                                        child: Container(
                                          height: 1,
                                          color: AppColors.color_D9D9D9,
                                        ),
                                      ),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Total poin saat ini',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Poppins',
                                                    color:
                                                        AppColors.color_FFFFFF,
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      height: 25,
                                                      width: 25,
                                                      'assets/images/ic_point.svg',
                                                    ),
                                                    const SizedBox(width: 7),
                                                    Text(
                                                      "${NumberFormatter.formatNumber(poin)} Poin",
                                                      style: const TextStyle(
                                                        fontSize: 26,
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .color_FFFFFF,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )),
                                      // Point History Section
                                      _buildPointHistorySection(provider),
                                      const SizedBox(height: 20),
                                    ],
                                  ))
                            ],
                          ))));
            } catch (e) {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPointHistorySection(PointsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.pointHistory.isEmpty && !provider.isLoadingHistory)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.color_F3F3F3,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 60,
                      color: AppColors.color_B3B3B3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada riwayat poin',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: AppColors.color_6F6F6F,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.pointHistory.length +
                (provider.isLoadingHistory ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.pointHistory.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.color_0FB7A6,
                    ),
                  ),
                );
              }

              try {
                final history = provider.pointHistory[index];
                return _buildHistoryItem(history);
              } catch (e) {
                return const SizedBox.shrink();
              }
            },
          ),
      ],
    );
  }

  Widget _buildHistoryItem(PointHistoryModel history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.color_404040.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: history.isFromDeposit
                  ? AppColors.color_0FB7A6.withValues(alpha: 0.1)
                  : AppColors.color_FFAB2A.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              history.isFromDeposit ? Icons.add_circle : Icons.remove_circle,
              color: history.isFromDeposit
                  ? AppColors.color_0FB7A6
                  : AppColors.color_FFAB2A,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.typeDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  history.keteranganDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_6F6F6F,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(history.tanggal),
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    color: AppColors.color_B3B3B3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_point.svg',
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormatter.formatNumber(history.jumlahPoint),
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: history.isFromDeposit
                          ? AppColors.color_0FB7A6
                          : AppColors.color_FFAB2A,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${history.xp} XP',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppColors.color_6F6F6F,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
