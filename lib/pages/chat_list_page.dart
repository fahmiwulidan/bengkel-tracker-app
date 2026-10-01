import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../services/api.dart'; // Import ApiService Dio Anda
import '../services/local_data_service.dart';
import '../widgets/bottom_navbar.dart';
import 'chat_detail_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'service_page.dart';
import 'profil_page.dart';

// ✅ DEKLARASI ENUM UTAMA (Ditaruh di tingkat atas agar dikenal oleh State)
enum ChatFilter { all, mechanic, support }

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String searchQuery = '';
  ChatFilter selectedFilter = ChatFilter.all;

  List<dynamic> _chatRooms = [];
  bool _isLoading = true;
  int _currentUserId = 1;

  @override
  void initState() {
    super.initState();
    _initChatList();
  }

  Future<void> _initChatList() async {
    await _loadCurrentUserId();
    await _fetchChatRooms();
  }

  Future<void> _loadCurrentUserId() async {
    final profile = await LocalDataService.getProfile();
    if (profile.containsKey('id')) {
      setState(() {
        // Pastikan merubah variabel _currentUserId milik State
        _currentUserId = int.tryParse(profile['id'].toString()) ?? 1;
      });
    }
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
      debugPrint("Error fetching chat rooms: $e");
    }
  }

  void _goHome(BuildContext context) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  List<dynamic> get filteredChats {
    final query = searchQuery.trim().toLowerCase();
    return _chatRooms.where((room) {
      final name =
          (room['workshop_name'] ?? room['mechanic_name'] ?? '')
              .toString()
              .toLowerCase();
      final lastMessage = (room['last_message'] ?? '').toString().toLowerCase();

      return query.isEmpty ||
          name.contains(query) ||
          lastMessage.contains(query);
    }).toList();
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
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _fetchChatRooms,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 10),
                              _SearchBox(
                                controller: searchController,
                                focusNode: searchFocusNode,
                                onChanged:
                                    (value) =>
                                        setState(() => searchQuery = value),
                                onClear: () {
                                  searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              ),
                              const SizedBox(height: 14),
                              _FilterTabs(
                                selectedFilter: selectedFilter,
                                onChanged:
                                    (filter) =>
                                        setState(() => selectedFilter = filter),
                              ),
                              const SizedBox(height: 13),

                              if (filteredChats.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'Belum ada percakapan.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...filteredChats.map((room) {
                                  return _ChatTile(
                                    asset: AppAssets.slamet,
                                    name:
                                        room['workshop_name'] ??
                                        room['mechanic_name'] ??
                                        'Mekanik Bengkel',
                                    message:
                                        room['last_message'] ??
                                        'Ketuk untuk melihat pesan',
                                    sub:
                                        "Kode Order: ${room['order_code'] ?? '-'}",
                                    time: room['updated_at_formatted'] ?? '',
                                    unread: '',
                                    onTap:
                                        () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ChatDetailPage(
                                                  chatRoomId: room['id'],
                                                  currentUserId: _currentUserId,
                                                  receiverName:
                                                      room['workshop_name'] ??
                                                      room['mechanic_name'] ??
                                                      'Mekanik',
                                                ),
                                          ),
                                        ),
                                  );
                                }),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
            ),
            BottomNavbar(
              activeIndex: 3,
              onCenterTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ServicePage()),
                  ),
              onHomeTap: () => _goHome(context),
              onHistoryTap:
                  () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
              onChatTap: () {},
              onProfileTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 110,
      child: Stack(
        children: [
          Container(color: AppColors.navy),
          Positioned(
            left: 19,
            top: 50,
            child: Row(
              children: [
                const Text(
                  'Pesan',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Syne',
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange,
                  ),
                  child: Center(
                    child: Text(
                      '${_chatRooms.length}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTab {
  const _ChatTab({required this.label, required this.filter});
  final String label;
  final ChatFilter filter;
}

// --- Komponen Sub-Widget UI Pembantu ---
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.white15,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: AppColors.white80, size: 21),
    ),
  );
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.warmBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.gray, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Cari percakapan...',
                hintStyle: TextStyle(color: AppColors.gray, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, color: AppColors.gray, size: 20),
            ),
        ],
      ),
    ),
  );
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selectedFilter, required this.onChanged});
  final ChatFilter selectedFilter;
  final ValueChanged<ChatFilter> onChanged;
  @override
  Widget build(BuildContext context) {
    final tabs = [
      _ChatTab(label: 'Semua', filter: ChatFilter.all),
      _ChatTab(label: 'Mekanik', filter: ChatFilter.mechanic),
      _ChatTab(label: 'CS Support', filter: ChatFilter.support),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            tabs.map((tab) {
              final active = selectedFilter == tab.filter;
              return Expanded(
                flex: tab.label == 'CS Support' ? 14 : 11,
                child: GestureDetector(
                  onTap: () => onChanged(tab.filter),
                  child: Container(
                    height: 31,
                    margin: const EdgeInsets.only(right: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.navy : AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: active ? AppColors.navy : AppColors.warmBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active ? AppColors.white : AppColors.darkGray,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.asset,
    required this.name,
    required this.message,
    required this.sub,
    required this.time,
    required this.unread,
    this.online = false,
    required this.onTap,
  });
  final String asset, name, message, sub, time, unread;
  final bool online;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 75,
      padding: const EdgeInsets.fromLTRB(20, 0, 15, 0),
      color: AppColors.background,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Image.asset(asset, width: 42)),
              ),
              if (online)
                const Positioned(
                  right: 1,
                  bottom: 2,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: AppColors.brightGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray),
                  ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.orange),
              ),
              const SizedBox(height: 9),
              Container(
                width: 21,
                height: 21,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unread,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _InitialTile extends StatelessWidget {
  const _InitialTile({
    required this.initial,
    required this.name,
    required this.message,
    required this.sub,
    required this.time,
    required this.onTap,
    this.verified = false,
  });
  final String initial, name, message, sub, time;
  final bool verified;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 75,
      padding: const EdgeInsets.fromLTRB(20, 0, 15, 0),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: verified ? AppColors.navy : AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: initial.length > 2 ? 7 : 13,
                      color:
                          verified ? AppColors.orange : const Color(0xFFFF2965),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (verified)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppColors.blue,
                    child: Icon(Icons.check, color: AppColors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.gray),
          ),
        ],
      ),
    ),
  );
}
