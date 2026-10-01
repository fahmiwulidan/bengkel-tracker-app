class OrderTracking {
  const OrderTracking({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.serviceType,
    required this.serviceMode,
    required this.problem,
    required this.basicCost,
    required this.totalCost,
    required this.userName,
    required this.userPhone,
    required this.userLatitude,
    required this.userLongitude,
    required this.workshopName,
    required this.mechanicId,
    required this.mechanicStatus,
    required this.mechanicName,
    required this.mechanicPhone,
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    required this.mechanicDistanceKm,
  });

  final int id;
  final String orderCode;
  final String status;
  final String serviceType;
  final String serviceMode;
  final String? problem;
  final int basicCost;
  final int totalCost;

  final String userName;
  final String? userPhone;
  final double userLatitude;
  final double userLongitude;

  final String? workshopName;

  final int? mechanicId;
  final String? mechanicStatus;
  final String? mechanicName;
  final String? mechanicPhone;
  final double? mechanicLatitude;
  final double? mechanicLongitude;
  final double? mechanicDistanceKm;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: int.parse(json['id'].toString()),
      orderCode: json['order_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      serviceMode: json['service_mode']?.toString() ?? '',
      problem: json['problem']?.toString(),
      basicCost: int.parse(json['basic_cost'].toString()),
      totalCost: int.parse(json['total_cost'].toString()),
      userName: json['user_name']?.toString() ?? '',
      userPhone: json['user_phone']?.toString(),
      userLatitude: double.parse(json['user_latitude'].toString()),
      userLongitude: double.parse(json['user_longitude'].toString()),
      workshopName: json['workshop_name']?.toString(),
      mechanicId: json['mechanic_id'] != null
          ? int.parse(json['mechanic_id'].toString())
          : null,
      mechanicStatus: json['mechanic_status']?.toString(),
      mechanicName: json['mechanic_name']?.toString(),
      mechanicPhone: json['mechanic_phone']?.toString(),
      mechanicLatitude: json['mechanic_latitude'] != null
          ? double.parse(json['mechanic_latitude'].toString())
          : null,
      mechanicLongitude: json['mechanic_longitude'] != null
          ? double.parse(json['mechanic_longitude'].toString())
          : null,
      mechanicDistanceKm: json['mechanic_distance_km'] != null
          ? double.parse(json['mechanic_distance_km'].toString())
          : null,
    );
  }
}