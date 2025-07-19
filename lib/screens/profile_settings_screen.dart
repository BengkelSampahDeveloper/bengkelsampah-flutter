import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:bengkelsampah_app/helpers/global_helper.dart';
import 'package:bengkelsampah_app/providers/detail_profile_provider.dart';
import 'package:bengkelsampah_app/screens/add_address_screen.dart';
import 'package:bengkelsampah_app/widgets/custom_text_field.dart';
import 'package:bengkelsampah_app/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_address_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final GlobalIdentifierManager _identifierManager = GlobalIdentifierManager();
  late DetailProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _identifierManager.loadIdentifier();
    _profileProvider = DetailProfileProvider();
    _profileProvider.loadDetailProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        title: const Text(
          'Pengaturan Profil',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChangeNotifierProvider<DetailProfileProvider>.value(
                value: _profileProvider,
                child: Consumer<DetailProfileProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        DialogHelper.showLoadingDialog(context,
                            message: 'Memuat data...');
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      });
                    }

                    if (provider.error != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        DialogHelper.showErrorDialog(
                          context,
                          message: provider.error!,
                          onRetry: provider.loadDetailProfile,
                        );
                      });
                      return const SizedBox.shrink();
                    }

                    final detailProfileData = provider.detailProfileData;
                    final addresses =
                        detailProfileData?['addresses'] as List<dynamic>? ?? [];

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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildNameSection(context),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Alamat",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_404040,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddAddressScreen(),
                                          ),
                                        ).then((value) {
                                          if (value == true) {
                                            provider.refresh();
                                          }
                                        });
                                      },
                                      child: const Text(
                                        "Tambah",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.color_0FB7A6,
                                        ),
                                        textAlign: TextAlign.right,
                                      ))
                                ],
                              ),
                              if (addresses.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Belum ada alamat",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: AppColors.color_535353,
                                    ),
                                  ),
                                )
                              else
                                ...addresses
                                    .where((address) =>
                                        address['is_default'] == true)
                                    .map((address) =>
                                        _buildAddressCard(address, () {
                                          provider.refresh();
                                        }))
                                    .toList()
                                    .followedBy(
                                      addresses
                                          .where((address) =>
                                              address['is_default'] != true)
                                          .map((address) =>
                                              _buildAddressCard(address, () {
                                                provider.refresh();
                                              }))
                                          .toList(),
                                    ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Lengkap',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: AppColors.color_404040,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _identifierManager.nameNotifier,
                builder: (context, name, child) {
                  return Text(
                    name.isNotEmpty ? name : 'Nama belum diset',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.color_404040,
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildEditNameBottomSheet(
                    context,
                    _identifierManager.currentName,
                  ),
                );
              },
              child: const Text(
                "Ubah",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_0FB7A6,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.color_D9D9D9,
        ),
      ],
    );
  }

  Widget _buildAddressCard(
      Map<String, dynamic> address, VoidCallback onRefresh) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.color_FFFFFF,
        border: Border.all(
          color: AppColors.color_D9D9D9,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  address['label_alamat'] ?? 'Rumah',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                if (address['is_default'] == true) ...[
                  const SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.color_40E0D0.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Center(
                        child: Text(
                          "Utama",
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: AppColors.color_0FB7A6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              address['nama'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              address['nomor_handphone'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _formatAddress(address),
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppColors.color_404040,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAddressScreen(
                            address: address,
                          ),
                        ),
                      ).then((value) {
                        // Only refresh if there are changes (value is true)
                        if (value == true) {
                          onRefresh();
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.color_FFFFFF,
                        border: Border.all(
                          color: AppColors.color_D9D9D9,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            "Ubah Alamat",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: AppColors.color_404040,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    final detailLain = address['detail_lain'] ?? '';
    final kecamatan = address['kecamatan'] ?? '';
    final kotaKabupaten = address['kota_kabupaten'] ?? '';
    final provinsi = address['provinsi'] ?? '';
    final kodePos = address['kode_pos'] ?? '';

    final List<String> addressParts = [
      if (detailLain.isNotEmpty) detailLain,
      if (kecamatan.isNotEmpty) 'Kec. $kecamatan',
      if (kotaKabupaten.isNotEmpty) kotaKabupaten,
      if (provinsi.isNotEmpty) provinsi,
      if (kodePos.isNotEmpty) kodePos,
    ];

    return addressParts.join(', ');
  }

  Widget _buildEditNameBottomSheet(BuildContext context, String currentName) {
    return _EditNameBottomSheet(
      currentName: currentName,
      identifierManager: _identifierManager,
    );
  }
}

// Separate StatefulWidget for Edit Name Bottom Sheet
class _EditNameBottomSheet extends StatefulWidget {
  final String currentName;
  final GlobalIdentifierManager identifierManager;

  const _EditNameBottomSheet({
    required this.currentName,
    required this.identifierManager,
  });

  @override
  State<_EditNameBottomSheet> createState() => _EditNameBottomSheetState();
}

class _EditNameBottomSheetState extends State<_EditNameBottomSheet> {
  late final TextEditingController nameController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (mounted) {
        DialogHelper.showLoadingDialog(
          context,
          message: 'Menyimpan perubahan...',
        );
      }

      final provider = Provider.of<DetailProfileProvider>(
        context,
        listen: false,
      );
      final success = await provider.updateProfile(
        name: nameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Hide loading
      }

      if (success && mounted) {
        Navigator.pop(context); // Close bottom sheet
        // Update global name
        await widget.identifierManager.updateName(nameController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diubah')),
        );
      } else if (mounted && provider.error != null) {
        DialogHelper.showErrorDialog(
          context,
          message: provider.error!,
          onRetry: handleSubmit,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Hide loading
        DialogHelper.showErrorDialog(
          context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.color_FFFFFF,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Nama Lengkap',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.color_404040,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: handleSubmit,
                text: 'Simpan',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
