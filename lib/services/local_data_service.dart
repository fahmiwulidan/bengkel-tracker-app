import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle.dart';

class LocalDataService {
  static const _profileKey = 'profile';
  static const _vehicleKey = 'mainVehicle';
  static const _vehiclesKey = 'vehicles';

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};

    return decoded.map((key, value) => MapEntry('$key', '$value'));
  }

  static Future<void> saveProfile({
    required String id, // ✅ TAMBAHKAN PARAMETER ID DI SINI
    required String name,
    required String email,
    required String phone,
    required String photoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'id': id, // ✅ SIMPAN ID KE DALAM LOCAL DATA STORAGE
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photoPath,
    };
    await prefs.setString(_profileKey, jsonEncode(data));
  }

  static Future<Vehicle?> getMainVehicle() async {
    final vehicles = await getVehicles();
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere(
      (vehicle) => vehicle.isMain,
      orElse: () => vehicles.first,
    );
  }

  static Future<void> saveMainVehicle(Vehicle vehicle) async {
    final updated = vehicle.isMain ? vehicle : vehicle.copyWith(isMain: true);
    await upsertVehicle(updated);
  }

  static Future<void> clearMainVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehicleKey);
    await prefs.remove(_vehiclesKey);
  }

  static Future<List<Vehicle>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getString(_vehiclesKey);

    if (rawList != null && rawList.isNotEmpty) {
      final decoded = jsonDecode(rawList);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Vehicle.fromJson)
            .toList();
      }
    }

    final legacy = prefs.getString(_vehicleKey);
    if (legacy != null && legacy.isNotEmpty) {
      final decoded = jsonDecode(legacy);
      if (decoded is Map<String, dynamic>) {
        return [Vehicle.fromJson(decoded)];
      }
    }

    return [];
  }

  static Future<void> upsertVehicle(Vehicle vehicle) async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await getVehicles();

    final existingIndex = vehicles.indexWhere((item) => item.id == vehicle.id);
    if (existingIndex >= 0) {
      vehicles[existingIndex] = vehicle;
    } else {
      vehicles.add(vehicle);
    }

    if (vehicle.isMain) {
      for (var i = 0; i < vehicles.length; i += 1) {
        if (vehicles[i].id != vehicle.id && vehicles[i].isMain) {
          vehicles[i] = vehicles[i].copyWith(isMain: false);
        }
      }
    }

    if (vehicles.isNotEmpty && !vehicles.any((item) => item.isMain)) {
      vehicles[0] = vehicles[0].copyWith(isMain: true);
    }

    await prefs.setString(
      _vehiclesKey,
      jsonEncode(vehicles.map((item) => item.toJson()).toList()),
    );

    final mainVehicle = vehicles.firstWhere(
      (item) => item.isMain,
      orElse: () => vehicles.first,
    );
    await prefs.setString(_vehicleKey, jsonEncode(mainVehicle.toJson()));
  }

  static Future<void> deleteVehicle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await getVehicles();
    vehicles.removeWhere((item) => item.id == id);

    if (vehicles.isNotEmpty && !vehicles.any((item) => item.isMain)) {
      vehicles[0] = vehicles[0].copyWith(isMain: true);
    }

    await prefs.setString(
      _vehiclesKey,
      jsonEncode(vehicles.map((item) => item.toJson()).toList()),
    );

    if (vehicles.isEmpty) {
      await prefs.remove(_vehicleKey);
      return;
    }

    final mainVehicle = vehicles.firstWhere(
      (item) => item.isMain,
      orElse: () => vehicles.first,
    );
    await prefs.setString(_vehicleKey, jsonEncode(mainVehicle.toJson()));
  }

  static Future<void> setMainVehicle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await getVehicles();
    if (vehicles.isEmpty) return;

    for (var i = 0; i < vehicles.length; i += 1) {
      vehicles[i] = vehicles[i].copyWith(isMain: vehicles[i].id == id);
    }

    await prefs.setString(
      _vehiclesKey,
      jsonEncode(vehicles.map((item) => item.toJson()).toList()),
    );

    final mainVehicle = vehicles.firstWhere(
      (item) => item.isMain,
      orElse: () => vehicles.first,
    );
    await prefs.setString(_vehicleKey, jsonEncode(mainVehicle.toJson()));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Hapus data profil JSON dan role pengguna
    await prefs.remove(_profileKey); // Menghapus key 'profile'
    await prefs.remove('role'); // Menghapus key 'role'

    // 2. Hapus data kendaraan utama yang tersimpan
    await prefs.remove(_vehicleKey);
    await prefs.remove(_vehiclesKey);
  }
}
