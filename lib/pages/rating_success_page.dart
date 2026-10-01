import 'package:flutter/material.dart';

import 'home_page.dart';

class RatingSuccessPage extends StatelessWidget {
  final int rating;
  final String review;

  const RatingSuccessPage({
    super.key,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08291E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 24),
          child: Column(
            children: [
              const Spacer(),
              _buildSuccessIcon(),
              const SizedBox(height: 28),
              const Text(
                'Terima Kasih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rating kamu berhasil dikirim.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              _buildRatingCard(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ke Beranda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 142,
          height: 142,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7043).withOpacity(.08),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 102,
          height: 102,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7043).withOpacity(.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFFF7043),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, color: Color(0xFFFFD447), size: 36),
        ),
      ],
    );
  }

  Widget _buildRatingCard() {
    final shownReview = review.isEmpty ? 'Tidak ada ulasan tambahan.' : review;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          const Text(
            'Bengkel Pak Slamet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final active = index < rating;

              return Icon(
                active ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFC043),
                size: 22,
              );
            }),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              shownReview,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
