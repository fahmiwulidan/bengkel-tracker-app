import '../models/mechanic.dart';
import 'api.dart'; // Pastikan import mengarah ke file ApiService yang ada getter 'client'

class MechanicService {
  // Alamat baseUrl tidak perlu ditulis ulang di sini karena sudah di-handle terpusat oleh ApiService.client

  /// Mengambil data mekanik berdasarkan ID Bengkel
  static Future<List<Mechanic>> getMechanicsByWorkshop(int workshopId) async {
    try {
      // Menggunakan ApiService.client terpusat yang otomatis membawa Token Bearer
      final response = await ApiService.client.get(
        '/workshops/$workshopId/mechanics',
      );

      if (response.statusCode == 200) {
        // PERBAIKAN: Dio otomatis mengonversi data menjadi Map/List, TIDAK PERLU jsonDecode lagi.
        final result = response.data;
        final List data = result['data'] ?? [];

        return data.map((item) => Mechanic.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data mekanik bengkel');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan server: $e');
    }
  }

  /// Mengambil data mekanik terdekat berdasarkan koordinat GPS spasial (PostGIS)
  static Future<List<Mechanic>> getNearestMechanics({
    required double lat,
    required double lng,
  }) async {
    try {
      // PERBAIKAN: Migrasi dari package 'http' ke 'ApiService.client' (Dio) agar seragam dan aman
      final response = await ApiService.client.get(
        '/mechanics/nearest',
        queryParameters: {'lat': lat, 'lng': lng},
      );

      if (response.statusCode == 200) {
        // Mengambil data langsung dari response body Dio
        final result = response.data;
        final List data = result['data'] ?? [];

        return data.map((item) => Mechanic.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data mekanik terdekat');
      }
    } catch (e) {
      throw Exception('Gagal memuat maps mekanik terdekat: $e');
    }
  }
}
