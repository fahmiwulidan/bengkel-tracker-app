import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_data_service.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HomeHero extends StatefulWidget {
  const HomeHero({super.key});

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  String _name =
      'Pengguna'; // Nilai default sebelum data dari memori internal terbaca
  String _role = 'user';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi async untuk menangkap data nama dan role hasil login tadi
  Future<void> _loadUserData() async {
    final profile = await LocalDataService.getProfile();
    setState(() {
      _name = profile['name'] ?? 'Pengguna';
      _role = profile['role'] ?? 'user';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika data SharedPreferences masih dibaca, beri widget kosong atau placeholder halus
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Container(color: AppColors.navy),
          Positioned(
            right: -33,
            top: -5,
            child: Container(
              width: 153,
              height: 153,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange12,
              ),
            ),
          ),
          Positioned(
            left: 70,
            bottom: -21,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange12,
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 34,
            child: Image.asset(AppAssets.bell, width: 42, height: 42),
          ),
          Positioned(
            left: 20,
            top: 77,
            child: RichText(
              text: const TextSpan(
                style: AppTextStyles.logo,
                children: [
                  TextSpan(text: 'Bengkel'),
                  TextSpan(
                    text: 'Track',
                    style: TextStyle(color: AppColors.orange),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 116,
            // Menampilkan nama dinamis berdasarkan akun yang sukses terautentikasi
            child: Text(
              'Halo, ${_name.toUpperCase()}!',
              style: AppTextStyles.body,
            ),
          ),
          Positioned(
            left: 20,
            top: 135,
            child: Text(
              "Butuh Bantuan Mekanik?",
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 163,
            child: Container(
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: AppColors.orange20,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: AppColors.peach, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Lamongan, Jawa Timur',
                    style: TextStyle(
                      color: AppColors.peach,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
