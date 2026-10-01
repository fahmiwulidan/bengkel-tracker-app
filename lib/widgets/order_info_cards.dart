import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String? address;
  final double? latitude;
  final double? longitude;

  String get _locationText {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }

    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }

    return 'Menggunakan lokasi GPS kamu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: appShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.location_on,
              size: 17,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Lokasi Kamu (GPS)',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 22,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'Live',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PriceCard extends StatelessWidget {
  const PriceCard({
    super.key,
    this.price = 25000,
  });

  final int price;

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biaya Dasar',
            style: TextStyle(
              color: Color(0xFFFFD6C3),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatRupiah(price),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.06,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Biaya dasar adalah biaya penjemputan',
            style: TextStyle(
              color: Color(0xFFFFD6C3),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}