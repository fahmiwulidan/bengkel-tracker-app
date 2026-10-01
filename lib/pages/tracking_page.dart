import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/order_tracking.dart';
import '../services/order_service.dart';
import '../services/api.dart';
import '../services/local_data_service.dart';
import '../widgets/bottom_navbar.dart';
import 'chat_detail_page.dart';
import 'chat_list_page.dart';
import 'history_page.dart';
import 'home_page.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, this.orderId = 1});

  final int orderId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late Future<OrderTracking> trackingFuture;
  Timer? refreshTimer;
  bool _isNavigatingToChat = false;

  @override
  void initState() {
    super.initState();
    trackingFuture = OrderService.getTracking(widget.orderId);
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _goHome(BuildContext context) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  // ✅ PERBAIKAN: Menambahkan parameter receiverName dinamis dari data tracking mekanik
  Future<void> _navigateToChat(
    BuildContext context,
    String mechanicName,
  ) async {
    if (_isNavigatingToChat) return;

    setState(() => _isNavigatingToChat = true);

    try {
      final profile = await LocalDataService.getProfile();
      final int currentUserId = int.tryParse(profile['id'].toString()) ?? 1;

      final response = await ApiService.client.post(
        '/chat-rooms',
        data: {'order_id': widget.orderId},
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final int chatRoomId = response.data['data']['id'];

        if (!mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => ChatDetailPage(
                  chatRoomId: chatRoomId,
                  currentUserId: currentUserId,
                  receiverName: mechanicName, // ✅ Oper nama mekanik dinamis
                ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal memuat room chat dari tracking: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghubungkan ke layanan chat.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isNavigatingToChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderTracking>(
      future: trackingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Gagal mengambil data tracking.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        final tracking = snapshot.data!;
        final String currentMechanicName =
            tracking.mechanicName ?? 'Mekanik Bengkel';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      _MapArea(tracking: tracking),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7D5D2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 17),
                                _ProgressSteps(status: tracking.status),
                                Text(
                                  'STATUS: ${tracking.status}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _CostCard(
                                  basicCost: tracking.basicCost,
                                  totalCost: tracking.totalCost,
                                  formatRupiah: _formatRupiah,
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 49,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isNavigatingToChat
                                            ? null
                                            : () => _navigateToChat(
                                              context,
                                              currentMechanicName,
                                            ), // ✅ Oper nama asli
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppColors.orange,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        _isNavigatingToChat
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'Hubungi Mekanik',
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
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
                BottomNavbar(
                  activeIndex: 2,
                  onCenterTap: () {},
                  onHomeTap: () => _goHome(context),
                  onHistoryTap:
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      ),
                  onChatTap:
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ChatListPage()),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapArea extends StatefulWidget {
  const _MapArea({required this.tracking});
  final OrderTracking tracking;

  @override
  State<_MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<_MapArea> {
  List<LatLng> routePoints = [];
  bool isRouteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void didUpdateWidget(covariant _MapArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tracking.mechanicLatitude !=
            oldWidget.tracking.mechanicLatitude ||
        widget.tracking.mechanicLongitude !=
            oldWidget.tracking.mechanicLongitude) {
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    final tracking = widget.tracking;
    final userPoint = LatLng(tracking.userLatitude, tracking.userLongitude);
    final mechanicPoint = LatLng(
      tracking.mechanicLatitude ?? tracking.userLatitude,
      tracking.mechanicLongitude ?? tracking.userLongitude,
    );

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${userPoint.longitude},${userPoint.latitude};'
        '${mechanicPoint.longitude},${mechanicPoint.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final routes = result['routes'] as List;

        if (routes.isNotEmpty) {
          final coordinates = routes.first['geometry']['coordinates'] as List;
          final points =
              coordinates.map<LatLng>((coord) {
                return LatLng(
                  double.parse(coord[1].toString()),
                  double.parse(coord[0].toString()),
                );
              }).toList();

          if (!mounted) return;
          setState(() {
            routePoints = points;
            isRouteLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Gagal mengambil route OSRM: $e');
    }

    if (!mounted) return;
    setState(() {
      routePoints = [userPoint, mechanicPoint];
      isRouteLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tracking = widget.tracking;
    final userPoint = LatLng(tracking.userLatitude, tracking.userLongitude);
    final mechanicPoint = LatLng(
      tracking.mechanicLatitude ?? tracking.userLatitude,
      tracking.mechanicLongitude ?? tracking.userLongitude,
    );

    final centerPoint = LatLng(
      (userPoint.latitude + mechanicPoint.latitude) / 2,
      (userPoint.longitude + mechanicPoint.longitude) / 2,
    );

    final mechanicName = tracking.mechanicName ?? 'Mekanik';
    final shortName = mechanicName.split(' ').take(2).join(' ');
    final polylinePoints =
        routePoints.isEmpty ? [userPoint, mechanicPoint] : routePoints;

    return SizedBox(
      height: 304,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 15.5,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bengkel_track',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 4,
                    color: AppColors.orange,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPoint,
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB879),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location,
                            size: 15,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Marker(
                    point: mechanicPoint,
                    width: 92,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.build,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              shortName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 18,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '19:22',
                style: TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.status});
  final String status;

  int get _activeStep {
    if (status == 'pending') return 2;
    if (status == 'paid') return 2;
    if (status == 'on_the_way') return 3;
    if (status == 'service') return 4;
    if (status == 'completed') return 5;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('✓', 'Order'),
      ('💳', 'Lunas'),
      ('🔧', 'Menuju'),
      ('🛠', 'Servis'),
      ('✅', 'Selesai'),
    ];
    return Row(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final active = i < _activeStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: active ? AppColors.orange : AppColors.white,
                        border: Border.all(
                          color:
                              active ? AppColors.orange : AppColors.warmBorder,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          s.$1,
                          style: TextStyle(
                            fontSize: 12,
                            color: active ? AppColors.white : AppColors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.$2,
                      style: TextStyle(
                        fontSize: 9,
                        color: active ? AppColors.orange : AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != steps.length - 1)
                Container(
                  width: 28,
                  height: 1.4,
                  color:
                      i < _activeStep - 1
                          ? AppColors.orange
                          : AppColors.warmBorder,
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  const _MechanicCard({required this.tracking, required this.onChat});
  final OrderTracking tracking;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final mechanicName = tracking.mechanicName ?? 'Belum ada mekanik';
    final mechanicStatus = tracking.mechanicStatus ?? '-';
    final distance =
        tracking.mechanicDistanceKm != null
            ? '${tracking.mechanicDistanceKm} km dari lokasi'
            : 'Jarak belum tersedia';

    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Image.asset(AppAssets.slamet, width: 39)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mechanicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Status: ${mechanicStatus.toUpperCase()}',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray),
                ),
                const SizedBox(height: 3),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _IconButton(icon: Icons.chat_bubble_outline, onTap: onChat),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warmBorder),
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({
    required this.basicCost,
    required this.totalCost,
    required this.formatRupiah,
  });

  final int basicCost;
  final int totalCost;
  final String Function(int value)
  formatRupiah; // ✅ Hapus baris 'final String Alignment;' di atas ini

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.warmBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembayaran Panggilan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const Divider(height: 20, color: AppColors.warmBorder),
          Row(
            children: [
              const Text(
                'Biaya panggilan mekanik',
                style: TextStyle(fontSize: 13, color: AppColors.darkGray),
              ),
              const Spacer(),
              Text(
                formatRupiah(basicCost),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 26, color: AppColors.warmBorder),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                formatRupiah(totalCost),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Biaya servis kendaraan akan diinformasikan oleh admin setelah pengecekan mekanik selesai.',
              style: TextStyle(
                color: Color(0xFFC56A22),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
