import 'package:bengkelsampah_app/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bank_sampah_provider.dart';
import '../constants/app_colors.dart';

class BankSampahScreen extends StatefulWidget {
  const BankSampahScreen({super.key});

  @override
  State<BankSampahScreen> createState() => _BankSampahScreenState();
}

class _BankSampahScreenState extends State<BankSampahScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F8FAFB,
      body: ChangeNotifierProvider<BankSampahProvider>(
        create: (_) => BankSampahProvider()..loadBankSampah(),
        child: Consumer<BankSampahProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.bankSampahList.isEmpty) {
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
                  onRetry: provider.loadBankSampah,
                );
              });
            }

            if (provider.bankSampahList.isEmpty && !provider.isLoading) {
              return const SizedBox(
                child: Center(
                  child: Text('Tidak ada data bank sampah'),
                ),
              );
            }

            return Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradient1,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 20, top: 63, bottom: 30),
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
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                              height: 29,
                              child: Center(
                                child: Text(
                                  "Daftar Bank Sampah",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.color_FFFFFF,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    color: AppColors.color_0FB7A6,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      itemCount: provider.bankSampahList.length,
                      itemBuilder: (context, index) {
                        final bankSampah = provider.bankSampahList[index];
                        return _buildBankSampahCard(bankSampah);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBankSampahCard(dynamic bankSampah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.color_0FB7A6.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bankSampah.kodeBankSampah,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: AppColors.color_0FB7A6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.color_40E0D0.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bankSampah.tipeLayananDisplay,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: AppColors.color_40E0D0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Bank Sampah (selalu tampilkan container)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (bankSampah.foto != null &&
                              bankSampah.foto!.isNotEmpty)
                          ? Image.network(
                              bankSampah.foto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.color_0FB7A6,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Info Bank Sampah
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankSampah.namaBankSampah,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                bankSampah.alamatBankSampah,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bankSampah.namaPenanggungJawab,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Colors.grey,
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
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bankSampah.kontakPenanggungJawab,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}
