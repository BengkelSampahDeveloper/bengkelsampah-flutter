import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/providers/address_provider.dart';
import 'package:bengkelsampah_app/widgets/custom_text_field.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = false;

  final _namaController = TextEditingController();
  final _nomorHandphoneController = TextEditingController();
  final _labelAlamatController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kotaKabupatenController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _detailLainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing address data
    _namaController.text = widget.address['nama'] ?? '';
    _nomorHandphoneController.text = widget.address['nomor_handphone'] ?? '';
    _labelAlamatController.text = widget.address['label_alamat'] ?? '';
    _provinsiController.text = widget.address['provinsi'] ?? '';
    _kotaKabupatenController.text = widget.address['kota_kabupaten'] ?? '';
    _kecamatanController.text = widget.address['kecamatan'] ?? '';
    _kodePosController.text = widget.address['kode_pos'] ?? '';
    _detailLainController.text = widget.address['detail_lain'] ?? '';
    _isDefault = widget.address['is_default'] ?? false;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);

    // Show loading dialog
    if (mounted) {
      DialogHelper.showLoadingDialog(
        context,
        message: 'Menyimpan alamat...',
      );
    }

    final success = await addressProvider.updateAddress(
      id: widget.address['id'],
      nama: _namaController.text,
      nomorHandphone: _nomorHandphoneController.text,
      labelAlamat: _labelAlamatController.text,
      provinsi: _provinsiController.text,
      kotaKabupaten: _kotaKabupatenController.text,
      kecamatan: _kecamatanController.text,
      kodePos: _kodePosController.text,
      detailLain: _detailLainController.text,
      isDefault: _isDefault,
    );

    // Hide loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted && addressProvider.error != null) {
      DialogHelper.showErrorDialog(
        context,
        message: addressProvider.error!,
        onRetry: _submitForm,
      );
    }
  }

  Future<void> _deleteAddress() async {
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);

    // Show loading dialog
    if (mounted) {
      DialogHelper.showLoadingDialog(
        context,
        message: 'Menghapus alamat...',
      );
    }

    final success = await addressProvider.deleteAddress(widget.address['id']);

    // Hide loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted && addressProvider.error != null) {
      DialogHelper.showErrorDialog(
        context,
        message: addressProvider.error!,
        onRetry: _deleteAddress,
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHandphoneController.dispose();
    _labelAlamatController.dispose();
    _provinsiController.dispose();
    _kotaKabupatenController.dispose();
    _kecamatanController.dispose();
    _kodePosController.dispose();
    _detailLainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/ic_back.svg',
            height: 24,
            width: 24,
          ),
        ),
        title: const Text(
          'Edit Alamat',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Informasi Pemilik',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_404040,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                color: AppColors.color_FFFFFF,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Nama Penerima',
                        hint: 'Masukkan nama penerima',
                        controller: _namaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama penerima harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'No. Handphone',
                        hint: 'Masukkan no. handphone',
                        controller: _nomorHandphoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No. handphone harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Label Alamat',
                        hint: 'Contoh: Rumah, Kantor',
                        controller: _labelAlamatController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Label alamat harus diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: Text(
                  'Informasi Alamat',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.color_404040,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.color_FFFFFF,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Provinsi',
                        hint: 'Masukkan provinsi',
                        controller: _provinsiController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Provinsi harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Kota/Kabupaten',
                        hint: 'Masukkan kota/kabupaten',
                        controller: _kotaKabupatenController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kota/Kabupaten harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Kecamatan',
                        hint: 'Masukkan kecamatan',
                        controller: _kecamatanController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kecamatan harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Kode Pos',
                        hint: 'Masukkan kode pos',
                        controller: _kodePosController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode pos harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Detail Alamat',
                        hint: 'Masukkan detail alamat',
                        controller: _detailLainController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                color: AppColors.color_FFFFFF,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: _isDefault,
                              onChanged: (value) {
                                setState(() => _isDefault = value ?? false);
                              },
                              activeColor: AppColors.color_0FB7A6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const Text(
                            'Jadikan Alamat Utama',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: 'Update',
                        onPressed: _submitForm,
                        height: 40,
                        borderRadius: 30,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _deleteAddress,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.color_F44336),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: const Text(
                          'Hapus Alamat',
                          style: TextStyle(
                            color: AppColors.color_F44336,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
