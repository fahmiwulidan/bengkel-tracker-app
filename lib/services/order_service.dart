import '../models/order_tracking.dart';
import 'api.dart';

class OrderService {
  static Future<OrderTracking> getTracking(int orderId) async {
    final response = await ApiService.client.get(
      '/orders/$orderId/tracking',
    );

    if (response.statusCode == 200) {
      return OrderTracking.fromJson(
        response.data['data'],
      );
    } else {
      throw Exception(
        'Gagal mengambil data tracking order',
      );
    }
  }

  static Future<int> createOrder({
    required int userId,
    required int workshopId,
    required int mechanicId,
    required String problem,
    required double userLat,
    required double userLng,
  }) async {
    try {
      final response = await ApiService.client.post(
        '/orders',
        data: {
          'user_id': userId,
          'workshop_id': workshopId,
          'mechanic_id': mechanicId,
          'problem': problem,
          'user_lat': userLat,
          'user_lng': userLng,
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return int.parse(
          response.data['data']['id'].toString(),
        );
      }

      throw Exception(
        'Gagal membuat order',
      );
    } catch (e) {
      throw Exception(
        'Gagal membuat order: $e',
      );
    }
  }
}