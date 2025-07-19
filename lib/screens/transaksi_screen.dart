import 'package:flutter/material.dart';
import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/setoran_provider.dart';
import '../models/setoran_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'detail_transaksi_screen.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<String> _statusTabs = [
    SetoranModel.STATUS_DIKONFIRMASI,
    SetoranModel.STATUS_DIPROSES,
    SetoranModel.STATUS_DIJEMPUT,
    SetoranModel.STATUS_SELESAI,
    SetoranModel.STATUS_BATAL,
  ];

  bool _isScreenVisible = false;
  bool _hasInitialized = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Load data only once on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _loadData();
        _hasInitialized = true;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Only refresh when app resumes and screen is visible
    if (state == AppLifecycleState.resumed &&
        _isScreenVisible &&
        !_isRefreshing) {
      final provider = context.read<SetoranProvider>();
      // Use smart refresh instead of always refreshing
      provider.smartRefresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove automatic refresh on dependencies change
    // This was causing multiple API calls
  }

  void _loadData() {
    if (mounted && !_isRefreshing) {
      _isRefreshing = true;
      final provider = context.read<SetoranProvider>();
      // Use smart refresh for initial load
      provider.smartRefresh().then((_) {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mark screen as visible when building
    _isScreenVisible = true;

    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: Column(
        children: [
          // Header - Updated to match pilahku design
          _buildHeader(),
          // TabBar
          Container(
            color: AppColors.color_F8FAFB,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.color_0FB7A6,
              labelColor: AppColors.color_0FB7A6,
              unselectedLabelColor: AppColors.color_666D80,
              tabs: const [
                Tab(text: 'Dikonfirmasi'),
                Tab(text: 'Diproses'),
                Tab(text: 'Dijemput'),
                Tab(text: 'Selesai'),
                Tab(text: 'Batal'),
              ],
              onTap: (index) {
                // Remove setState to prevent unnecessary rebuilds
                // setState(() {});
              },
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((status) {
                return Consumer<SetoranProvider>(
                  builder: (context, provider, _) {
                    // Filter setorans by current tab status
                    final filtered = provider.setorans
                        .where((setoran) => setoran.status == status)
                        .toList();

                    if (provider.isLoading && provider.setorans.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          try {
                            final provider = context.read<SetoranProvider>();
                            await provider.pullToRefresh();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Gagal memperbarui data: ${e.toString()}'),
                                  backgroundColor: AppColors.color_F44336,
                                ),
                              );
                            }
                          }
                        },
                        color: AppColors.color_0FB7A6,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.color_0FB7A6,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (provider.error != null && provider.setorans.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          try {
                            final provider = context.read<SetoranProvider>();
                            await provider.pullToRefresh();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Gagal memperbarui data: ${e.toString()}'),
                                  backgroundColor: AppColors.color_F44336,
                                ),
                              );
                            }
                          }
                        },
                        color: AppColors.color_0FB7A6,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_error.svg',
                                    width: 64,
                                    height: 64,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.color_666D80,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.color_666D80,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      final provider =
                                          context.read<SetoranProvider>();
                                      provider.pullToRefresh();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.color_0FB7A6,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          try {
                            final provider = context.read<SetoranProvider>();
                            await provider.pullToRefresh();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Gagal memperbarui data: ${e.toString()}'),
                                  backgroundColor: AppColors.color_F44336,
                                ),
                              );
                            }
                          }
                        },
                        color: AppColors.color_0FB7A6,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        try {
                          final provider = context.read<SetoranProvider>();
                          await provider.pullToRefresh();
                        } catch (e) {
                          // Show snackbar for refresh error
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Gagal memperbarui data: ${e.toString()}'),
                                backgroundColor: AppColors.color_F44336,
                              ),
                            );
                          }
                        }
                      },
                      color: AppColors.color_0FB7A6,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final setoran = filtered[index];
                          return _buildSetoranCard(setoran);
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradient1),
      child: const SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Riwayat Setoran',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_FFFFFF,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 60,
              color: AppColors.color_0FB7A6.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada riwayat setoran',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Setoran Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_666D80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetoranCard(SetoranModel setoran) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final formattedDate = dateFormat.format(setoran.createdAt);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransaksiScreen(
              setoranId: setoran.id,
            ),
          ),
        );

        // Only refresh if there are changes (result is true)
        if (result == true) {
          final provider = context.read<SetoranProvider>();
          provider.smartRefresh();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.color_FFFFFF,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with bank name and status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.color_0FB7A6.withValues(alpha: 0.1),
                    AppColors.color_40E0D0.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setoran.bankSampahName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.color_404040,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.color_666D80,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(setoran.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(setoran.status)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusText(setoran.status),
                          style: TextStyle(
                            color: _getStatusColor(setoran.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _tipeSetorColor(setoran.tipeSetor)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _tipeSetorColor(setoran.tipeSetor)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          setoran.tipeSetorText,
                          style: TextStyle(
                            color: _tipeSetorColor(setoran.tipeSetor),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items list with horizontal scroll
            if (setoran.itemsJson.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Sampah (${setoran.itemsJson.length} item)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.color_404040,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Estimasi: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColors.color_666D80,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/ic_poin_inverse.svg',
                                    width: 12,
                                    height: 12,
                                  ),
                                  Text(
                                    NumberFormat('#,###')
                                        .format(setoran.estimasiTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.color_0FB7A6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Text(
                                    'Aktual: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColors.color_666D80,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/ic_poin_inverse.svg',
                                    width: 12,
                                    height: 12,
                                  ),
                                  Text(
                                    setoran.aktualTotal != null
                                        ? NumberFormat('#,###')
                                            .format(setoran.aktualTotal!)
                                        : '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: setoran.aktualTotal != null
                                          ? AppColors.color_008B8B
                                          : AppColors.color_666D80,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: setoran.itemsJson.length,
                        itemBuilder: (context, index) {
                          final item = setoran.itemsJson[index];
                          return _buildItemCard(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Footer with additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.color_F8FAFB,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.color_666D80,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          setoran.addressFullAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.color_666D80,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final nama = item['sampah_nama']?.toString() ?? 'Unknown';
    final estimasiBerat = (item['estimasi_berat'] ?? 0.0).toDouble();
    final aktualBerat = (item['aktual_berat'] ?? 0.0).toDouble();
    final hargaPerSatuan = (item['harga_per_satuan'] ?? 0.0).toDouble();
    final satuan = item['sampah_satuan']?.toString() ?? 'KG';
    final totalEstimasi = estimasiBerat * hargaPerSatuan;
    final totalAktual = aktualBerat * hargaPerSatuan;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.color_E9E9E9,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              nama,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.color_404040,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/ic_poin_inverse.svg',
                width: 12,
                height: 12,
              ),
              Text(
                '${NumberFormat('#,###').format(hargaPerSatuan)}/$satuan',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.color_666D80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Estimasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_0FB7A6,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${estimasiBerat.toStringAsFixed(1)} $satuan',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.color_666D80,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/images/ic_poin_inverse.svg',
                      width: 12,
                      height: 12,
                    ),
                    Text(
                      NumberFormat('#,###').format(totalEstimasi),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.color_0FB7A6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Aktual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.color_008B8B.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktual',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_008B8B,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      aktualBerat > 0
                          ? '${aktualBerat.toStringAsFixed(1)} $satuan'
                          : '-',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.color_666D80,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/images/ic_poin_inverse.svg',
                      width: 12,
                      height: 12,
                    ),
                    Text(
                      totalAktual > 0
                          ? NumberFormat('#,###').format(totalAktual)
                          : '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: totalAktual > 0
                            ? AppColors.color_008B8B
                            : AppColors.color_666D80,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tipeSetorColor(String tipeSetor) {
    switch (tipeSetor) {
      case SetoranModel.TIPE_JUAL:
        return AppColors.color_0FB7A6;
      case SetoranModel.TIPE_SEDEKAH:
        return AppColors.color_FFAB2A;
      case SetoranModel.TIPE_TABUNG:
        return AppColors.color_40E0D0;
      default:
        return AppColors.color_B3B3B3;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SetoranModel.STATUS_DIKONFIRMASI:
        return AppColors.color_0FB7A6;
      case SetoranModel.STATUS_DIPROSES:
        return AppColors.color_FFAB2A;
      case SetoranModel.STATUS_DIJEMPUT:
        return AppColors.color_40E0D0;
      case SetoranModel.STATUS_SELESAI:
        return AppColors.color_008B8B;
      case SetoranModel.STATUS_BATAL:
        return AppColors.color_F44336;
      default:
        return AppColors.color_B3B3B3;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case SetoranModel.STATUS_DIKONFIRMASI:
        return 'Dikonfirmasi';
      case SetoranModel.STATUS_DIPROSES:
        return 'Diproses';
      case SetoranModel.STATUS_DIJEMPUT:
        return 'Dijemput';
      case SetoranModel.STATUS_SELESAI:
        return 'Selesai';
      case SetoranModel.STATUS_BATAL:
        return 'Batal';
      default:
        return 'Unknown';
    }
  }
}
