import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/workshop.dart';
import '../services/workshop_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/home_hero.dart';
import '../widgets/nearby_workshop.dart';
import '../widgets/section_header.dart';
import '../widgets/service_card.dart';
import '../widgets/workshop_card.dart';
import 'service_page.dart';
import 'workshop_detail_page.dart';
import 'history_page.dart';
import 'chat_list_page.dart';
import 'profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Workshop>> futureNearestWorkshops;
  late Future<List<Workshop>> futureTopRatedWorkshops;

  String selectedFilter = 'semua';

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  double userLat = -7.1187;
  double userLng = 112.4215;

  @override
    void initState() {
      super.initState();

      futureNearestWorkshops = WorkshopService.getNearestWorkshops(
        lat: userLat,
        lng: userLng,
      );

      futureTopRatedWorkshops = WorkshopService.getTopRatedWorkshops(
        lat: userLat,
        lng: userLng,
      );

      _loadUserLocation();
    }

    @override
    void dispose() {
      searchController.dispose();
      super.dispose();
    }

  Future<void> _loadUserLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;

        futureNearestWorkshops = WorkshopService.getNearestWorkshops(
          lat: userLat,
          lng: userLng,
        );

        futureTopRatedWorkshops = WorkshopService.getTopRatedWorkshops(
          lat: userLat,
          lng: userLng,
        );
      });
    } catch (e) {
      debugPrint('Gagal mengambil lokasi user: $e');
    }
  }

  void _openOrder(BuildContext context, int serviceIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServicePage(initialServiceIndex: serviceIndex),
      ),
    );
  }

  void _openDetail(BuildContext context, String asset, Workshop workshop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkshopDetailPage(
          asset: asset,
          workshop: workshop,
        ),
      ),
    );
  }

  void _setFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == 'semua') {
        futureNearestWorkshops = WorkshopService.getNearestWorkshops(
          lat: userLat,
          lng: userLng,
        );
      } else if (filter == 'buka') {
        futureNearestWorkshops = WorkshopService.getFilteredWorkshops(
          lat: userLat,
          lng: userLng,
          radius: 5,
          isOpen: true,
        );
      } else if (filter == 'rating') {
        futureNearestWorkshops = WorkshopService.getFilteredWorkshops(
          lat: userLat,
          lng: userLng,
          radius: 5,
          minRating: 4.5,
        );
      } else if (filter == 'buka_rating') {
        futureNearestWorkshops = WorkshopService.getFilteredWorkshops(
          lat: userLat,
          lng: userLng,
          radius: 5,
          minRating: 4.5,
          isOpen: true,
        );
      }
    });
  }

  String _getWorkshopAsset(Workshop workshop, int index) {
    final title = workshop.title.toLowerCase();

    if (title.contains('m gank') || title.contains('musiman')) {
      return AppAssets.bengkelMusiman;
    }

    if (title.contains('sumber rejeki') || title.contains('gopal')) {
      return AppAssets.gopalGarage;
    }

    if (title.contains('auto part')) {
      return AppAssets.karya;
    }

    if (title.contains('pak slamet') || title.contains('slamet')) {
      return AppAssets.slamet;
    }

    if (index % 2 == 0) {
      return AppAssets.slamet;
    }

    return AppAssets.karya;
  }

  double _getLogoWidth(Workshop workshop, int index) {
    final title = workshop.title.toLowerCase();

    if (title.contains('m gank') || title.contains('musiman')) {
      return 120;
    }

    if (title.contains('sumber rejeki') || title.contains('gopal')) {
      return 120;
    }

    if (index % 2 == 0) {
      return 106;
    }

    return 92;
  }

  double _getLogoHeight(Workshop workshop, int index) {
    final title = workshop.title.toLowerCase();

    if (title.contains('m gank') || title.contains('musiman')) {
      return 70;
    }

    if (title.contains('sumber rejeki') || title.contains('gopal')) {
      return 70;
    }

    if (index % 2 == 0) {
      return 66;
    }

    return 75;
  }

  Widget _filterChip({
    required String label,
    required String value,
  }) {
    final bool active = selectedFilter == value;

    return GestureDetector(
      onTap: () => _setFilter(value),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.orange : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.darkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(label: 'Semua', value: 'semua'),
            _filterChip(label: 'Buka', value: 'buka'),
            _filterChip(label: 'Rating 4.5+', value: 'rating'),
            _filterChip(label: 'Buka & Rating', value: 'buka_rating'),
          ],
        ),
      ),
    );
  }

  List<Workshop> _filterWorkshopsBySearch(List<Workshop> workshops) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return workshops;
    }

    return workshops.where((workshop) {
      final title = workshop.title.toLowerCase();
      final address = workshop.address.toLowerCase();
      final tags = workshop.tags.join(' ').toLowerCase();

      return title.contains(query) ||
          address.contains(query) ||
          tags.contains(query);
    }).toList();
  }

  Widget _buildTopRatedSection() {
    return SizedBox(
      height: 149,
      child: FutureBuilder<List<Workshop>>(
        future: futureTopRatedWorkshops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Gagal mengambil rekomendasi: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            );
          }

          final allWorkshops = snapshot.data ?? [];
          final workshops = _filterWorkshopsBySearch(allWorkshops);

          if (workshops.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Bengkel tidak ditemukan.',
                style: TextStyle(fontSize: 12),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: workshops.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              final asset = _getWorkshopAsset(workshop, index);

              return WorkshopCard(
                asset: asset,
                title: workshop.title,
                rating: workshop.rating,
                distance: workshop.distance,
                logoWidth: _getLogoWidth(workshop, index),
                logoHeight: _getLogoHeight(workshop, index),
                isOpen: workshop.isOpen,
                onTap: () => _openDetail(
                  context,
                  asset,
                  workshop,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNearestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<Workshop>>(
        future: futureNearestWorkshops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal mengambil data bengkel: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          }

          final allWorkshops = snapshot.data ?? [];
          final workshops = _filterWorkshopsBySearch(allWorkshops);

          if (workshops.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tidak ada bengkel sesuai pencarian.',
                style: TextStyle(fontSize: 12),
              ),
            );
          }

          return Column(
            children: List.generate(workshops.length, (index) {
              final workshop = workshops[index];
              final asset = _getWorkshopAsset(workshop, index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NearbyWorkshopTile(
                  asset: asset,
                  title: workshop.title,
                  address: workshop.address,
                  distance: workshop.distance,
                  rating: workshop.rating,
                  tags: workshop.tags,
                  onTap: () => _openDetail(context, asset, workshop),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 92),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHero(),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppColors.gray,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Cari bengkel, layanan...',
                                    hintStyle: TextStyle(
                                      color: AppColors.gray,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.gray,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                        const SectionHeader(
                          title: 'Layanan Darurat',
                          left: 20,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              EmergencyCard(
                                asset: AppAssets.mogok,
                                label: 'Mogok',
                                onTap: () => _openOrder(context, 0),
                              ),
                              EmergencyCard(
                                asset: AppAssets.ban,
                                label: 'Ban Bocor',
                                onTap: () => _openOrder(context, 1),
                              ),
                              EmergencyCard(
                                asset: AppAssets.aki,
                                label: 'Aki',
                                onTap: () => _openOrder(context, 2),
                              ),
                              EmergencyCard(
                                asset: AppAssets.oli,
                                label: 'Ganti Oli',
                                onTap: () => _openOrder(context, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SectionHeader(
                          title: 'Rekomendasi Terbaik',
                          trailing: 'Semua',
                          left: 20,
                          right: 18,
                        ),
                        const SizedBox(height: 7),
                        _buildTopRatedSection(),
                        const SizedBox(height: 10),
                        const SectionHeader(
                          title: 'Bengkel Terdekat',
                          left: 20,
                        ),
                        const SizedBox(height: 8),
                        _buildFilterChips(),
                        const SizedBox(height: 8),
                        _buildNearestSection(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BottomNavbar(
              activeIndex: 0,
              onCenterTap: () => _openOrder(context, 0),
              onHomeTap: () {},
              onHistoryTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
              onChatTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              ),
              onProfileTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}