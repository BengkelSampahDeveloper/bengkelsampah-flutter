import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../providers/pilahku_provider.dart';
import '../providers/katalog_detail_provider.dart';
import '../models/pilahku_model.dart';
import '../models/sampah_detail_model.dart';
import '../helpers/dialog_helper.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_text_field.dart';

class AddToPilahkuScreen extends StatefulWidget {
  final int sampahId;

  const AddToPilahkuScreen({
    Key? key,
    required this.sampahId,
  }) : super(key: key);

  @override
  State<AddToPilahkuScreen> createState() => _AddToPilahkuScreenState();
}

class _AddToPilahkuScreenState extends State<AddToPilahkuScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? _selectedBranchId;
  String? _selectedBranchName;
  String? _selectedTipeLayanan;
  double? _selectedPrice;
  bool _isLoading = false;
  bool _showWeightError = false;
  bool _showBranchError = false;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(() {
      setState(() {
        if (_showWeightError && _weightController.text.isNotEmpty) {
          _showWeightError = false;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KatalogDetailProvider>().loadSampahDetail(widget.sampahId);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.color_F8FAFB,
      body: Consumer2<KatalogDetailProvider, PilahkuProvider>(
        builder: (context, katalogProvider, pilahkuProvider, _) {
          if (katalogProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color_0FB7A6,
              ),
            );
          }

          final sampah = katalogProvider.selectedSampah;
          if (sampah == null) {
            return const Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(color: AppColors.color_404040),
              ),
            );
          }

          return Column(
            children: [
              // Header
              _buildHeader(sampah),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weight Input Section
                      _buildWeightInputSection(sampah),

                      const SizedBox(height: 24),

                      // Branch Selection Section
                      _buildBranchSelectionSection(katalogProvider, sampah),

                      const SizedBox(height: 32),

                      // Add Button
                      _buildAddButton(sampah, pilahkuProvider),
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

  Widget _buildHeader(SampahDetailModel sampah) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradient1),
      child: SafeArea(
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
                    color: AppColors.color_FFFFFF.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 16,
                      color: AppColors.color_FFFFFF,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Tambah ke Pilahku',
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
        ),
      ),
    );
  }

  Widget _buildWeightInputSection(SampahDetailModel sampah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Item Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.color_F3F3F3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: sampah.gambar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          sampah.gambar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: AppColors.color_B3B3B3,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: AppColors.color_B3B3B3,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampah.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_404040,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sampah.deskripsi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: AppColors.color_6F6F6F,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Weight Input
          const Text(
            'Estimasi Berat',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            label: 'Berat',
            hint: 'Masukkan estimasi berat',
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Estimasi berat tidak boleh kosong';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0) {
                return 'Estimasi berat harus lebih dari 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Satuan: ${sampah.satuan}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_6F6F6F,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelectionSection(
      KatalogDetailProvider katalogProvider, SampahDetailModel sampah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showBranchError ? AppColors.color_F44336 : Colors.transparent,
          width: _showBranchError ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pilih Cabang',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
              if (_showBranchError) ...[
                const SizedBox(width: 8),
                const Text(
                  '*Wajib dipilih',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.color_F44336,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih cabang terdekat untuk harga terbaik',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.color_6F6F6F,
            ),
          ),
          const SizedBox(height: 16),

          // Branch Options
          ...katalogProvider.prices.map((price) {
            final isSelected = _selectedBranchId == price.bankSampahId;
            return _buildBranchOption(price, isSelected, sampah.satuan);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBranchOption(PriceModel price, bool isSelected, String satuan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedBranchId = price.bankSampahId;
              _selectedBranchName = price.bankSampahNama;
              _selectedTipeLayanan = price.tipeLayanan;
              _selectedPrice = price.harga;
              _showBranchError = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.color_0FB7A6.withValues(alpha: 0.1)
                  : AppColors.color_F8FAFB,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.color_0FB7A6
                    : AppColors.color_E9E9E9,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Selection Indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.color_0FB7A6
                        : AppColors.color_FFFFFF,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.color_0FB7A6
                          : AppColors.color_B3B3B3,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.color_FFFFFF,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // Branch Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.bankSampahNama,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.color_0FB7A6
                              : AppColors.color_404040,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            price.tipeLayananIcon,
                            size: 12,
                            color: price.tipeLayananColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            price.tipeLayananDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: price.tipeLayananColor,
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
        ),
      ),
    );
  }

  Widget _buildAddButton(
      SampahDetailModel sampah, PilahkuProvider pilahkuProvider) {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final isValid = weight > 0 && _selectedBranchId != null;

    return Column(
      children: [
        // Summary
        if (isValid) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.color_0FB7A6.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.color_0FB7A6.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.color_0FB7A6,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estimasi Berat: $weight ${sampah.satuan}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_0FB7A6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Add Button
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: _isLoading ? 'Menambahkan...' : 'Tambah ke Pilahku',
            onPressed: _isLoading
                ? () {}
                : () => _handleAddButtonPress(sampah, pilahkuProvider),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddButtonPress(
      SampahDetailModel sampah, PilahkuProvider pilahkuProvider) async {
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    // Check weight first
    if (weight <= 0) {
      setState(() {
        _showWeightError = true;
      });
      DialogHelper.showErrorDialog(
        context,
        title: 'Estimasi Berat Kosong',
        message: 'Silakan masukkan estimasi berat sampah terlebih dahulu',
      );
      return;
    } else {
      setState(() {
        _showWeightError = false;
      });
    }

    // Check branch selection
    if (_selectedBranchId == null) {
      setState(() {
        _showBranchError = true;
      });
      DialogHelper.showErrorDialog(
        context,
        title: 'Cabang Belum Dipilih',
        message: 'Silakan pilih cabang bank sampah terlebih dahulu',
      );
      return;
    } else {
      setState(() {
        _showBranchError = false;
      });
    }

    // If all validations pass, proceed with adding to pilahku
    await _addToPilahku(sampah, pilahkuProvider);
  }

  Future<void> _addToPilahku(
      SampahDetailModel sampah, PilahkuProvider pilahkuProvider) async {
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if item already exists
      final existingItem =
          pilahkuProvider.getExistingItem(sampah.id, _selectedBranchId!);

      if (existingItem != null) {
        // Show confirmation for updating existing item
        final shouldUpdate =
            await _showUpdateConfirmation(existingItem, weight);
        if (!shouldUpdate) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Create new item
      final newItem = PilahkuItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sampahId: sampah.id,
        sampahNama: sampah.nama,
        sampahDeskripsi: sampah.deskripsi,
        sampahSatuan: sampah.satuan,
        sampahGambar: sampah.gambar,
        estimasiBerat: weight,
        bankSampahId: _selectedBranchId!,
        bankSampahNama: _selectedBranchName!,
        bankSampahTipeLayanan: _selectedTipeLayanan,
        hargaPerSatuan: _selectedPrice!,
        createdAt: DateTime.now(),
      );

      await pilahkuProvider.addItem(newItem);

      if (mounted) {
        Navigator.pop(context);
        DialogHelper.showErrorDialog(
          context,
          title: 'Berhasil',
          message: 'Berhasil menambahkan ke pilahku',
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showErrorDialog(
          context,
          message: 'Gagal menambahkan ke pilahku: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showUpdateConfirmation(
      PilahkuItemModel existingItem, double newWeight) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Item Sudah Ada',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              '${existingItem.sampahNama} sudah ada di pilahku dengan estimasi berat ${existingItem.estimasiBerat} ${existingItem.sampahSatuan}. Apakah Anda ingin menambahkan estimasi berat $newWeight ${existingItem.sampahSatuan}?',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.color_6F6F6F),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Ya, Tambahkan',
                  style: TextStyle(color: AppColors.color_0FB7A6),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
