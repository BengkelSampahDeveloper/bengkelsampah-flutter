import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:bengkelsampah_app/constants/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  Widget _buildHomeIcon(bool isSelected) {
    return Image.asset(
      isSelected
          ? 'assets/images/ic_home_active.webp'
          : 'assets/images/ic_home_inactive.webp',
      width: 24,
      height: 24,
    );
  }

  Widget _buildPilahkuIcon(bool isSelected) {
    return Image.asset(
      isSelected
          ? 'assets/images/ic_pilahku_active.webp'
          : 'assets/images/ic_pilahku_inactive.webp',
      width: 24,
      height: 24,
    );
  }

  Widget _buildJejakkuIcon(bool isSelected) {
    return Image.asset(
      isSelected
          ? 'assets/images/ic_jejakku_active.webp'
          : 'assets/images/ic_jejakku_inactive.webp',
      width: 24,
      height: 24,
    );
  }

  Widget _buildAkunkuIcon(bool isSelected) {
    return Image.asset(
      isSelected
          ? 'assets/images/ic_akunku_active.webp'
          : 'assets/images/ic_akunku_inactive.webp',
      width: 24,
      height: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.color_0FB7A6.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        selectedItemColor: AppColors.color_0FB7A6,
        unselectedItemColor: AppColors.color_6C919C,
        selectedColorOpacity: 0.1,
        itemShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        itemPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        items: [
          SalomonBottomBarItem(
            icon: _buildHomeIcon(currentIndex == 0),
            title: const Text(
              'Beranda',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedColor: AppColors.color_0FB7A6,
          ),
          SalomonBottomBarItem(
            icon: _buildPilahkuIcon(currentIndex == 1),
            title: const Text(
              'Pilahku',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedColor: AppColors.color_0FB7A6,
          ),
          SalomonBottomBarItem(
            icon: _buildJejakkuIcon(currentIndex == 2),
            title: const Text(
              'jejakku',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedColor: AppColors.color_0FB7A6,
          ),
          SalomonBottomBarItem(
            icon: _buildAkunkuIcon(currentIndex == 3),
            title: const Text(
              'Akunku',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedColor: AppColors.color_0FB7A6,
          ),
        ],
      ),
    );
  }
}
