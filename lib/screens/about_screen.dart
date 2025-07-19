import 'package:bengkelsampah_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color_F6F7FB,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient4,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 62, left: 26, right: 26, bottom: 15),
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
                                "BengkelSampah",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.color_FFFFFF,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.color_0FB7A6,
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 15),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "BengkelSampah ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.color_FFFFFF,
                                fontFamily: 'Poppins'),
                          ),
                          TextSpan(
                            text:
                                "merupakan sebuah inovasi digital yang didirikan dengan tujuan untuk mewujudkan upaya optimalisasi dalam aktivitas perniagaan sampah non-organik.",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.color_FFFFFF,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ))),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.color_FFFFFF,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                  child: Column(
                    children: [
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Visi ",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_404040,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: "Bengkel",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_0FB7A6,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: "Sampah",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_404040,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Mengoptimalisasikan kualitas kebersihan lingkungan dan sistem tata kelola sampah non-organik secara terpadu di seluruh Indonesia.",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.color_404040,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.color_FFFFFF,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                  child: Column(
                    children: [
                      const Text(
                        "Target Pengembangan Berkelanjutan",
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.color_404040,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 23),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/ic_goals_one.webp",
                            width: 85,
                            height: 85,
                          ),
                          const SizedBox(width: 15),
                          Image.asset(
                            "assets/images/ic_goals_two.webp",
                            width: 85,
                            height: 85,
                          ),
                          const SizedBox(width: 15),
                          Image.asset(
                            "assets/images/ic_goals_three.webp",
                            width: 85,
                            height: 85,
                          ),
                        ],
                      )
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.color_FFFFFF,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                  child: Column(
                    children: [
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Mengapa Harus ",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_404040,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: "Bengkel",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_0FB7A6,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: "Sampah",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.color_404040,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradient1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Penjemputan Sampah Gratis",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.color_FFFFFF,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/ic_why_one.webp",
                                            width: 58,
                                            height: 55,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                          const SizedBox(width: 11),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradient1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Menjual 20+ Jenis Sampah",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.color_FFFFFF,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/ic_why_two.webp",
                                            width: 58,
                                            height: 55,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradient1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Harga Sampah Lebih Tinggi",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.color_FFFFFF,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/ic_why_three.webp",
                                            width: 58,
                                            height: 55,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                          const SizedBox(width: 11),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradient1,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Lokasi Akurat Transparan",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.color_FFFFFF,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/ic_why_four.webp",
                                            width: 58,
                                            height: 55,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              color: AppColors.color_008B8B,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Special Thanks",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.color_FFFFFF,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "- Supported by: PT. Agincourt Resources",
                      style: TextStyle(
                          fontSize: 10, color: AppColors.color_FFFFFF),
                    ),
                    Text(
                      "- Design by: DaurUang by Dimas Ardiansyah lisensi CC BY 4.0.",
                      style: TextStyle(
                          fontSize: 10, color: AppColors.color_FFFFFF),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
