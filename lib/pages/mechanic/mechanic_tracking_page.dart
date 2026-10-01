import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/local_data_service.dart';
import '../chat_detail_page.dart';

import '../../constants/app_colors.dart';

class MechanicTrackingPage extends StatefulWidget {
  final bool hasActiveOrder;
  final int orderId;

  const MechanicTrackingPage({
    super.key,
    this.hasActiveOrder = true,
    this.orderId = 1,
  });

  @override
  State<MechanicTrackingPage> createState() => _MechanicTrackingPageState();
}

class _MechanicTrackingPageState extends State<MechanicTrackingPage> {
  // Controller untuk menggerakkan peta
  final MapController _mapController = MapController();
  
  // Stream untuk memantau pergerakan GPS
  StreamSubscription<Position>? _positionStream;

  Map<String, dynamic>? _orderData;
  LatLng? _customerPosition;
  LatLng? _mechanicPosition;
  List<LatLng> _routePoints = [];
  DateTime? _lastRouteUpdate;

  bool _isLoading = true;
  String _distanceText = 'Menghitung...';
  String _etaText = '...';

  int _currentUserId = 1;
  double _heading = 0;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    // Wajib dimatikan agar GPS tidak terus menyala di background
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    try {
      final profile = await LocalDataService.getProfile();

      if (profile.containsKey('id')) {
        _currentUserId =
            int.tryParse(profile['id'].toString()) ?? 1;
      }
      // 1. Ambil data order (Posisi Pelanggan) dari API
      final response = await ApiService.client.get(
        '/orders/${widget.orderId}/tracking',
      );

      final data = response.data['data'];
      _orderData = data;
      _customerPosition = LatLng(
        double.parse(data['user_latitude'].toString()),
        double.parse(data['user_longitude'].toString()),
      );

      // 2. Mulai Lacak GPS Mekanik
      await _startLocationTracking();
      await _loadRoute();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startLocationTracking() async {
    // Cek status dan izin GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Ambil lokasi awal
    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _updateTrackingInfo(initialPosition);

    // Pantau pergerakan (Real-time update)
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update jika bergerak 5 meter
      ),
    ).listen((Position position) {
      _updateTrackingInfo(position);
    });
  }

  void _updateTrackingInfo(Position position) {

    _sendLocationToServer(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _mechanicPosition = LatLng(position.latitude, position.longitude);
      _heading = position.heading;
      if (_lastRouteUpdate == null ||
          DateTime.now()
                  .difference(_lastRouteUpdate!)
                  .inSeconds >
              5) {

        _lastRouteUpdate = DateTime.now();
        _loadRoute();
      }

      // Otomatis geser peta mengikuti mekanik
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          _mechanicPosition!,
          _mapController.camera.zoom,
        );
      });

      // Hitung Jarak
      if (_customerPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _customerPosition!.latitude,
          _customerPosition!.longitude,
        );

        // Format Jarak
        if (distanceInMeters >= 1000) {
          _distanceText = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
        } else {
          _distanceText = '${distanceInMeters.round()} m';
        }

        // Estimasi Waktu (Asumsi kecepatan rata-rata 30 km/jam)
        double speedKmh = 30.0;
        double hours = (distanceInMeters / 1000) / speedKmh;
        int minutes = (hours * 60).round();

        if (minutes < 1) {
          _etaText = 'Kurang dari 1 menit';
        } else {
          _etaText = '$minutes menit';
        }
      }
    });
  }

  Future<void> _sendLocationToServer(
    double lat,
    double lng,
  ) async {
    try {

      final response = await ApiService.client.patch(
        '/mechanics/${_orderData?['mechanic_id']}/location',
        data: {
          'lat': lat,
          'lng': lng,
        },
      );

      print(response.statusCode);
      print(response.data);

    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadRoute() async {
    if (_mechanicPosition == null ||
        _customerPosition == null) {
      return;
    }

    try {
      final response = await Dio().get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_mechanicPosition!.longitude},${_mechanicPosition!.latitude};'
        '${_customerPosition!.longitude},${_customerPosition!.latitude}',
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      final coordinates =
          response.data['routes'][0]['geometry']['coordinates'];

      setState(() {
        _routePoints =
            coordinates.map<LatLng>((coord) {
              return LatLng(
                coord[1].toDouble(),
                coord[0].toDouble(),
              );
            }).toList();
      });
    } catch (e) {
      debugPrint('OSRM ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_orderData == null || _customerPosition == null || _mechanicPosition == null) {
      return _buildEmptyTrackingPage(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController, // Tambahkan controller
              options: MapOptions(
                initialCenter: _mechanicPosition!, // Center ke mekanik
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),

                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _mechanicPosition!,
                      width: 46,
                      height: 46,
                      child: _buildMechanicMarker(),
                    ),
                    Marker(
                      point: _customerPosition!,
                      width: 46,
                      height: 46,
                      child: _buildCustomerMarker(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _buildHeader(context),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 92,
            child: _buildOrderInfoCard(_orderData!),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(context, _orderData!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrackingPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 42, 14, 22),
              color: const Color(0xFF10163A),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
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
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7043).withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_off_rounded,
                          color: Color(0xFFFF7043),
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Belum ada order aktif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tracking akan tersedia setelah Anda menerima order dari pelanggan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 42, 12, 30),
      decoration: const BoxDecoration(color: Color(0xFF10163A)),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Material(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tracking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 42,
            height: 42,
            child: Material(
              color: const Color(0xFFFF7043),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${data['order_code']}',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Diterima',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  data['user_name'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.location_on, color: Colors.red, size: 13),
              const SizedBox(width: 4),
              Text(
                '${data['user_latitude']}, ${data['user_longitude']}',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['user_phone'] ?? '',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dalam Perjalanan',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ETA $_etaText • $_distanceText', // Update text menggunakan State
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final response = await ApiService.client.post(
                    '/orders/${widget.orderId}/arrive',
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mekanik tiba di lokasi'),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('ERROR ARRIVE: $e');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal update status: $e'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Tiba di Lokasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final response = await ApiService.client.post(
                    '/orders/${widget.orderId}/complete',
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Servis selesai'),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('ERROR COMPLETE: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Selesai Servis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () async {
                try {
                  final response = await ApiService.client.post(
                    '/chat-rooms',
                    data: {
                      'order_id': widget.orderId,
                    },
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {

                    final int roomChatId =
                        response.data['data']['id'];

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          chatRoomId: roomChatId,
                          currentUserId: _currentUserId,
                          receiverName:
                              data['user_name'] ?? 'Pelanggan',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint(
                    "Gagal memuat room chat pelanggan dari tracking: $e",
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Chat Pelanggan',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMechanicMarker() {
  return Transform.rotate(
    angle: _heading * math.pi / 180,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/bengkel.jpg',
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

  static Widget _buildCustomerMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.35),
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
    );
  }
}