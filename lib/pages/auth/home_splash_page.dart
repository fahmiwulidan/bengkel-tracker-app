import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import 'auth_widgets.dart';
import 'login_page.dart';
import 'register_step1_page.dart';

class HomeSplashPage extends StatefulWidget {
  const HomeSplashPage({super.key});

  @override
  State<HomeSplashPage> createState() => _HomeSplashPageState();
}

class _HomeSplashPageState extends State<HomeSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 16),
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    AppAssets.logo,
                    width: 145,
                    height: 145,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    const Text(
                      'Bengkel',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: .95,
                      ),
                    ),
                    const Text(
                      'Track',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Mekanik On-demand · Lamongan',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color.fromRGBO(255, 255, 255, 0.42),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Spacer(flex: 20),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    OrangeButton(
                      text: 'Daftar Sekarang',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterStep1Page(),
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color.fromRGBO(255, 255, 255, 0.16),
                          ),
                          backgroundColor: const Color.fromRGBO(
                            255,
                            255,
                            255,
                            0.10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sudah punya akun? Masuk',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dengan melanjutkan kamu menyetujui',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color.fromRGBO(255, 255, 255, 0.18),
                      ),
                    ),
                    const Text(
                      'Syarat & Ketentuan · Kebijakan Privasi',
                      style: TextStyle(fontSize: 10, color: AppColors.orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
