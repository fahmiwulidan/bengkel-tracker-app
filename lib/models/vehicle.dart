class Vehicle {
  final String id;
  final String type;
  final String brand;
  final String model;
  final String year;
  final String transmission;
  final String color;
  final String platePrefix;
  final String plateNumber;
  final bool isMain;

  const Vehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.transmission,
    required this.color,
    required this.platePrefix,
    required this.plateNumber,
    required this.isMain,
  });

  String get title {
    final parts = [brand, model].where((value) => value.trim().isNotEmpty);
    final combined = parts.join(' ');
    if (combined.isNotEmpty) return combined;
    final fallback = type.trim().isNotEmpty ? type.trim() : 'Kendaraan';
    return plateNumber.trim().isEmpty ? fallback : plateNumber.trim();
  }

  String get plate {
    final prefix = platePrefix.trim();
    final number = plateNumber.trim();
    if (prefix.isEmpty) return number;
    if (number.isEmpty) return prefix;
    return '$prefix $number';
  }

  Vehicle copyWith({
    String? id,
    String? type,
    String? brand,
    String? model,
    String? year,
    String? transmission,
    String? color,
    String? platePrefix,
    String? plateNumber,
    bool? isMain,
  }) => Vehicle(
    id: id ?? this.id,
    type: type ?? this.type,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    transmission: transmission ?? this.transmission,
    color: color ?? this.color,
    platePrefix: platePrefix ?? this.platePrefix,
    plateNumber: plateNumber ?? this.plateNumber,
    isMain: isMain ?? this.isMain,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'brand': brand,
    'model': model,
    'year': year,
    'transmission': transmission,
    'color': color,
    'platePrefix': platePrefix,
    'plateNumber': plateNumber,
    'isMain': isMain,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: (json['id'] ?? '').toString(),
    type: (json['type'] ?? '').toString(),
    brand: (json['brand'] ?? '').toString(),
    model: (json['model'] ?? '').toString(),
    year: (json['year'] ?? '').toString(),
    transmission: (json['transmission'] ?? '').toString(),
    color: (json['color'] ?? '').toString(),
    platePrefix: (json['platePrefix'] ?? '').toString(),
    plateNumber: (json['plateNumber'] ?? '').toString(),
    isMain: json['isMain'] == true,
  );
}
