import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.color_404040,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kebijakan Privasi Aplikasi Bengkel Sampah',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                    '1. Informasi yang Kami Kumpulkan',
                    '1.1. Informasi Pribadi:\n'
                        '• Nama lengkap\n'
                        '• Alamat email\n'
                        '• Nomor telepon\n'
                        '• Alamat lengkap\n'
                        '• Foto profil (opsional)\n'),
                _buildSection(
                  '2. Penggunaan Informasi',
                  '2.1. Untuk menyediakan layanan aplikasi\n'
                      '2.2. Untuk memproses transaksi\n'
                      '2.3. Untuk mengirim notifikasi penting\n'
                      '2.4. Untuk meningkatkan layanan\n'
                      '2.5. Untuk keperluan analisis dan pengembangan',
                ),
                _buildSection(
                  '3. Perlindungan Data',
                  '3.1. Kami menggunakan enkripsi untuk melindungi data Anda\n'
                      '3.2. Akses ke data dibatasi hanya untuk karyawan yang berwenang\n'
                      '3.3. Data disimpan di server yang aman\n'
                      '3.4. Kami melakukan pemantauan keamanan secara berkala',
                ),
                _buildSection(
                  '4. Berbagi Informasi',
                  '4.1. Kami tidak menjual data pribadi Anda\n'
                      '4.2. Data dapat dibagikan dengan:\n'
                      '• Mitra pengangkut sampah\n'
                      '• Penyedia layanan pembayaran\n'
                      '• Pihak berwenang jika diperlukan hukum',
                ),
                _buildSection(
                  '5. Hak Pengguna',
                  '5.1. Mengakses data pribadi Anda\n'
                      '5.2. Memperbarui atau mengoreksi data\n'
                      '5.3. Meminta penghapusan data\n'
                      '5.4. Menolak penggunaan data untuk tujuan tertentu',
                ),
                _buildSection(
                  '6. Cookie dan Teknologi Serupa',
                  'Kami menggunakan cookie dan teknologi serupa untuk:\n'
                      '• Meningkatkan pengalaman pengguna\n'
                      '• Menganalisis penggunaan aplikasi\n'
                      '• Menyimpan preferensi pengguna',
                ),
                _buildSection(
                  '7. Perubahan Kebijakan',
                  'Kami dapat mengubah kebijakan privasi ini sewaktu-waktu. Perubahan akan diberitahukan melalui aplikasi.',
                ),
                _buildSection(
                    '8. Kontak',
                    'Untuk pertanyaan terkait privasi, silakan hubungi:\n\n'
                        'Email: developer@bengkelsampah.com\n'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: AppColors.color_404040,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: AppColors.color_535353,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
