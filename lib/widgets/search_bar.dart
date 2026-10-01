import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BengkelSearchBar extends StatelessWidget {
  const BengkelSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 13, right: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 26),
          const SizedBox(width: 7),
          const Expanded(
            child: Text(
              'Cari bengkel, layanan...',
              style: TextStyle(
                color: AppColors.gray,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orange,
            ),
            child: const Icon(Icons.menu_rounded, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
