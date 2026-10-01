import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/api.dart';
import '../../constants/app_colors.dart';
import '../auth/auth_gate.dart';
import 'mechanic_menu_chat_page.dart'; // ✅ Berkas list chat asli Anda
import 'mechanic_home_page.dart';
import 'mechanic_tracking_page.dart';
import 'edit_mechanic_profile_page.dart';

class MechanicProfilePage extends StatefulWidget {
  const MechanicProfilePage({super.key});

  @override
  State<MechanicProfilePage> createState() => _MechanicProfilePageState();
}

class _MechanicProfilePageState extends State<MechanicProfilePage> {
  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int completedOrder = 0;
  double income = 0;

  bool isOnline = true;
  String _mechanicName = 'Mekanik';
  String _mechanicEmail = '';
  bool _isLoading = true;
  int _mechanicId = 1;

  @override
  void initState() {
    super.initState();
    _loadMechanicData();
    _loadStatistic();
  }

  Future<void> _loadMechanicData() async { 
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _mechanicName = prefs.getString('name') ?? 'Mekanik BengkelTrack';
        _mechanicEmail = prefs.getString('email') ?? '';
        // Ambil ID mekanik dinamis untuk dipakai di endpoint status
        _mechanicId = int.tryParse(prefs.getString('id') ?? '1') ?? 1;
        _isLoading = false;
      });
    }
  }
Future<void> _loadStatistic() async {
  try {
    final response =
        await ApiService.client.get('/mechanic/statistic');

    setState(() {
      completedOrder =
          response.data['completed_order'] ?? 0;

      income =
          (response.data['income'] ?? 0).toDouble();
    });
  } catch (e) {
    debugPrint(e.toString());
  }
}
  Future<void> _updateStatus(bool value) async {
    try {
      // ✅ PERBAIKAN 1: Endpoint mengikuti ID mekanik yang sedang login secara dinamis
      await ApiService.client.patch(
        '/mechanics/$_mechanicId/status',
        data: {'status': value ? 'open' : 'close'},
      );

      setState(() {
        isOnline = value;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'Status Online' : 'Status Offline')),
      );
    } catch (e) {
      debugPrint("Gagal mengubah status online mekanik: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengubah status')));
    }
  }

  Future<void> _actionLogout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun mekanik?',
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
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (konfirmasi == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('role');
      await prefs.remove('profile');
      await prefs.remove('name');
      await prefs.remove('email');
      await prefs.remove('id');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      }
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title belum tersedia'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatisticCard(),
                        const SizedBox(height: 12),
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        const Text(
                          'PEKERJAAN',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMenuCard(),
                        const SizedBox(height: 18),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String initialLetter =
        _mechanicName.isNotEmpty ? _mechanicName.trim()[0].toUpperCase() : 'M';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF10163A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460).withOpacity(.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 34),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Profil Mekanik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: Material(
                      color: Colors.white.withOpacity(.10),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showComingSoon('Pengaturan'),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF7043),
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -3,
                    bottom: 5,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -3,
                    bottom: 5,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _mechanicName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _mechanicEmail.isNotEmpty
                    ? _mechanicEmail
                    : 'Mekanik BengkelTrack',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043).withOpacity(.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Mekanik Info',
                  style: TextStyle(
                    color: Color(0xFFFFD0C2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              value: rupiah.format(income),
              label: 'Bulan ini',
              subLabel: '+12%',
              valueColor: const Color(0xFFFF7043),
              subColor: const Color(0xFF22C55E),
            ),
          ),
          _divider(),
          Expanded(
            child: _statItem(
              value: completedOrder.toString(),
              label: 'Order Selesai',
              subLabel: 'Selesai semua',
              valueColor: const Color(0xFF111827),
              subColor: const Color(0xFF22C55E),
            ),
          ),
          _divider(),
          Expanded(
            child: _statItem(
              value: '4.9',
              label: 'Rating',
              subLabel: '21 ulasan',
              valueColor: const Color(0xFF111827),
              subColor: const Color(0xFF22C55E),
            ),
          ),
          _divider(),
          /* Expanded(
            child: _statItem(
              value: '93%',
              label: 'Respon',
              subLabel: 'Sangat baik',
              valueColor: const Color(0xFF111827),
              subColor: const Color(0xFF22C55E),
            ),
          ), */
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required String subLabel,
    required Color valueColor,
    required Color subColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subLabel,
          style: TextStyle(
            color: subColor,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 42, color: const Color(0xFFE5E7EB));

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFEFFAF2) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline ? const Color(0xFFD7F2DE) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color:
                  isOnline ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.adjust, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Status: Online' : 'Status: Offline',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOnline
                      ? 'Siap menerima order baru'
                      : 'Tidak menerima order baru',
                  style: TextStyle(
                    color:
                        isOnline
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF22C55E),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            onChanged: _updateStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.person,
            iconColor: const Color(0xFF8B9CF6),
            bgColor: const Color(0xFFEFF1FF),
            title: 'Edit Profil',
            subtitle: 'Foto, nama, nomor HP',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditMechanicProfilePage(),
                ),
              );
              if (result == true) _loadMechanicData();
            },
          ),
          _itemDivider(),
          _menuItem(
            icon: Icons.handyman,
            iconColor: const Color(0xFFE53935),
            bgColor: const Color(0xFFFFECEC),
            title: 'Keahlian & Layanan',
            subtitle: 'Motor, Mobil, Oli & Tune Up',
            onTap: () => _showComingSoon('Keahlian & Layanan'),
          ),
          _itemDivider(),
          _menuItem(
            icon: Icons.calendar_month,
            iconColor: const Color(0xFFE49A32),
            bgColor: const Color(0xFFFFF4DE),
            title: 'Jadwal Kerja',
            subtitle: 'Sen-Sab · 06:00–21:00',
            onTap: () => _showComingSoon('Jadwal Kerja'),
          ),
          _itemDivider(),
          _menuItem(
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF7D7A43),
            bgColor: const Color(0xFFF5F1D8),
            title: 'Rekening Payout',
            subtitle: 'BCA · xxxx-xxx-1234',
            onTap: () => _showComingSoon('Rekening Payout'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _itemDivider() => Container(
    height: 1,
    margin: const EdgeInsets.only(left: 58),
    color: const Color(0xFFF0F0F0),
  );

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _actionLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE1E1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'LogOut',
          style: TextStyle(
            color: Color(0xFFFF3B30),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(index: 0, icon: Icons.home_rounded, label: 'Beranda'),
          _navItem(
            index: 1,
            icon: Icons.location_on_rounded,
            label: 'Tracking',
          ),
          _navItem(
            index: 2,
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Pesan',
          ),
          _navItem(index: 3, icon: Icons.person_rounded, label: 'Profil'),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool active = index == 3;
    return GestureDetector(
      onTap: () {
        if (index == 3) return;
        if (index == 0)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MechanicHomePage()),
          );
        if (index == 1)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MechanicTrackingPage(hasActiveOrder: true),
            ),
          );
        // ✅ PERBAIKAN 2: Navigasi menu chat dialihkan ke berkas asli MechanicMenuChatPage
        if (index == 2)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MechanicMenuChatPage()),
          );
      },
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: active ? const Color(0xFFFF7043) : const Color(0xFFFF9B6A),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color:
                    active ? const Color(0xFFFF7043) : const Color(0xFFFF9B6A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
