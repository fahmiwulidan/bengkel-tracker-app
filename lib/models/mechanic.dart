class Mechanic {
  const Mechanic({
    required this.id,
    required this.userId,
    required this.workshopId,
    required this.status,
    required this.name,
    required this.phone,
    required this.email,
    required this.workshopName,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  final int id;
  final int userId;
  final int workshopId;
  final String status;
  final String name;
  final String? phone;
  final String? email;
  final String workshopName;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  bool get isOpen => status == 'open';

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      workshopId: int.parse(json['workshop_id'].toString()),
      status: json['status']?.toString() ?? 'close',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      workshopName: json['workshop_name']?.toString() ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      distanceKm: json['distance_km'] != null
          ? double.parse(json['distance_km'].toString())
          : null,
    );
  }
}