class Workshop {
  const Workshop({
    required this.id,
    required this.asset,
    required this.title,
    required this.address,
    required this.distance,
    required this.rating,
    required this.tags,
    required this.logoWidth,
    required this.logoHeight,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String asset;
  final String title;
  final String address;
  final String distance;
  final String rating;
  final List<String> tags;
  final double logoWidth;
  final double logoHeight;
  final bool isOpen;
  final double latitude;
  final double longitude;

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],
      asset: 'assets/images/slamet.png',
      title: json['name'] ?? '',
      address: json['address'] ?? '',
      distance: json['distance_km'] != null
          ? '${json['distance_km']} km'
          : '-',
      rating: json['rating'].toString(),
      tags: [
        json['is_open'] == true ? 'Buka' : 'Tutup',
      ],
      logoWidth: 39,
      logoHeight: 36,
      isOpen: json['is_open'] == true,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}