import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/katalog_detail_provider.dart';
import '../helpers/dialog_helper.dart';
import '../models/sampah_detail_model.dart';
import '../providers/pilahku_provider.dart';
import '../screens/add_to_pilahku_screen.dart';

class KatalogDetailScreen extends StatefulWidget {
  final int sampahId;

  const KatalogDetailScreen({
    Key? key,
    required this.sampahId,
  }) : super(key: key);

  @override
  State<KatalogDetailScreen> createState() => _KatalogDetailScreenState();
}

class _KatalogDetailScreenState extends State<KatalogDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bottomSheetAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KatalogDetailProvider>().loadSampahDetail(widget.sampahId);
    });
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    super.dispose();
  }

  void _toggleBottomSheet() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _bottomSheetController.forward();
      } else {
        _bottomSheetController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_0FB7A6,
      body: Consumer<KatalogDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedSampah == null) {
            return Container(
              decoration: const BoxDecoration(gradient: AppColors.gradient1),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.color_FFFFFF,
                ),
              ),
            );
          }

          if (provider.error != null && provider.selectedSampah == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showErrorDialog(
                context,
                message: provider.error!,
                onRetry: () async {
                  DialogHelper.showLoadingDialog(context,
                      message: 'Memuat detail...');
                  await provider.loadSampahDetail(widget.sampahId);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            });
            return const SizedBox.shrink();
          }

          final sampah = provider.selectedSampah;
          if (sampah == null) {
            return const Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(color: AppColors.color_FFFFFF),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(gradient: AppColors.gradient1),
            child: Stack(
              children: [
                // Background and Image Section
                Column(
                  children: [
                    // Header with Back Button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                  height: 29,
                                  width: 29,
                                  decoration: BoxDecoration(
                                    color: AppColors.color_FFFFFF
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.chevron_left,
                                      size: 16,
                                      color: AppColors.color_FFFFFF,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Image Section
                    AnimatedBuilder(
                      animation: _bottomSheetAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40 + (_bottomSheetAnimation.value * 40),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 250 - (_bottomSheetAnimation.value * 200),
                            child: sampah.gambar != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      sampah.gambar!,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.color_FFFFFF,
                                          size: 60,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.color_FFFFFF,
                                    size: 60,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Bottom Sheet
                AnimatedBuilder(
                  animation: _bottomSheetAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Pilahku Button - Above Bottom Sheet
                        Positioned(
                          right: 8,
                          top: MediaQuery.of(context).size.height *
                                  (0.5 - (_bottomSheetAnimation.value * 0.3)) -
                              60,
                          child: Consumer<PilahkuProvider>(
                            builder: (context, pilahkuProvider, _) {
                              final isInPilahku =
                                  pilahkuProvider.isItemInPilahku(
                                sampah.id,
                                provider.prices.isNotEmpty
                                    ? provider.prices.first.bankSampahId
                                    : '',
                              );

                              return TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.color_FFFFFF,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: isInPilahku
                                              ? AppColors.color_6F6F6F
                                              : AppColors.color_0FB7A6,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddToPilahkuScreen(
                                                  sampahId: widget.sampahId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Animated Icon
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  child: Icon(
                                                    key: ValueKey(isInPilahku),
                                                    isInPilahku
                                                        ? Icons.check_circle
                                                        : Icons
                                                            .add_shopping_cart,
                                                    size: 18,
                                                    color: isInPilahku
                                                        ? AppColors.color_6F6F6F
                                                        : AppColors
                                                            .color_0FB7A6,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Animated Text
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  child: Text(
                                                    key: ValueKey(isInPilahku),
                                                    isInPilahku
                                                        ? 'Sudah'
                                                        : 'Pilah',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isInPilahku
                                                          ? AppColors
                                                              .color_6F6F6F
                                                          : AppColors
                                                              .color_0FB7A6,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Bottom Sheet Content
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: MediaQuery.of(context).size.height *
                              (0.5 - (_bottomSheetAnimation.value * 0.3)),
                          child: GestureDetector(
                            onTap: _toggleBottomSheet,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.color_FFFFFF,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Handle for bottom sheet
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.color_E9E9E9,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),

                                  // Content
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name
                                          Text(
                                            sampah.nama,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.color_404040,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          // Description
                                          Text(
                                            sampah.deskripsi,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.color_6F6F6F,
                                              height: 1.6,
                                            ),
                                          ),

                                          const SizedBox(height: 32),

                                          // Improved Section Header
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.color_F8FAFB,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.color_E9E9E9,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Title
                                                const Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Harga di Berbagai Cabang',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors
                                                              .color_404040,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'Pilih cabang terdekat untuk harga terbaik',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .color_6F6F6F,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Branch Count Badge
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        AppColors.gradient1,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .color_0FB7A6
                                                            .withValues(
                                                                alpha: 0.2),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    '${provider.prices.length} Cabang',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .color_FFFFFF,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 16),
                                          ...provider.prices
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final price = entry.value;
                                            // Find the highest price to mark as "best"
                                            final maxPrice = provider.prices
                                                .map((p) => p.harga)
                                                .reduce(
                                                    (a, b) => a > b ? a : b);
                                            final isBestPrice =
                                                price.harga == maxPrice;
                                            return _buildImprovedPriceCard(
                                                price,
                                                index,
                                                sampah.satuan,
                                                isBestPrice);
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImprovedPriceCard(
      PriceModel price, int index, String satuan, bool isBestPrice) {
    final sampah = context.read<KatalogDetailProvider>().selectedSampah;
    if (sampah == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Optional: Add tap functionality for future features
            // Could show branch details, directions, or contact info
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.color_FFFFFF,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isBestPrice
                        ? AppColors.color_0FB7A6
                        : AppColors.color_E9E9E9,
                    width: isBestPrice ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isBestPrice
                          ? AppColors.color_0FB7A6.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Branch Icon/Indicator with subtle animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient1,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.color_0FB7A6.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.color_FFFFFF,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price.bankSampahNama,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Service Type Indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: price.tipeLayananColor
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: price.tipeLayananColor
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: price.tipeLayananColor
                                      .withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  price.tipeLayananIcon,
                                  size: 10,
                                  color: price.tipeLayananColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  price.tipeLayananDisplay,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: price.tipeLayananColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Price Section with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient1,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.color_0FB7A6.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Point Icon
                          SvgPicture.asset(
                            'assets/images/ic_point.svg',
                            width: 11,
                            height: 11,
                          ),

                          const SizedBox(width: 6),

                          // Price Text
                          Text(
                            '${price.harga.toInt()} / $satuan',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: AppColors.color_FFFFFF,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Best Price Badge
              if (isBestPrice)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.color_FFAB2A,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.color_FFAB2A.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.color_FFFFFF,
                          size: 10,
                        ),
                        Text(
                          'Terbaik',
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_FFFFFF,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
