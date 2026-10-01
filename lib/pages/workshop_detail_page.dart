import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../models/workshop.dart';
import '../services/api.dart';
import '../services/local_data_service.dart';
import 'chat_detail_page.dart';
import 'service_page.dart';

class WorkshopDetailPage extends StatefulWidget {
  const WorkshopDetailPage({
    super.key,
    required this.asset,
    required this.workshop,
  });

  final String asset;
  final Workshop workshop;

  @override
  State<WorkshopDetailPage> createState() => _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends State<WorkshopDetailPage> {
  bool _isNavigatingToChat = false;

  String _formatDistance(dynamic distance) {
    final text = distance.toString();
    if (text.toLowerCase().contains('km')) {
      return text;
    }
    return '$text km';
  }

  void _shareWorkshop(BuildContext context) {
    final text = '''
${widget.workshop.title}

Alamat:
${widget.workshop.address}

Rating: ${widget.workshop.rating}
Jarak: ${_formatDistance(widget.workshop.distance)}

Cek bengkel ini di aplikasi BengkelTrack.
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Info bengkel berhasil disalin.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ PERBAIKAN: Menambahkan argumen receiverName dinamis dari judul Bengkel/Workshop
  Future<void> _handleChatNavigation(BuildContext context) async {
    if (_isNavigatingToChat) return;

    setState(() => _isNavigatingToChat = true);

    try {
      final profile = await LocalDataService.getProfile();
      final int currentUserId = int.tryParse(profile['id'].toString()) ?? 1;

      final response = await ApiService.client.post(
        '/chat-rooms',
        data: {'workshop_id': widget.workshop.id, 'order_id': 1},
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
                  receiverName:
                      widget
                          .workshop
                          .title, // ✅ Mengisi parameter nama bengkel dinamis
                ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal memproses pembuatan chat room bengkel: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka percakapan dengan bengkel.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isNavigatingToChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWeb = constraints.maxWidth >= 900;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 900 : double.infinity,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Container(
                    color: AppColors.background,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: 12),
                                _buildAvailableServices(),
                                const SizedBox(height: 12),
                                _buildOperationalCard(),
                                const SizedBox(height: 12),
                                _buildReviews(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            child: Container(
                              color: AppColors.background,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed:
                                            _isNavigatingToChat
                                                ? null
                                                : () => _handleChatNavigation(
                                                  context,
                                                ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.orange,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          backgroundColor: AppColors.white,
                                        ),
                                        child:
                                            _isNavigatingToChat
                                                ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.orange,
                                                      ),
                                                )
                                                : const Text(
                                                  'Chat',
                                                  style: TextStyle(
                                                    color: AppColors.orange,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const ServicePage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: AppColors.orange,
                                          foregroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Pesan Sekarang',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = TimeOfDay.now();
    final bool isOpenNow = now.hour >= 6 && now.hour < 21;
    final String statusText = isOpenNow ? 'Buka' : 'Tutup';
    final Color statusColor = isOpenNow ? AppColors.brightGreen : AppColors.red;
    const String timeText = '06:00 - 21:00';

    return Container(
      width: double.infinity,
      color: AppColors.navy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 18, 0),
            child: Row(
              children: [
                const Text(
                  '19:22',
                  style: TextStyle(color: AppColors.gray, fontSize: 11),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _shareWorkshop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white15,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white15,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child:
                        widget.asset.isEmpty
                            ? const Icon(
                              Icons.store,
                              color: AppColors.white,
                              size: 24,
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                widget.asset,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workshop.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.workshop.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              timeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
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
          Container(
            height: 41,
            color: AppColors.white15,
            child: Row(
              children: [
                _StatItem(
                  value: _formatDistance(widget.workshop.distance),
                  label: 'Jarak',
                ),
                const _HeaderDivider(),
                const _StatItem(value: '128', label: 'Review'),
                const _HeaderDivider(),
                _StatItem(
                  value: widget.workshop.rating.toString(),
                  label: 'Rating',
                ),
                const _HeaderDivider(),
                const _StatItem(value: '5+', label: 'Mekanik'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableServices() {
    final services = ['Motor', 'Mobil', 'Ganti Oli', 'Ban Bocor', 'Lainnya'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Tersedia',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                services.map((item) {
                  final active = item == 'Motor' || item == 'Mobil';
                  return Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: active ? AppColors.orange : AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: active ? AppColors.orange : AppColors.warmBorder,
                      ),
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 9,
                          color: active ? AppColors.white : AppColors.gray,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.warmBorder),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jam Operasional',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          _OperationalRow(day: 'Senin - Sabtu', time: '06:00 - 21:00'),
          SizedBox(height: 4),
          _OperationalRow(day: 'Minggu', time: 'Tutup', closed: true),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Review Pelanggan',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Semua',
                style: TextStyle(color: AppColors.orange, fontSize: 10),
              ),
            ],
          ),
          SizedBox(height: 7),
          _ReviewCard(
            initial: 'B',
            name: 'Budi Speed',
            rating: '5.0',
            time: '2 hr lalu',
            message:
                'Pak Slamet cepat & profesional, harga wajar. Langsung beres dalam 30 menit. Recommended!',
            color: AppColors.navy,
          ),
          SizedBox(height: 8),
          _ReviewCard(
            initial: 'D',
            name: 'Clarisa Speed',
            rating: '4.8',
            time: '1 hari lalu',
            message:
                'Motor mogok, mekanik datang kurang dari 10 menit. Mantap pelayanannya!',
            color: AppColors.orange,
          ),
          SizedBox(height: 8),
          _ReviewCard(
            initial: 'R',
            name: 'Harry Pratama',
            rating: '4.9',
            time: '3 hari lalu',
            message: 'Harga sesuai, pengerjaan rapi. Puas!',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 9),
          ),
        ],
      ),
    ),
  );
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 22, color: AppColors.white15);
}

class _OperationalRow extends StatelessWidget {
  const _OperationalRow({
    required this.day,
    required this.time,
    this.closed = false,
  });
  final String day, time;
  final bool closed;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(day, style: const TextStyle(color: AppColors.gray, fontSize: 11)),
      const Spacer(),
      Text(
        time,
        style: TextStyle(
          color: closed ? Colors.red : AppColors.textDark,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.initial,
    required this.name,
    required this.rating,
    required this.time,
    required this.message,
    required this.color,
  });
  final String initial, name, rating, time, message;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.warmBorder),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: color,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.gray,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  const Text(
                    '★ ★ ★ ★ ★',
                    style: TextStyle(color: AppColors.orange, fontSize: 8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(color: AppColors.gray, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.gray,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
