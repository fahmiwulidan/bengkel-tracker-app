import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class NearbyWorkshopTile extends StatelessWidget {
  const NearbyWorkshopTile({
    super.key,
    required this.asset,
    required this.title,
    required this.address,
    required this.distance,
    required this.rating,
    required this.tags,
    this.onTap,
  });

  final String asset;
  final String title;
  final String address;
  final String distance;
  final String rating;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool useLightLogoBg =
      asset == AppAssets.bengkelMusiman || asset == AppAssets.gopalGarage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 92,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFEDEAE6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: useLightLogoBg ? AppColors.white : Colors.black,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  asset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: tags
                      .map(
                        (tag) => Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 9, color: AppColors.gray),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 11)),
                  Text(
                    rating,
                    style: const TextStyle(fontSize: 11, color: AppColors.darkGray),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
