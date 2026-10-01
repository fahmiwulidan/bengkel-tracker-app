import 'package:dio/dio.dart';
import 'api.dart';

class PaymentService {
  /// Fungsi untuk membuat Invoice ke Xendit melalui Backend Laravel
  static Future<String> createInvoice({
    required String payerEmail,
    required int orderId,
    required String method,
    required int amount,
  }) async {
    try {
      // Menembak endpoint invoice Xendit menggunakan ApiService.client terpusat
      final response = await ApiService.client.post(
        'https://bengkel-tracker.onrender.com/api/payments/create-invoice',
        data: {
          "payer_email": payerEmail,
          "order_id": orderId,
          "method": method,
          "amount": amount,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Mengembalikan checkout_url dari struktur response API Anda
        return data['data']['checkout_url']?.toString() ?? '';
      } else {
        throw Exception('Gagal membuat invoice pembayaran.');
      }
    } on DioException catch (e) {
      String errorMsg = "Terjadi kesalahan pada sistem pembayaran.";
      if (e.response != null && e.response?.data['message'] != null) {
        errorMsg = e.response?.data['message'];
      }
      throw Exception(errorMsg);
    }
  }
}
