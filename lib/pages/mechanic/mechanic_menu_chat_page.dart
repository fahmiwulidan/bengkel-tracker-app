import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_assets.dart';
import '../../services/api.dart';
import 'mechanic_tracking_page.dart';
import 'mechanic_profile_page.dart';
import '../../services/local_data_service.dart';
import '../chat_detail_page.dart'; // ✅ Import halaman universal

class MechanicMenuChatPage extends StatefulWidget {
  const MechanicMenuChatPage({super.key});

  @override
  State<MechanicMenuChatPage> createState() => _MechanicMenuChatPageState();
}

class _MechanicMenuChatPageState extends State<MechanicMenuChatPage> {
  int activeIndex = 2;
  String selectedFilter = 'semua';
  int _currentUserId = 1;

  List<dynamic> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMechanicChatList();
  }

  Future<void> _initMechanicChatList() async {
    await _loadMechanicId();
    await _fetchChatRooms();
  }

  Future<void> _loadMechanicId() async {
    final profile = await LocalDataService.getProfile();

    setState(() {
      // ✅ Mengambil ID user murni yang dikirim dari AuthController Laravel
      _currentUserId = int.tryParse(profile['id'].toString()) ?? 1;
    });

    debugPrint("🔑 MEKANIK LOGIN ACTIVE USER_ID: $_currentUserId");
  }

  Future<void> _fetchChatRooms() async {
    try {
      final response = await ApiService.client.get('/chat-rooms');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _chatRooms = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching mechanic chat rooms: $e");
    }
  }

  List<dynamic> get filteredChats {
    return _chatRooms.where((room) {
      final customerName =
          (room['customer_name'] ?? 'Pelanggan').toString().toLowerCase();
      if (selectedFilter == 'pelanggan') return !customerName.contains('admin');
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _fetchChatRooms,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 10),
                              _buildSearchBox(),
                              const SizedBox(height: 12),
                              _buildFilterTabs(),
                              const SizedBox(height: 14),
                              _buildActiveOrderCard(),
                              const SizedBox(height: 16),
                              if (filteredChats.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'Belum ada percakapan aktif.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...filteredChats.map(
                                  (room) => _buildChatItem(room),
                                ),
                              const SizedBox(height: 12),
                              const Center(
                                child: Text(
                                  'Tidak ada pesan lagi',
                                  style: TextStyle(
                                    color: Color(0xFFB5B5B5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavbar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 18),
      decoration: const BoxDecoration(color: Color(0xFF10163A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesan',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              fontFamily: 'Syne',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043).withOpacity(.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Role Mekanik',
                  style: TextStyle(
                    color: Color(0xFFFFB199),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari percakapan...',
          hintStyle: TextStyle(color: Color(0xFFB5B5B5), fontSize: 12),
          prefixIcon: Icon(Icons.search, color: Color(0xFFB5B5B5), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _filterChip('Semua', 'semua'),
        const SizedBox(width: 8),
        _filterChip('Pelanggan', 'pelanggan'),
      ],
    );
  }

  Widget _filterChip(String title, String value) {
    final bool active = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF10163A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? const Color(0xFF10163A) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF8A8FA3),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard() {
    if (_chatRooms.isEmpty) return const SizedBox.shrink();
    final activeChat = _chatRooms.first;
    final String customerName = activeChat['customer_name'] ?? 'Pelanggan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF7043).withOpacity(.45)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_unchecked,
            color: Color(0xFFFF7043),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Aktif Sekarang',
                  style: TextStyle(
                    color: Color(0xFFFF7043),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activeChat['customer_name'] ?? 'Pelanggan'} · Kode Order: ${activeChat['order_code'] ?? '-'}',
                  style: const TextStyle(
                    color: Color(0xFFFF7043),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatDetailPage(
                          // ✅ PERBAIKAN: Ubah ke ChatDetailPage universal
                          chatRoomId:
                              int.tryParse(activeChat['id'].toString()) ?? 1,
                          currentUserId: _currentUserId,
                          receiverName: customerName,
                        ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                side: const BorderSide(color: Color(0xFFFF7043)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lihat',
                style: TextStyle(
                  color: Color(0xFFFF7043),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> room) {
    // ✅ Parameter 'room' sudah dikirim langsung ke fungsi ini, tidak perlu _chatRooms[index] lagi
    final String customerName = room['customer_name'] ?? 'Pelanggan';
    final String orderCode = room['order_code'] ?? '-';
    final int orderId =
        room['order_id'] ?? room['id'] ?? 0; // Mengambil ID order dinamis

    final String initial =
        customerName
            .substring(0, customerName.length >= 2 ? 2 : 1)
            .toUpperCase();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatDetailPage(
                  chatRoomId: room['id'],
                  currentUserId:
                      _currentUserId, // ✅ Sisi mekanik akan mengirim ID Mekaniknya (misal: ID 2 atau 3)
                  receiverName: room['customer_name'] ?? 'Pelanggan',
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.paleOrange,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 11),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ MENAMPILKAN ID ORDER DI SAMPING NAMA CUSTOMER
                            Text(
                              "$customerName (Order ID: #$orderId)",
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              room['last_message'] ??
                                  'Ketuk untuk melihat pesan',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
                                height: 1.25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          room['updated_at_formatted'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavbar(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context: context,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Beranda',
          ),
          _navItem(
            context: context,
            index: 1,
            icon: Icons.location_on_rounded,
            label: 'Tracking',
          ),
          _navItem(
            context: context,
            index: 2,
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
          ),
          _navItem(
            context: context,
            index: 3,
            icon: Icons.person_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool active = activeIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 2) return;
        if (index == 0) Navigator.pop(context);
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MechanicTrackingPage(hasActiveOrder: true),
            ),
          );
        }
        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MechanicProfilePage()),
          );
        }
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
