import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({
    super.key,
    required this.asset,
    required this.label,
    this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isMogok = label == 'Mogok';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 69,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: isMogok ? 2.0 : 1.0,
              child: Image.asset(
                asset,
                width: isMogok ? 34 : 30,
                height: isMogok ? 34 : 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceOption extends StatelessWidget {
  const ServiceOption({
    super.key,
    required this.asset,
    required this.title,
    this.selected = false,
    this.isVector = false,
    this.onTap,
  });

  final String asset;
  final String title;
  final bool selected;
  final bool isVector;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isMogokMesin = title == 'Mogok / Mesin';
    final bool isGantiOli = title == 'Ganti Oli';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: isMogokMesin ? 2.0 : 1.0,
              child: Image.asset(
                asset,
                width: isGantiOli ? 38 : 34,
                height: isGantiOli ? 38 : 34,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Syne',
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Mulai Rp 25.000',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: AppColors.gray,
                fontFamily: 'Syne',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
