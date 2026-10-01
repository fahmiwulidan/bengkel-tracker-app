import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'rating_page.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    const int callFee = 25000;
    const int serviceFee = 50000;
    const int sparepartFee = 25000;
    const int totalFee = callFee + serviceFee + sparepartFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, totalFee),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildInvoiceCard(
                      callFee: callFee,
                      serviceFee: serviceFee,
                      sparepartFee: sparepartFee,
                      totalFee: totalFee,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoBox(),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RatingPage(),
                            ),
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
                          'Beri Rating',
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalFee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 22),
      decoration: const BoxDecoration(color: Color(0xFF10163A)),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Material(
                  color: Colors.white.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Invoice',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(totalFee),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'SELESAI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard({
    required int callFee,
    required int serviceFee,
    required int sparepartFee,
    required int totalFee,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DETAIL ORDER'),
          const SizedBox(height: 12),
          _row('No. Invoice', '#INV-20240521-001'),
          _row('No. Order', '#ORD-20240521-001'),
          _row('Bengkel', 'Bengkel Pak Slamet'),
          _row('Layanan', 'Mogok / Mesin'),
          _row('Tanggal', '22 Apr 2026 · 09:45'),
          _row('Status', 'Selesai'),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          _sectionTitle('RINCIAN BIAYA'),
          const SizedBox(height: 12),
          _row('Biaya panggilan aplikasi', _formatRupiah(callFee)),
          _row('Biaya servis dari admin', _formatRupiah(serviceFee)),
          _row('Biaya sparepart', _formatRupiah(sparepartFee)),
          _row('Metode servis', 'Cash di luar aplikasi'),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Akhir',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _formatRupiah(totalFee),
                style: const TextStyle(
                  color: Color(0xFFFF7043),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0C7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFF7043), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Biaya servis dan sparepart diinput oleh admin setelah servis selesai. Pembayaran servis dilakukan di luar aplikasi.',
              style: TextStyle(
                color: Color(0xFFC56A22),
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: .5,
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
