import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/setoran_model.dart';
import '../providers/setoran_provider.dart';
import 'package:provider/provider.dart';
import '../helpers/dialog_helper.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final int setoranId;

  const DetailTransaksiScreen({
    Key? key,
    required this.setoranId,
  }) : super(key: key);

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSetoranDetail();
    });
  }

  Future<void> _loadSetoranDetail() async {
    final provider = context.read<SetoranProvider>();

    // Check if data is already loaded
    if (provider.selectedSetoran != null &&
        provider.selectedSetoran!.id == widget.setoranId) {
      return;
    }

    // Show loading dialog
    DialogHelper.showLoadingDialog(
      context,
      message: 'Memuat detail transaksi...',
    );

    try {
      await provider.loadSetoranDetail(widget.setoranId);
    } finally {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: Consumer<SetoranProvider>(
        builder: (context, provider, _) {
          final setoran = provider.selectedSetoran;

          if (setoran == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.color_0FB7A6,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, false),
                ),
                title: const Text(
                  'Detail Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.error != null) ...[
                      Text(
                        provider.error!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.color_404040,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSetoranDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color_0FB7A6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.color_404040,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(setoran),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(setoran),
                      const SizedBox(height: 16),
                      if (setoran.status == SetoranModel.STATUS_SELESAI &&
                          setoran.tanggalSelesai != null)
                        _buildCompletionDateCard(setoran),
                      if (setoran.status == SetoranModel.STATUS_SELESAI &&
                          setoran.tanggalSelesai != null)
                        const SizedBox(height: 16),
                      _buildBankSampahCard(setoran),
                      const SizedBox(height: 16),
                      _buildAddressCard(setoran),
                      const SizedBox(height: 16),
                      if (setoran.petugasNama != null)
                        _buildPetugasCard(setoran),
                      const SizedBox(height: 16),
                      _buildItemsCard(setoran),
                      const SizedBox(height: 16),
                      _buildPhotoCard(setoran),
                      const SizedBox(height: 16),
                      _buildScheduleCard(setoran),
                      const SizedBox(height: 16),
                      _buildNotesCard(setoran),
                      const SizedBox(height: 16),
                      if (setoran.status == SetoranModel.STATUS_DIKONFIRMASI)
                        _buildCancelButton(setoran),
                      if (setoran.status == SetoranModel.STATUS_BATAL &&
                          setoran.alasanPembatalan != null)
                        _buildCancellationReasonCard(setoran),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SetoranModel setoran) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradient1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const Expanded(
                    child: Text(
                      'Detail Transaksi',
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
              const SizedBox(height: 16),
              _buildSummaryCard(setoran),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SetoranModel setoran) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            '#${setoran.id}',
            'Kode',
          ),
          _buildSummaryItem(
            DateFormat('dd MMM yyyy', 'id_ID').format(setoran.createdAt),
            'Tanggal',
          ),
          _buildSummaryPointItem(
            setoran.status == SetoranModel.STATUS_SELESAI &&
                    setoran.aktualTotal != null
                ? setoran.aktualTotal!
                : setoran.estimasiTotal,
            setoran.status == SetoranModel.STATUS_SELESAI &&
                    setoran.aktualTotal != null
                ? 'Aktual'
                : 'Estimasi',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_FFFFFF,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_FFFFFF,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPointItem(dynamic value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ic_point.svg',
                width: 15,
                height: 15,
              ),
              const SizedBox(width: 4),
              Text(
                NumberFormat('#,###').format(value),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_FFFFFF,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_FFFFFF,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(setoran.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(setoran.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(setoran.status),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTipeSetorColor(setoran.tipeSetor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTipeSetorText(setoran.tipeSetor),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: _getTipeSetorColor(setoran.tipeSetor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankSampahCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bank Sampah',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.color_666D80,
                      ),
                    ),
                    Text(
                      setoran.bankSampahName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_404040,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  setoran.bankSampahAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: AppColors.color_666D80,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.color_666D80,
              ),
              const SizedBox(width: 8),
              Text(
                setoran.bankSampahPhone,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: AppColors.color_666D80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.color_FFAB2A,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Penjemputan',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.color_666D80,
                      ),
                    ),
                    Text(
                      setoran.addressName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_404040,
                      ),
                    ),
                  ],
                ),
              ),
              if (setoran.addressIsDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_0FB7A6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            setoran.addressFullAddress,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_666D80,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.color_666D80,
              ),
              const SizedBox(width: 8),
              Text(
                setoran.addressPhone,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: AppColors.color_666D80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetugasCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petugas',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.color_666D80,
                      ),
                    ),
                    Text(
                      'Informasi Petugas',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_404040,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.color_0FB7A6.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.color_666D80,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Petugas',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: AppColors.color_666D80,
                            ),
                          ),
                          Text(
                            setoran.petugasNama!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: AppColors.color_666D80,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kontak Petugas',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: AppColors.color_666D80,
                            ),
                          ),
                          Text(
                            setoran.petugasContact!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
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
        ],
      ),
    );
  }

  Widget _buildItemsCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_40E0D0.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: AppColors.color_40E0D0,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daftar Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...setoran.itemsJson
              .map((item) => _buildItemRow(item, setoran.status))
              .toList(),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimasi:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_poin_inverse.svg',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormat('#,###').format(setoran.estimasiTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_008B8B,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (setoran.status == SetoranModel.STATUS_SELESAI &&
              setoran.aktualTotal != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Aktual:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_poin_inverse.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat('#,###').format(setoran.aktualTotal!),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: AppColors.color_008B8B,
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

  Widget _buildItemRow(Map<String, dynamic> item, String status) {
    final nama = item['sampah_nama']?.toString() ?? '';
    final estimasiBerat = (item['estimasi_berat'] as num?)?.toDouble() ?? 0.0;
    final satuan = item['sampah_satuan']?.toString() ?? '';
    final hargaPerSatuan =
        (item['harga_per_satuan'] as num?)?.toDouble() ?? 0.0;
    final totalEstimasi = estimasiBerat * hargaPerSatuan;

    // Data aktual untuk status selesai
    final aktualBerat = (item['aktual_berat'] as num?)?.toDouble();
    final totalAktual = (item['aktual_total'] as num?)?.toDouble();
    final itemStatus = item['status']?.toString() ?? '';

    // Tentukan apakah item dihapus atau ditambah
    final isDeleted = itemStatus == 'dihapus';
    final isAdded = itemStatus == 'ditambah';
    final isCompleted = status == SetoranModel.STATUS_SELESAI;

    // Warna dan opacity berdasarkan status
    final textColor =
        isDeleted ? AppColors.color_666D80 : AppColors.color_404040;
    final opacity = isDeleted ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDeleted ? AppColors.color_F8FAFB : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isAdded
                ? Border.all(color: AppColors.color_0FB7A6, width: 2)
                : isDeleted
                    ? Border.all(
                        color: AppColors.color_666D80.withValues(alpha: 0.3),
                        width: 1)
                    : Border.all(color: AppColors.color_DFE1E7, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan nama sampah dan status badge
              Row(
                children: [
                  // Status badge
                  if (isCompleted && (isDeleted || isAdded))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isDeleted
                            ? AppColors.color_F44336.withValues(alpha: 0.1)
                            : AppColors.color_0FB7A6.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDeleted
                              ? AppColors.color_F44336
                              : AppColors.color_0FB7A6,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDeleted
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            size: 14,
                            color: isDeleted
                                ? AppColors.color_F44336
                                : AppColors.color_0FB7A6,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDeleted ? 'Dihapus' : 'Ditambah',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: isDeleted
                                  ? AppColors.color_F44336
                                  : AppColors.color_0FB7A6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      nama,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Harga per satuan
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_poin_inverse.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat('#,###').format(hargaPerSatuan),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_0FB7A6,
                          ),
                        ),
                        Text(
                          '/ $satuan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: AppColors.color_666D80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Data estimasi dan aktual dalam card terpisah
              Row(
                children: [
                  // Estimasi Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.color_F8FAFB,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.color_DFE1E7,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                size: 16,
                                color: AppColors.color_666D80,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Estimasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.color_666D80,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${estimasiBerat.toStringAsFixed(1)} $satuan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/images/ic_poin_inverse.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                NumberFormat('#,###').format(totalEstimasi),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.color_0FB7A6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Aktual Card (hanya tampil jika status selesai dan ada data aktual)
                  if (isCompleted && aktualBerat != null && aktualBerat > 0)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.color_008B8B.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppColors.color_008B8B.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.color_008B8B,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Aktual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.color_008B8B,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${aktualBerat.toStringAsFixed(1)} $satuan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_404040,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_poin_inverse.svg',
                                  width: 14,
                                  height: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  NumberFormat('#,###')
                                      .format(totalAktual ?? 0),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.color_008B8B,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isCompleted)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.color_F8FAFB,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.color_DFE1E7,
                            width: 1,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.color_666D80,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Aktual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.color_666D80,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_666D80,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_666D80,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Selisih (hanya tampil jika ada data aktual)
              if (isCompleted && aktualBerat != null && aktualBerat > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.color_FFAB2A.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.compare_arrows,
                          size: 16,
                          color: AppColors.color_FFAB2A,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selisih: ${(aktualBerat - estimasiBerat).toStringAsFixed(1)} $satuan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_FFAB2A,
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

  Widget _buildPhotoCard(SetoranModel setoran) {
    if (setoran.fotoSampah == null || setoran.fotoSampah!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_F44336.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: AppColors.color_F44336,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Foto Sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              setoran.fotoSampah!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.color_F8FAFB,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.color_666D80,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(SetoranModel setoran) {
    if (setoran.tanggalPenjemputan == null &&
        setoran.waktuPenjemputan == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FA39A.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.color_0FA39A,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Jadwal Penjemputan',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (setoran.tanggalPenjemputan != null)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.color_666D80,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                      .format(setoran.tanggalPenjemputan!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: AppColors.color_666D80,
                  ),
                ),
              ],
            ),
          if (setoran.waktuPenjemputan != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.color_666D80,
                ),
                const SizedBox(width: 8),
                Text(
                  setoran.waktuPenjemputan!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: AppColors.color_666D80,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(SetoranModel setoran) {
    if (setoran.notes == null || setoran.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            setoran.notes!,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_666D80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_F44336.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.color_F44336,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Batalkan Setoran',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Anda dapat membatalkan setoran ini karena masih dalam status dikonfirmasi.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_666D80,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showCancelDialog(setoran),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color_F44336,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Batalkan Setoran',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(SetoranModel setoran) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Batalkan Setoran',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin membatalkan setoran ini?',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alasan Pembatalan:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: alasanController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan pembatalan...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.color_666D80),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (alasanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan pembatalan harus diisi'),
                    backgroundColor: AppColors.color_F44336,
                  ),
                );
                return;
              }

              Navigator.pop(context, false);
              await _cancelSetoran(setoran.id, alasanController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color_F44336,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSetoran(int setoranId, String alasanPembatalan) async {
    DialogHelper.showLoadingDialog(
      context,
      message: 'Membatalkan setoran...',
    );

    try {
      final provider = context.read<SetoranProvider>();
      final result = await provider.cancelSetoran(setoranId, alasanPembatalan);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (result['success'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.color_0FB7A6,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Setoran Berhasil Dibatalkan!',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Setoran telah dibatalkan dan status telah diperbarui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: AppColors.color_6F6F6F,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(
                        context, true); // Return true to indicate changes
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: AppColors.color_0FB7A6),
                  ),
                ),
              ],
            ),
          );
        }
        // Only refresh if there are changes (result is true)
        if (result == true) {
          final provider = context.read<SetoranProvider>();
          provider.smartRefresh();
        }
      } else {
        if (mounted) {
          DialogHelper.showErrorDialog(
            context,
            message: result['message'] ??
                'Terjadi kesalahan saat membatalkan setoran',
            onRetry: () => _cancelSetoran(setoranId, alasanPembatalan),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        DialogHelper.showErrorDialog(
          context,
          message: 'Terjadi kesalahan: ${e.toString()}',
          onRetry: () => _cancelSetoran(setoranId, alasanPembatalan),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SetoranModel.STATUS_DIKONFIRMASI:
        return AppColors.color_0FB7A6;
      case SetoranModel.STATUS_DIPROSES:
        return AppColors.color_FFAB2A;
      case SetoranModel.STATUS_DIJEMPUT:
        return AppColors.color_0FA39A;
      case SetoranModel.STATUS_SELESAI:
        return AppColors.color_0FB7A6;
      case SetoranModel.STATUS_BATAL:
        return AppColors.color_F44336;
      default:
        return AppColors.color_666D80;
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
        return status;
    }
  }

  Color _getTipeSetorColor(String tipeSetor) {
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

  String _getTipeSetorText(String tipeSetor) {
    switch (tipeSetor) {
      case SetoranModel.TIPE_JUAL:
        return 'Jual';
      case SetoranModel.TIPE_SEDEKAH:
        return 'Sedekah';
      case SetoranModel.TIPE_TABUNG:
        return 'Tabung';
      default:
        return tipeSetor;
    }
  }

  Widget _buildCancellationReasonCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Alasan Pembatalan',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            setoran.alasanPembatalan!,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_666D80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionDateCard(SetoranModel setoran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tanggal Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                .format(setoran.tanggalSelesai!),
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_666D80,
            ),
          ),
        ],
      ),
    );
  }
}
