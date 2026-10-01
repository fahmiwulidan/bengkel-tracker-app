import '../models/workshop.dart';
import 'api.dart';

class WorkshopService {

  static Future<List<Workshop>> getNearestWorkshops({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await ApiService.client.get(
        '/workshops/nearest',
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      final result = response.data;
      final List data = result['data'] ?? [];

      return data.map((item) => Workshop.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data bengkel terdekat: $e');
    }
  }

  static Future<List<Workshop>> getAllWorkshops() async {
    try {
      final response = await ApiService.client.get(
        '/workshops',
      );

      final result = response.data;
      final List data = result['data'] ?? [];

      return data.map((item) => Workshop.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data bengkel');
    }
  }

  static Future<List<Workshop>> getTopRatedWorkshops({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await ApiService.client.get(
        '/workshops/top-rated',
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      final result = response.data;
      final List data = result['data'] ?? [];

      return data.map((item) => Workshop.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data bengkel rating tertinggi');
    }
  }

  static Future<List<Workshop>> getFilteredWorkshops({
    required double lat,
    required double lng,
    double radius = 5,
    double? minRating,
    bool? isOpen,
  }) async {
    try {
      final response = await ApiService.client.get(
        '/workshops/filter',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
          if (minRating != null) 'min_rating': minRating,
          if (isOpen != null) 'is_open': isOpen ? 1 : 0,
        },
      );

      final result = response.data;
      final List data = result['data'] ?? [];

      return data.map((item) => Workshop.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil filter bengkel');
    }
  }
}