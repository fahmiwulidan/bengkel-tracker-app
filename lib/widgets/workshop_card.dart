import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.asset,
    required this.title,
    required this.rating,
    required this.distance,
    required this.logoWidth,
    required this.logoHeight,
    required this.isOpen,
    this.onTap,
  });

  final String asset;
  final String title;
  final String rating;
  final String distance;
  final double logoWidth;
  final double logoHeight;
  final bool isOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool useLightLogoBg =
      asset == AppAssets.bengkelMusiman || asset == AppAssets.gopalGarage;
    final String statusText = isOpen ? 'Buka' : 'Tutup';
    final Color statusBg = isOpen ? AppColors.lightGreen : const Color(0xFFFFE5E5);
    final Color statusColor = isOpen ? AppColors.green : AppColors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 154,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 88,
              width: 154,
              decoration: BoxDecoration(
                color: useLightLogoBg ? AppColors.white : Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        asset,
                        width: logoWidth,
                        height: logoHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 8,
                    child: Container(
                      height: 19,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 10, 0),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 0, 10, 11),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    distance,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}