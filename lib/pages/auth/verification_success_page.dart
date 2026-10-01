import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import '../home_page.dart';
import 'auth_widgets.dart';

class VerificationSuccessPage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  const VerificationSuccessPage({super.key, required this.name, required this.phone, required this.email});

  @override
  State<VerificationSuccessPage> createState() => _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  @override
  void initState() {
    super.initState();
    _finish();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(children: [
            Positioned(top: 45, left: -20, right: -20, child: CustomPaint(size: const Size(double.infinity, 330), painter: _RadarPainter())),
            Column(children: [
              const Spacer(flex: 12),
              const CircleAvatar(radius: 39, backgroundColor: AppColors.brightGreen, child: Icon(Icons.check, color: Colors.white, size: 46)),
              const SizedBox(height: 20),
              const Text('Verifikasi Berhasil!', style: TextStyle(fontFamily: 'Syne', fontSize: 28, color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Nomor HP kamu sudah terkonfirmasi', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(.52))),
              const SizedBox(height: 24),
              Container(height: 78, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.10))), child: Row(children: [CircleAvatar(radius: 22, backgroundColor: AppColors.orange, child: Text(_initials(widget.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(widget.name.isEmpty ? 'Fahmi Wulidan' : widget.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)), Text('+62 ${widget.phone.isEmpty ? '857–1991–6327' : widget.phone}', style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12)), Text(widget.email.isEmpty ? 'fahmiwa13@gmail.com' : widget.email, style: TextStyle(color: Colors.white.withOpacity(.35), fontSize: 12))])), const CircleAvatar(radius: 14, backgroundColor: AppColors.brightGreen, child: Icon(Icons.check, color: Colors.white, size: 18))])),
              const SizedBox(height: 26),
              Text('Menyiapkan dashboard kamu...', style: TextStyle(color: Colors.white.withOpacity(.38), fontSize: 13)),
              const SizedBox(height: 10),
              Container(width: 190, height: 4, alignment: Alignment.centerLeft, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(6)), child: FractionallySizedBox(widthFactor: .72, child: Container(decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(6))))),
              const SizedBox(height: 24),
              Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [_CheckText('Data diri dilengkapi'), SizedBox(height: 12), _CheckText('Kendaraan terdaftar'), SizedBox(height: 12), _CheckText('Nomor HP terverifikasi')])),
              const Spacer(flex: 10),
              OrangeButton(text: 'Masuk ke Dashboard', onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (_) => false)),
              const SizedBox(height: 12),
              Text('Otomatis masuk dalam 3 detik...', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.25))),
              const SizedBox(height: 28),
            ]),
          ]),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'FW';
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}

class _CheckText extends StatelessWidget { final String text; const _CheckText(this.text); @override Widget build(BuildContext context) => Row(children: [const CircleAvatar(radius: 9, backgroundColor: AppColors.brightGreen, child: Icon(Icons.check, color: Colors.white, size: 13)), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))]); }

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 5; i >= 1; i--) {
      canvas.drawCircle(center, i * 34.0, Paint()..color = Colors.green.withOpacity(.035 + i * .015));
    }
    final dots = Paint();
    for (int i = 0; i < 12; i++) {
      final a = i * pi / 6;
      dots.color = [AppColors.orange, AppColors.brightGreen, const Color(0xFFC49A83)][i % 3].withOpacity(.75);
      canvas.drawCircle(center + Offset(cos(a) * (120 + (i % 3) * 22), sin(a) * (120 + (i % 3) * 22)), i % 4 == 0 ? 8 : 4, dots);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
