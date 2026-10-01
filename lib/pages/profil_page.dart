import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/vehicle.dart';
import '../services/local_data_service.dart';
import '../widgets/bottom_navbar.dart';
import 'auth/login_page.dart';
import 'chat_list_page.dart';
import 'edit_profil_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'service_page.dart';
import 'vehicle_from_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String> profile = {};
  Vehicle? mainVehicle;
  bool notif = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    profile = await LocalDataService.getProfile();
    mainVehicle = await LocalDataService.getMainVehicle();

    if (mounted) setState(() => _isLoading = false);
  }

  String initials() {
    final name = (profile['name'] ?? 'FW').trim();
    if (name.isEmpty) return 'FW';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 1).toUpperCase();
  }

  Future<void> _actionLogout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Konfirmasi Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun BengkelTrack?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (konfirmasi == true) {
      await LocalDataService.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  children: [
                    _top(),
                    Transform.translate(
                      offset: const Offset(0, -18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _stats(),
                            const SizedBox(height: 16),
                            section('AKUN SAYA'),
                            card([
                              tile(
                                Icons.person,
                                'Edit Profil',
                                'Nama, foto, nomor HP',
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                  load();
                                },
                              ),
                              divider(),
                              tile(
                                Icons.directions_car,
                                'Kendaraan Saya',
                                mainVehicle?.title.isNotEmpty == true
                                    ? mainVehicle!.title
                                    : 'Tambah Kendaraan',
                                () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => VehicleFormPage(
                                            vehicle: mainVehicle,
                                          ),
                                    ),
                                  );
                                  load();
                                },
                              ),
                              divider(), // Penempatan divider yang konsisten sebelum logout
                              tile(
                                Icons.logout,
                                'Logout',
                                'Keluar dari akun ini',
                                _actionLogout,
                              ),
                            ]),
                            const SizedBox(height: 16),
                            section('APLIKASI'),
                            card([
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Color(0xFFFFF4E8),
                                      child: Text('🔔'),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Notifikasi',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: notif,
                                      activeColor: AppColors.orange,
                                      onChanged:
                                          (value) =>
                                              setState(() => notif = value),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNavbar(
              activeIndex: 4,
              onCenterTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServicePage()),
                  ),
              onHomeTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
              onHistoryTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
              onChatTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatListPage()),
                  ),
              onProfileTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _top() {
    final photoPath = profile['photo'] ?? '';
    return Container(
      height: 248,
      width: double.infinity,
      color: AppColors.navy,
      child: Stack(
        children: [
          const Positioned(
            left: -48,
            top: 105,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.blueNavy,
            ),
          ),
          const Positioned(
            right: -24,
            top: -22,
            child: CircleAvatar(radius: 90, backgroundColor: Color(0x333B82F6)),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                    load();
                  },
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0x8040445B),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.orange,
                      backgroundImage: _avatarImage(photoPath),
                      child:
                          photoPath.isEmpty
                              ? Text(
                                initials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile['name']?.isNotEmpty == true
                      ? profile['name']!
                      : 'Pengguna',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  profile['email']?.isNotEmpty == true
                      ? profile['email']!
                      : 'pengguna@gmail.com',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() => Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warmBorder),
      boxShadow: appShadow,
    ),
    child: const Row(
      children: [
        Expanded(child: _Stat(n: '3', l: 'Order')),
        VerticalDivider(color: AppColors.warmBorder),
        Expanded(child: _Stat(n: 'Rp. 250rb', l: 'Total Servis')),
      ],
    ),
  );

  Widget section(String text) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.gray,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget divider() =>
      const Divider(height: 1, indent: 52, color: AppColors.warmBorder);

  Widget card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.warmBorder),
    ),
    child: Column(children: children),
  );

  Widget tile(IconData icon, String title, String subtitle, VoidCallback tap) =>
      GestureDetector(
        onTap: tap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFF1F5FF),
                child: Icon(icon, color: AppColors.orange, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray),
            ],
          ),
        ),
      );

  ImageProvider? _avatarImage(String photoPath) {
    if (photoPath.isEmpty) return null;
    if (kIsWeb) return NetworkImage(photoPath);
    final file = File(photoPath);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }
}

class _Stat extends StatelessWidget {
  final String n;
  final String l;
  const _Stat({required this.n, required this.l});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        n,
        style: const TextStyle(
          color: AppColors.orange,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(l, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
    ],
  );
}
