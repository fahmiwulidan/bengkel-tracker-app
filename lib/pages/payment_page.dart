import 'dart:async'; // 1. WAJIB TAMBAH: Untuk mengaktifkan objek Timer Polling
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../services/local_data_service.dart';
import '../services/api.dart'; // Impor ApiService.client
import 'payment_success_page.dart';

class PaymentPage extends StatefulWidget {
  final int orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'qris';
  bool _isProcessing = false;
  final int servicePrice = 25000;
  final int adminPrice = 0;
  int get totalPayment => servicePrice + adminPrice;

  // 2. TAMBAHKAN VARIABEL KONTROL TIMBER DI SINI
  Timer? _pollingTimer;
  String? _currentXenditId;

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  void dispose() {
    // 3. WAJIB: Batalkan timer saat user keluar dari halaman agar memori HP/Laptop tidak bocor
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _payNow() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final userProfile = await LocalDataService.getProfile();
      final String userEmail =
          userProfile['email'] ?? 'pelanggan@bengkeltrack.com';

      // AMBIL URL & PORT REALTIME YANG SEDANG BERJALAN DI BROWSER KAMU SAAT INI
      final String currentBrowserUrl = Uri.base.toString();

      // 1. Hit API pembuatan invoice ke Render
      final response = await ApiService.client.post(
        'https://bengkel-tracker.onrender.com/api/payments/create-invoice',
        data: {
          "payer_email": userEmail,
          "order_id": widget.orderId,
          "method": selectedPayment,
          "amount": totalPayment,
          "redirect_url": currentBrowserUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        final String checkoutUrl =
            resData['data']['checkout_url']?.toString() ?? '';

        // Simpan xendit_id dari response pembuat invoice untuk modal pencarian webhook nanti
        _currentXenditId = resData['data']['xendit_id']?.toString();

        if (checkoutUrl.isEmpty || _currentXenditId == null) {
          throw Exception('Data Invoice Xendit tidak lengkap.');
        }

        // 2. Buka Tab Baru Pembayaran Xendit
        final Uri url = Uri.parse(checkoutUrl);
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // 3. NYALAKAN MESIN POLLING: Cek status ke webhook server setiap 3 detik sekali
        _startPaymentPolling();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses transaksi: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // 4. LOGIKA UTAMA POLLING STATUS WEBHOOK
  void _startPaymentPolling() {
    // Batalkan timer lama jika ada yang masih berjalan secara tidak sengaja
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_currentXenditId == null) return;

      try {
        // Tembak endpoint webhook yang sudah Anda siapkan (Bearer token otomatis disisipkan oleh api.dart)
        final response = await ApiService.client.post(
          'https://bengkel-tracker.onrender.com/api/payments/webhook',
          data: {"xendit_id": _currentXenditId},
        );

        if (response.statusCode == 200) {
          final status =
              response.data['data']['status']?.toString().toUpperCase();

          // Jika status sudah LUNAS (PAID)
          if (status == 'PAID') {
            _pollingTimer?.cancel(); // Hentikan timer berkala langsung

            if (!mounted) return;

            // Ambil nilai integer murni untuk mengamankan kompilasi JavaScript Web
            final int fixedTotalValue = totalPayment.toInt();

            // REDIRECT: Pindah ke PaymentSuccessPage dengan tipe data yang aman
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PaymentSuccessPage(
                      orderId: widget.orderId,
                      totalPayment:
                          fixedTotalValue, // 🌟 PERBAIKAN: Gunakan nilai variabel yang sudah di .toInt()
                      paymentMethod: selectedPayment,
                    ),
              ),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembayaran Berhasil Dikonfirmasi!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        // Biarkan silent error jika RTO/Koneksi goyang saat mempolling, agar tidak mengganggu UI user
        debugPrint('Sedang memantau status pembayaran...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMechanicCard(),
                    const SizedBox(height: 18),
                    _sectionTitle('SCAN QRIS'),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      value: 'qris',
                      icon: Icons.qr_code_2,
                      title: 'QRIS',
                      subtitle: 'Scan pakai semua dompet digital',
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('DOMPET DIGITAL'),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      value: 'gopay',
                      icon: Icons.account_balance_wallet,
                      title: 'GOPAY',
                      subtitle: 'Metode Instan e-Wallet',
                    ),
                    _buildPaymentOption(
                      value: 'ovo',
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'OVO',
                      subtitle: 'Metode Instan e-Wallet',
                    ),
                    _buildPaymentOption(
                      value: 'dana',
                      icon: Icons.wallet,
                      title: 'DANA',
                      subtitle: 'Metode Instan e-Wallet',
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('VIRTUAL ACCOUNT'),
                    const SizedBox(height: 8),
                    _buildPaymentOption(
                      value: 'bca',
                      icon: Icons.account_balance,
                      title: 'BCA Virtual Account',
                      subtitle: 'Transfer ATM / m-Banking',
                    ),
                    _buildPaymentOption(
                      value: 'mandiri',
                      icon: Icons.account_balance,
                      title: 'Mandiri Virtual Account',
                      subtitle: 'Transfer ATM / m-Banking',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomPayment(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 38, 14, 18),
      decoration: const BoxDecoration(color: Color(0xFF10163A)),
      child: Row(
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
                'Pilih Pembayaran',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildMechanicCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.engineering, color: Color(0xFFFF7043)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bengkel Pak Slamet',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Mogok / Mesin',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(servicePrice),
            style: const TextStyle(
              color: Color(0xFFFF7043),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: .5,
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool active = selectedPayment == value;

    return GestureDetector(
      onTap: () {
        if (_isProcessing) return;
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF2ED) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFFFF7043) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    active
                        ? const Color(0xFFFF7043).withOpacity(.12)
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    active ? const Color(0xFFFF7043) : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              active ? Icons.check_circle : Icons.radio_button_unchecked,
              color: active ? const Color(0xFFFF7043) : const Color(0xFFD1D5DB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPayment() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Bayar',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatRupiah(totalPayment),
                    style: const TextStyle(
                      color: Color(0xFFFF7043),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _isProcessing ? null : _payNow, // Disable jika loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  disabledBackgroundColor: AppColors.gray,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isProcessing
                      ? 'Memproses...'
                      : 'Bayar via ${selectedPayment.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
