import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../models/chat_message_model.dart';
import '../services/api.dart'; // Menggunakan ApiService berbasis Dio Anda

class ChatDetailPage extends StatefulWidget {
  final int chatRoomId;
  final int currentUserId; // ID user/mekanik yang sedang login aktif
  final String receiverName; // Nama lawan bicara dinamis

  const ChatDetailPage({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.receiverName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Auto-scroll ke pesan paling bawah setelah data dimuat atau pesan dikirim
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 1. Mengambil Riwayat Chat dari API Laravel Bengkel-Tracker via Dio
  Future<void> _fetchMessages() async {
    try {
      final response = await ApiService.client.get(
        '/chat-rooms/${widget.chatRoomId}/messages',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawMessages = response.data['data']['data'] ?? [];

        setState(() {
          _messages =
              rawMessages
                  .map((m) => ChatMessageModel.fromJson(m))
                  .toList()
                  .reversed // ✅ Membuat urutan chat terbaru berada di paling bawah layar
                  .toList();
          _isLoading = false;
        });

        // Berikan sedikit delay agar ListView selesai dirender sebelum scrolling
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching messages via Dio: $e");
    }
  }

  // 2. Mengirim Pesan Baru ke API Laravel Bengkel-Tracker via Dio
  Future<void> _sendMessage() async {
    final String textToSend = _messageController.text.trim();
    if (textToSend.isEmpty) return;

    _messageController.clear();

    try {
      final response = await ApiService.client.post(
        '/chat-messages',
        data: {
          'chat_room_id': widget.chatRoomId,
          'sender_id':
              widget
                  .currentUserId, // 🛠️ PASTIKAN BARIS INI MENGGUNAKAN widget.currentUserId
          'message': textToSend,
          'message_type': 'text',
        },
      );

      if (response.statusCode == 201) {
        _fetchMessages();
      }
    } catch (e) {
      debugPrint("Error sending message via Dio: $e");
    }
  }

  // Penyesuaian Zona Waktu HP Indonesia (WIB)
  String _parseLocalTime(String createdAt) {
    try {
      final String dateTimeStr =
          createdAt.contains('Z')
              ? createdAt
              : "${createdAt.replaceAll(' ', 'T')}Z";
      DateTime parsedDate = DateTime.parse(dateTimeStr).toLocal();
      return "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return createdAt.length > 16 ? createdAt.substring(11, 16) : createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              height: 124,
              color: AppColors.navy,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white15,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Image.asset(AppAssets.slamet, width: 38),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.receiverName} (Order ID: #${widget.chatRoomId})",
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: AppColors.brightGreen,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- BODY RIWAYAT CHAT ---
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        controller: _scrollController,
                        reverse:
                            true, // ✅ Jangkar gulir dimulai dari bawah ke atas
                        padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];

                          // 🔐 LOGIKA ANTIPELURU PENENTU POSISI BUBBLE CHAT (KANAN / KIRI)
                          bool isMe = false;

                          // 1. Bersihkan nilai ID dari DB dan ID lokal dari spasi atau nilai null berupa string
                          final String dbSenderStr =
                              msg.senderId.toString().trim().toLowerCase();
                          final String localUserStr =
                              widget.currentUserId
                                  .toString()
                                  .trim()
                                  .toLowerCase();

                          // 2. Validasi ketat: Pastikan kedua ID valid, tidak kosong, dan bukan teks "null"
                          if (dbSenderStr.isNotEmpty &&
                              localUserStr.isNotEmpty &&
                              dbSenderStr != 'null' &&
                              localUserStr != 'null') {
                            // 3. Bandingkan ID secara presisi
                            isMe = (dbSenderStr == localUserStr);
                          }

                          // 🔍 Tambahkan Debug Print ini untuk melihat langsung ID yang saling bertabrakan di Debug Console VS Code
                          debugPrint(
                            "🚨 CHAT LOG -> ID di Database: '$dbSenderStr' | ID Login Sekarang: '$localUserStr' | Hasil (isMe): $isMe",
                          );

                          return _Bubble(
                            text: msg.message,
                            time: _parseLocalTime(msg.createdAt),
                            me: isMe, // Jika true akan ke KANAN (Oranye), jika false akan ke KIRI (Putih)
                          );
                        },
                      ),
            ),

            // --- BOTTOM TEXT INPUT ---
            Container(
              height: 60,
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.attach_file,
                      color: AppColors.gray,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      decoration: BoxDecoration(
                        color: AppColors.softCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.warmBorder),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 13),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC0BBB4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.time, required this.me});
  final String text, time;
  final bool me;

  @override
  Widget build(BuildContext context) => Align(
    alignment:
        me
            ? Alignment.centerRight
            : Alignment.centerLeft, // ✅ Kanan jika saya, Kiri jika lawan chat
    child: Container(
      margin: EdgeInsets.only(
        left: me ? 72 : 0,
        right: me ? 0 : 72,
        bottom: 10,
      ),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
      decoration: BoxDecoration(
        // ✅ Pengondisian warna latar belakang bubble chat
        color: me ? AppColors.orange : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(me ? 16 : 4),
          bottomRight: Radius.circular(me ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: me ? AppColors.white : AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 9,
                  color: me ? AppColors.white70 : AppColors.gray,
                ),
              ),
              if (me) ...[
                const SizedBox(width: 3),
                const Icon(Icons.done_all, size: 12, color: AppColors.white70),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
