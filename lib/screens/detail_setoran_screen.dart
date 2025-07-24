import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../providers/address_provider.dart';
import '../models/pilahku_model.dart';
import '../models/address_model.dart';
import '../widgets/custom_buttons.dart';
import '../providers/setoran_provider.dart';
import '../providers/pilahku_provider.dart';
import '../helpers/dialog_helper.dart';
import 'dart:typed_data';
import '../helpers/global_helper.dart';
import '../helpers/image_picker_helper.dart';
import 'package:universal_platform/universal_platform.dart';

enum TipeSetor { jual, sedekah, tabung }

class DetailSetoranScreen extends StatefulWidget {
  final List<PilahkuItemModel> selectedItems;

  const DetailSetoranScreen({
    Key? key,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<DetailSetoranScreen> createState() => _DetailSetoranScreenState();
}

class _DetailSetoranScreenState extends State<DetailSetoranScreen> {
  AddressModel? selectedAddress;
  File? selectedImage;
  Uint8List? webImageBytes;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TipeSetor selectedTipeSetor = TipeSetor.tabung; // Default to tabung

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  @override
  void dispose() {
    // Clean up resources
    selectedImage = null;
    webImageBytes = null;
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final addressProvider = context.read<AddressProvider>();
    await addressProvider.getAddresses();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.color_FFFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.color_D9D9D9,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
            ),
            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.color_0FB7A6,
                  size: 24,
                ),
              ),
              title: const Text(
                'Ambil Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_404040,
                ),
              ),
              subtitle: const Text(
                'Gunakan kamera untuk mengambil foto',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_6F6F6F,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _takePhotoFromCamera();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.color_FFAB2A,
                  size: 24,
                ),
              ),
              title: const Text(
                'Pilih dari Galeri',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_404040,
                ),
              ),
              subtitle: const Text(
                'Pilih foto dari galeri',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_6F6F6F,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhotoFromCamera() async {
    if (!mounted) return;

    try {
      if (UniversalPlatform.isWeb) {
        final bytes = await ImagePickerHelper.getWebImageBytes(context);
        if (bytes != null && mounted) {
          setState(() {
            webImageBytes = bytes;
            selectedImage = null;
          });
        }
        return;
      }

      // Store context before async operation
      final currentContext = context;

      final file = await ImagePickerHelper.pickImageFromCamera(context);

      // Double check if widget is still mounted and context is valid
      if (file != null && mounted && currentContext.mounted) {
        // Add small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted && currentContext.mounted) {
          setState(() {
            selectedImage = file;
            webImageBytes = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: AppColors.color_FFAB2A,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (!mounted) return;

    try {
      if (UniversalPlatform.isWeb) {
        final bytes = await ImagePickerHelper.getWebImageBytes(context);
        if (bytes != null && mounted) {
          setState(() {
            webImageBytes = bytes;
            selectedImage = null;
          });
        }
        return;
      }

      // Store context before async operation
      final currentContext = context;

      final file = await ImagePickerHelper.pickImageFromGallery(context);

      // Double check if widget is still mounted and context is valid
      if (file != null && mounted && currentContext.mounted) {
        // Add small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted && currentContext.mounted) {
          setState(() {
            selectedImage = file;
            webImageBytes = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: AppColors.color_FFAB2A,
          ),
        );
      }
    }
  }

  void _showDatePicker() {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);

    showDatePicker(
      context: context,
      initialDate: selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year, now.month, now.day + 30),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
          selectedTime = null; // Reset time when date changes
        });
      }
    });
  }

  void _showTimePicker() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
      );
      return;
    }

    final now = DateTime.now();
    final isToday = selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    const startHour = 8; // Jam kerja mulai 8 AM
    const endHour = 17; // Jam kerja sampai 5 PM

    showTimePicker(
      context: context,
      initialTime: selectedTime ??
          TimeOfDay(hour: isToday ? now.hour + 1 : startHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        // Cek jam operasional
        if (time.hour < startHour || time.hour >= endHour) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih waktu antara jam 8:00 - 17:00'),
              ),
            );
            // Kosongkan waktu yang dipilih
            setState(() {
              selectedTime = null;
            });
          }
          return;
        }
        // Cek jika hari ini dan waktu yang dipilih sudah lewat
        if (isToday) {
          final pickedDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            time.hour,
            time.minute,
          );
          if (pickedDateTime.isBefore(now)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak bisa memilih jam yang telah lewat'),
                ),
              );
              // Kosongkan waktu yang dipilih
              setState(() {
                selectedTime = null;
              });
            }
            return;
          }
        }
        setState(() {
          selectedTime = time;
        });
      }
    });
  }

  void _showAddressPicker() {
    final addressProvider = context.read<AddressProvider>();
    final addresses = addressProvider.addresses;

    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Belum ada alamat. Silakan tambah alamat di pengaturan profil.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.color_FFFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.color_D9D9D9,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Pilih Alamat Penjemputan',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: AppColors.color_6F6F6F,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Address list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = selectedAddress?.id == address.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.color_0FB7A6.withValues(alpha: 0.1)
                          : AppColors.color_FFFFFF,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.color_0FB7A6
                            : AppColors.color_E9E9E9,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            selectedAddress = address;
                          });
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label and default badge
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      address.labelAlamat,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.color_404040,
                                      ),
                                    ),
                                  ),
                                  if (address.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.color_0FB7A6
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.color_0FB7A6,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.color_0FB7A6,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Name and phone
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.color_6F6F6F,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      address.nama,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_6F6F6F,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 16,
                                    color: AppColors.color_6F6F6F,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      address.nomorHandphone,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_6F6F6F,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Full address
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.color_6F6F6F,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      address.fullAddress,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: AppColors.color_404040,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getServiceTypeDisplay(String? serviceType) {
    switch (serviceType) {
      case 'jemput':
        return 'Jemput Saja';
      case 'tempat':
        return 'Tempat Saja';
      case 'keduanya':
        return 'Keduanya';
      default:
        return 'Tidak Diketahui';
    }
  }

  Color _getServiceTypeColor(String? serviceType) {
    switch (serviceType) {
      case 'jemput':
        return AppColors.color_0FB7A6;
      case 'tempat':
        return AppColors.color_FFAB2A;
      case 'keduanya':
        return AppColors.color_6C919C;
      default:
        return AppColors.color_B3B3B3;
    }
  }

  IconData _getServiceTypeIcon(String? serviceType) {
    switch (serviceType) {
      case 'jemput':
        return Icons.delivery_dining;
      case 'tempat':
        return Icons.location_on;
      case 'keduanya':
        return Icons.swap_horiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankSampah = widget.selectedItems.first.bankSampahNama;
    final serviceType = widget.selectedItems.first.bankSampahTipeLayanan;
    final totalItems = widget.selectedItems.length;
    final totalWeight =
        widget.selectedItems.fold(0.0, (sum, item) => sum + item.estimasiBerat);
    final totalPrice =
        widget.selectedItems.fold(0.0, (sum, item) => sum + item.totalHarga);

    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.color_404040),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Setoran',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Alamat Penjemputan
            _buildSection1(),
            const SizedBox(height: 20),

            // Section 2: Detail Bank Sampah
            _buildSection2(bankSampah, serviceType),
            const SizedBox(height: 20),

            // Section 3: Daftar Sampah
            _buildSection3(totalItems, totalWeight, totalPrice),
            const SizedBox(height: 20),

            // Section 4: Tipe Setor
            _buildSection4(),
            const SizedBox(height: 20),

            // Section 5: Foto Sampah
            _buildSection5(),
            const SizedBox(height: 20),

            // Section 6: Jadwal Penjemputan (berdasarkan tipe layanan)
            _buildSection6(serviceType),
            const SizedBox(height: 30),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection1() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alamat Penjemputan',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedAddress == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.color_F8FAFB,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.color_E9E9E9),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 48,
                    color: AppColors.color_B3B3B3,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada alamat dipilih',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: AppColors.color_B3B3B3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: 'Pilih Alamat',
                    onPressed: _showAddressPicker,
                    width: 150,
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.color_F8FAFB,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.color_0FB7A6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label and default badge
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.color_0FB7A6,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedAddress!.labelAlamat,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppColors.color_404040,
                          ),
                        ),
                      ),
                      if (selectedAddress!.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.color_0FB7A6.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.color_0FB7A6,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Utama',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: AppColors.color_0FB7A6,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _showAddressPicker,
                        child: const Text(
                          'Ubah',
                          style: TextStyle(color: AppColors.color_0FB7A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name and phone
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.color_6F6F6F,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedAddress!.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: AppColors.color_6F6F6F,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.color_6F6F6F,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedAddress!.nomorHandphone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: AppColors.color_6F6F6F,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Full address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.color_6F6F6F,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedAddress!.fullAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: AppColors.color_404040,
                          ),
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

  Widget _buildSection2(String bankSampah, String? serviceType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Bank Sampah',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.color_F8FAFB,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.color_E9E9E9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(serviceType)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getServiceTypeIcon(serviceType),
                        color: _getServiceTypeColor(serviceType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bankSampah,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                          Text(
                            _getServiceTypeDisplay(serviceType),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: _getServiceTypeColor(serviceType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Alamat', 'Jl. Contoh No. 123, Jakarta'),
                _buildInfoRow('Penanggung Jawab', 'John Doe'),
                _buildInfoRow('Kontak', '+62 812-3456-7890'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppColors.color_6F6F6F,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppColors.color_404040,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection3(int totalItems, double totalWeight, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Sampah',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.color_F8FAFB,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.color_E9E9E9),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total Item', '$totalItems item'),
                _buildSummaryRow(
                    'Estimasi Berat', '${totalWeight.toStringAsFixed(1)} kg'),
                _buildSummaryRow('Estimasi Total',
                    '${NumberFormatter.formatSimpleNumber(totalPrice)} Poin',
                    isTotal: true),
                const SizedBox(height: 8),
                _buildTipeSetorSummary(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Daftar item sampah
          ...widget.selectedItems.map((item) => _buildItemCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildTipeSetorSummary() {
    final totalPrice =
        widget.selectedItems.fold(0.0, (sum, item) => sum + item.totalHarga);

    switch (selectedTipeSetor) {
      case TipeSetor.jual:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.money,
                size: 16,
                color: AppColors.color_FFAB2A,
              ),
              const SizedBox(width: 6),
              Text(
                'Estimasi cash: ${NumberFormatter.formatSimpleNumber(totalPrice)} Poin',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_FFAB2A,
                ),
              ),
            ],
          ),
        );

      case TipeSetor.sedekah:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.color_F44336.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: AppColors.color_F44336,
              ),
              SizedBox(width: 6),
              Text(
                'Sedekah kebersamaan',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_F44336,
                ),
              ),
            ],
          ),
        );

      case TipeSetor.tabung:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/ic_poin_inverse.svg',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Estimasi poin: ${NumberFormatter.formatSimpleNumber(totalPrice)} Poin',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.color_0FB7A6,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildItemCard(PilahkuItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        border: Border.all(color: AppColors.color_E9E9E9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(item),
            const SizedBox(width: 16),
            Expanded(
              child: _buildItemDetails(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(PilahkuItemModel item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.color_F3F3F3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildImageContent(item),
    );
  }

  Widget _buildImageContent(PilahkuItemModel item) {
    if (item.sampahGambar?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.sampahGambar!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported,
                color: AppColors.color_B3B3B3);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.color_0FB7A6,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }
    return const Icon(Icons.image_not_supported, color: AppColors.color_B3B3B3);
  }

  Widget _buildItemDetails(PilahkuItemModel item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name
        Text(
          item.sampahNama,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Bank Sampah Info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getServiceTypeColor(item.bankSampahTipeLayanan)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getServiceTypeIcon(item.bankSampahTipeLayanan),
                size: 12,
                color: _getServiceTypeColor(item.bankSampahTipeLayanan),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.bankSampahNama,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_6F6F6F,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Price Details
        _buildItemStats(item),
        const SizedBox(height: 8),

        // Total Points
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/ic_poin_inverse.svg',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${NumberFormatter.formatSimpleNumber(item.totalHarga)} Poin',
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FB7A6,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemStats(PilahkuItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/ic_poin_inverse.svg',
          width: 15,
          height: 15,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${NumberFormatter.formatSimpleNumber(item.hargaPerSatuan)} Poin x ${item.estimasiBerat.toStringAsFixed(1)} ${item.sampahSatuan.isNotEmpty ? item.sampahSatuan : 'Kg'}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: AppColors.color_0FB7A6,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: AppColors.color_6F6F6F,
            ),
          ),
          if (isTotal)
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/ic_poin_inverse.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_0FB7A6,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_404040,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection4() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipe Setor',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),

          // Tipe Setor Options
          Column(
            children: TipeSetor.values
                .map((tipe) => _buildTipeSetorOption(tipe))
                .toList(),
          ),

          const SizedBox(height: 12),

          // Information based on selected type
          _buildTipeSetorInfo(),
        ],
      ),
    );
  }

  Widget _buildTipeSetorOption(TipeSetor tipe) {
    final isSelected = selectedTipeSetor == tipe;
    final Map<TipeSetor, Map<String, dynamic>> tipeInfo = {
      TipeSetor.jual: {
        'title': 'Jual',
        'subtitle': 'Dapatkan uang cash langsung',
        'icon': Icons.money,
        'color': AppColors.color_FFAB2A,
      },
      TipeSetor.sedekah: {
        'title': 'Sedekah',
        'subtitle': 'Donasikan untuk kebaikan',
        'icon': Icons.favorite,
        'color': AppColors.color_F44336,
      },
      TipeSetor.tabung: {
        'title': 'Tabung',
        'subtitle': 'Simpan sebagai poin',
        'icon': Icons.account_balance_wallet,
        'color': AppColors.color_0FB7A6,
      },
    };

    final info = tipeInfo[tipe]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? info['color'].withValues(alpha: 0.1)
            : AppColors.color_F8FAFB,
        border: Border.all(
          color: isSelected ? info['color'] : AppColors.color_E9E9E9,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              selectedTipeSetor = tipe;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? info['color'].withValues(alpha: 0.2)
                        : AppColors.color_E9E9E9,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    info['icon'],
                    size: 20,
                    color: isSelected ? info['color'] : AppColors.color_6F6F6F,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? info['color']
                              : AppColors.color_404040,
                        ),
                      ),
                      Text(
                        info['subtitle'],
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: isSelected
                              ? info['color']
                              : AppColors.color_6F6F6F,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: info['color'],
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipeSetorInfo() {
    final totalPrice =
        widget.selectedItems.fold(0.0, (sum, item) => sum + item.totalHarga);

    switch (selectedTipeSetor) {
      case TipeSetor.jual:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.color_FFAB2A.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.color_FFAB2A,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anda akan mendapatkan uang cash sebesar ${NumberFormatter.formatSimpleNumber(totalPrice)} Poin (setara dengan estimasi nilai sampah)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_FFAB2A,
                  ),
                ),
              ),
            ],
          ),
        );

      case TipeSetor.sedekah:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.color_F44336.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.color_F44336.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.color_F44336,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Terima kasih atas sedekah Anda! Sampah akan didonasikan untuk kebaikan bersama.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_F44336,
                  ),
                ),
              ),
            ],
          ),
        );

      case TipeSetor.tabung:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.color_0FB7A6.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: AppColors.color_0FB7A6,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anda akan mendapatkan ${NumberFormatter.formatSimpleNumber(totalPrice)} Poin yang dapat digunakan untuk transaksi di aplikasi',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_0FB7A6,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildSection5() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Sampah',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedImage == null && webImageBytes == null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.color_F8FAFB,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.color_E9E9E9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: AppColors.color_B3B3B3,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada foto',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: AppColors.color_B3B3B3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Upload foto sampah yang akan disetor',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: AppColors.color_B3B3B3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: AppColors.color_FFFFFF,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Upload Foto',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: AppColors.color_FFFFFF,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.color_0FB7A6),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: UniversalPlatform.isWeb && webImageBytes != null
                        ? Image.memory(
                            webImageBytes!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.color_F44336,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.color_FFFFFF, size: 20),
                        onPressed: () {
                          setState(() {
                            selectedImage = null;
                            webImageBytes = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection6(String? serviceType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceType == 'tempat'
                ? 'Informasi Setoran'
                : 'Jadwal Penjemputan',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 12),
          if (serviceType == 'jemput') ...[
            _buildSchedulePicker(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.color_0FB7A6.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Nantinya Anda akan dikonfirmasi oleh bank sampah untuk penjemputan. Jadwal penjemputan dapat diubah bank sampah atas kesepakatan dengan Anda.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_0FB7A6,
                ),
              ),
            ),
          ] else if (serviceType == 'tempat') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.color_FFAB2A.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.color_FFAB2A.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Cabang bank ini hanya menerima sampah di tempat. Silakan datang langsung ke cabang dengan membawa sampah yang telah dipilah.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_FFAB2A,
                ),
              ),
            ),
          ] else if (serviceType == 'keduanya') ...[
            _buildSchedulePicker(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.color_6C919C.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.color_6C919C.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Nanti bank sampah akan menghubungi Anda untuk mengkonfirmasi akan dijemput atau dibawa langsung ke bank sampah.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: AppColors.color_6C919C,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color_F8FAFB,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color_E9E9E9),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.color_6F6F6F,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.color_FFFFFF,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.color_E9E9E9),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.color_6F6F6F),
                            const SizedBox(width: 2),
                            Text(
                              selectedDate != null
                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Pilih tanggal',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: selectedDate != null
                                    ? AppColors.color_404040
                                    : AppColors.color_B3B3B3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waktu',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppColors.color_6F6F6F,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showTimePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.color_FFFFFF,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.color_E9E9E9),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: AppColors.color_6F6F6F),
                            const SizedBox(width: 2),
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Pilih waktu',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: selectedTime != null
                                    ? AppColors.color_404040
                                    : AppColors.color_B3B3B3,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final serviceType = widget.selectedItems.first.bankSampahTipeLayanan;
    bool canSubmit = selectedAddress != null &&
        (selectedImage != null || webImageBytes != null);

    // For jemput and keduanya, need schedule
    if (serviceType == 'jemput' || serviceType == 'keduanya') {
      canSubmit = canSubmit && selectedDate != null && selectedTime != null;
    }

    return SizedBox(
      width: double.infinity,
      child: GradientButton(
        text: 'Kirim Setoran',
        onPressed: canSubmit ? _submitSetoran : () {},
      ),
    );
  }

  Future<void> _submitSetoran() async {
    // Validate required fields
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alamat penjemputan terlebih dahulu'),
          backgroundColor: AppColors.color_F44336,
        ),
      );
      return;
    }

    if (selectedImage == null && webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload foto sampah terlebih dahulu'),
          backgroundColor: AppColors.color_F44336,
        ),
      );
      return;
    }

    // Validate schedule for pickup service
    if (widget.selectedItems.first.bankSampahTipeLayanan == 'jemput' ||
        widget.selectedItems.first.bankSampahTipeLayanan == 'keduanya') {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal dan waktu penjemputan'),
            backgroundColor: AppColors.color_F44336,
          ),
        );
        return;
      }
    }

    // Show loading dialog
    DialogHelper.showLoadingDialog(
      context,
      message: 'Mengirim data setoran...',
    );

    try {
      // Prepare items data
      final items = widget.selectedItems
          .map((item) => {
                'sampah_id': item.sampahId,
                'estimasi_berat': item.estimasiBerat,
                'harga_per_satuan': item.hargaPerSatuan,
                'sampah_nama': item.sampahNama,
                'sampah_satuan': item.sampahSatuan,
              })
          .toList();

      // Calculate total
      final estimasiTotal = widget.selectedItems
          .fold<double>(0, (sum, item) => sum + item.totalHarga);

      // Get bank sampah data from first item
      final firstItem = widget.selectedItems.first;
      final bankSampahId = int.tryParse(firstItem.bankSampahId) ?? 0;

      // Prepare date and time
      DateTime? tanggalPenjemputan;
      String? waktuPenjemputan;

      if (selectedDate != null && selectedTime != null) {
        tanggalPenjemputan = selectedDate;
        waktuPenjemputan =
            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
      }

      // Create setoran using provider
      final setoranProvider = context.read<SetoranProvider>();
      final result = await setoranProvider.createSetoran(
        bankSampahId: bankSampahId,
        addressId: selectedAddress!.id,
        tipeSetor: selectedTipeSetor.name,
        items: items,
        estimasiTotal: estimasiTotal,
        tanggalPenjemputan: tanggalPenjemputan,
        waktuPenjemputan: waktuPenjemputan,
        fotoSampah: UniversalPlatform.isWeb ? webImageBytes : selectedImage,
        tipeLayanan: firstItem.bankSampahTipeLayanan ?? 'tempat',
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (result['success'] == true) {
        // Clear pilahku items that were submitted
        final pilahkuProvider = context.read<PilahkuProvider>();
        for (final item in widget.selectedItems) {
          pilahkuProvider.removeItem(item.id);
        }

        // Refresh setoran data to ensure new data appears
        await setoranProvider.smartRefresh();

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
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
                    'Setoran Berhasil!',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Data setoran telah dikirim ke bank sampah. Anda akan dihubungi untuk konfirmasi.',
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
                    // Navigate back to pilahku screen
                    Navigator.pop(context);
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
      } else {
        // Show error dialog
        if (mounted) {
          DialogHelper.showErrorDialog(
            context,
            message:
                result['message'] ?? 'Terjadi kesalahan saat mengirim setoran',
            onRetry: _submitSetoran,
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (mounted) {
        DialogHelper.showErrorDialog(
          context,
          message: 'Terjadi kesalahan: ${e.toString()}',
          onRetry: _submitSetoran,
        );
      }
    }
  }
}
