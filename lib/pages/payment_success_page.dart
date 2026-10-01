import 'package:flutter/material.dart';
import 'tracking_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  final int orderId;
  final int totalPayment; // Mengunci data bulat murni kiriman dari PaymentPage
  final String paymentMethod;

  const PaymentSuccessPage({
    super.key,
    required this.orderId,
    required this.totalPayment,
    required this.paymentMethod,
  });

  // Fungsi utilitas pemformat mata uang Rupiah
  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  // Konversi value string method menjadi nama estetik di UI struk
  String get paymentName {
    if (paymentMethod == 'qris') return 'QRIS';
    if (paymentMethod == 'gopay') return 'GoPay';
    if (paymentMethod == 'ovo') return 'OVO';
    if (paymentMethod == 'dana') return 'DANA';
    if (paymentMethod == 'bca') return 'BCA Virtual Account';
    if (paymentMethod == 'mandiri') return 'Mandiri Virtual Account';
    return 'Pembayaran';
  }

  void _goToTracking(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TrackingPage(orderId: orderId)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08291E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 40, 22, 24),
          child: Column(
            children: [
              const Spacer(),
              _buildSuccessIcon(),
              const SizedBox(height: 28),
              const Text(
                'Pembayaran\nBerhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Biaya panggilan mekanik sudah berhasil dibayar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _buildReceiptCard(),
              const SizedBox(height: 18),
              _buildInfoBox(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _goToTracking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Lacak Pesanan',
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
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(.08),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(.12),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 34),
        ),
      ],
    );
  }

  Widget _buildReceiptCard() {
    final now = DateTime.now();
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final String tanggalDinamis =
        '${now.day} ${months[now.month - 1]} ${now.year}';
    final String waktuDinamis =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          const Text(
            'Biaya Panggilan Mekanik',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(
              totalPayment,
            ), // Menampilkan totalPayment kiriman dengan aman tanpa crash
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _receiptRow('Metode', paymentName),
          _receiptRow('Tanggal', tanggalDinamis),
          _receiptRow('Waktu', waktuDinamis),
          _receiptRow('Status', 'Lunas'),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFFD166), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pembayaran ini hanya untuk biaya panggilan mekanik. Biaya servis akan diatur oleh admin setelah proses servis selesai.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
