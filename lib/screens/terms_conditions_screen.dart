import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.color_FFFFFF,
        elevation: 0,
        title: const Text(
          'Syarat & Ketentuan',
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
                  'Syarat dan Ketentuan Penggunaan Aplikasi Bengkel Sampah',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.color_404040,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '1. Penerimaan Syarat dan Ketentuan',
                  'Dengan mengunduh, mengakses, atau menggunakan aplikasi Bengkel Sampah, Anda menyetujui untuk terikat dengan syarat dan ketentuan ini. Jika Anda tidak setuju dengan syarat dan ketentuan ini, mohon untuk tidak menggunakan aplikasi ini.',
                ),
                _buildSection(
                  '2. Definisi',
                  '• "Aplikasi" merujuk pada aplikasi Bengkel Sampah\n'
                      '• "Pengguna" merujuk pada individu yang menggunakan aplikasi\n'
                      '• "Sampah" merujuk pada material yang dapat didaur ulang\n'
                      '• "Transaksi" merujuk pada proses jual beli sampah melalui aplikasi',
                ),
                _buildSection(
                  '3. Ketentuan Penggunaan',
                  '3.1. Pengguna harus berusia minimal 17 tahun atau telah mendapatkan persetujuan dari orang tua/wali.\n\n'
                      '3.2. Pengguna wajib memberikan informasi yang akurat dan lengkap saat mendaftar.\n\n'
                      '3.3. Pengguna bertanggung jawab atas keamanan akun dan kerahasiaan password.',
                ),
                _buildSection(
                  '4. Ketentuan Transaksi',
                  '4.1. Pengguna wajib memastikan sampah yang dijual sesuai dengan kategori yang tersedia.\n\n'
                      '4.2. Pengguna wajib memastikan sampah dalam kondisi bersih dan sesuai standar.\n\n'
                      '4.3. Harga sampah akan ditentukan berdasarkan jenis, kualitas, dan berat sampah.\n\n'
                      '4.4. Pembayaran akan dilakukan sesuai dengan metode yang tersedia di aplikasi.',
                ),
                _buildSection(
                  '5. Poin dan Hadiah',
                  '5.1. Poin dapat diperoleh melalui transaksi penjualan sampah.\n\n'
                      '5.2. Poin dapat ditukarkan dengan hadiah yang tersedia di katalog.\n\n'
                      '5.3. Poin tidak dapat ditukarkan dengan uang tunai.\n\n'
                      '5.4. Bengkel Sampah berhak mengubah nilai poin dan hadiah tanpa pemberitahuan sebelumnya.',
                ),
                _buildSection(
                  '6. Pembatasan Penggunaan',
                  '6.1. Pengguna dilarang menggunakan aplikasi untuk tujuan ilegal.\n\n'
                      '6.2. Pengguna dilarang melakukan manipulasi data atau transaksi.\n\n'
                      '6.3. Pengguna dilarang menyalahgunakan fitur aplikasi.',
                ),
                _buildSection(
                  '7. Perubahan Syarat dan Ketentuan',
                  'Bengkel Sampah berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan diberitahukan melalui aplikasi.',
                ),
                _buildSection(
                  '8. Kontak',
                  'Untuk pertanyaan terkait syarat dan ketentuan, silakan hubungi kami melalui:\n\n'
                      'Email: support@bengkelsampah.com\n'
                      'Telepon: (+62) 821 6823 1808',
                ),
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
