import 'package:bengkel/pages/home_page.dart';
import 'package:bengkel/pages/mechanic/mechanic_home_page.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import 'auth_widgets.dart';
import 'register_step1_page.dart';
import '../../services/local_data_service.dart';
import '../../services/api.dart'; // 1. PERBAIKAN: Sesuaikan dengan nama file ApiService Anda

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _remember = false;
  bool _hide = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 2. PERBAIKAN: Cukup panggil ApiService.client secara langsung.
      // Url dasar (baseUrl) dan header Content-Type sudah terbungkus otomatis di dalamnya.
      final loginInput = _emailCtrl.text.trim();
      final isPhoneLogin = _isPhoneInput(loginInput);
      final payload =
          isPhoneLogin
              ? {
                'email': loginInput,
                'phone': _normalizePhone(loginInput),
                'password': _passCtrl.text,
              }
              : {'email': loginInput, 'password': _passCtrl.text};

      final response = await ApiService.client.post('/login', data: payload);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = response.data;
        print(data);

        // AMANKAN PARSING DATA DI SINI (Berikan fallback ?? '')
        final String token = data['access_token']?.toString() ?? '';
        final String name =
            data['user']['name']?.toString() ?? 'Pengguna Bengkel';
        final String email = data['user']['email']?.toString() ?? '';
        final String role =
            data['user']['role']?.toString().toLowerCase() ?? 'user';
        final String StringUserId = data['user']['id']?.toString() ?? '1';

        // 3. Simpan data otentikasi dasar ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('access_token', token);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('role', role);

        // Sinkronisasikan juga ke format JSON Profile milik LocalDataService
        final existingProfile = await LocalDataService.getProfile();
        final apiPhone = data['user']['phone']?.toString().trim() ?? '';
        final savedPhone = existingProfile['phone']?.trim() ?? '';
        final loginPhone = _normalizePhone(_emailCtrl.text);

        final resolvedPhone =
            apiPhone.isNotEmpty
                ? apiPhone
                : (savedPhone.isNotEmpty ? savedPhone : loginPhone);

        await LocalDataService.saveProfile(
          id: StringUserId,
          name: name,
          email: email,
          phone: resolvedPhone,
          photoPath: data['user']['photo']?.toString() ?? '',
        );

        if (!mounted) return;

        // 4. SISTEM OTOMATIS MENENTUKAN REDIRECT BERDASARKAN ROLE
        if (role == 'mechanic') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MechanicHomePage()),
            (_) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (_) => false,
          );
        }
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);

      String errorMsg = "Gagal terhubung ke server.";
      if (e.response != null && e.response?.data['message'] != null) {
        errorMsg = e.response?.data['message'];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      lightBottom: true,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    top: -68,
                    right: -60,
                    child: _HeaderCircle(size: 192, color: Color(0x800F3460)),
                  ),
                  const Positioned(
                    top: 48,
                    left: -84,
                    child: _HeaderCircle(size: 158, color: Color(0x12FF6B35)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Bengkel ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Track',
                                style: TextStyle(color: AppColors.orange),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Masuk untuk lanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(.52),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                decoration: const BoxDecoration(color: Color(0xFFF9F8F6)),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6E1DA)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Nomor HP / Email'),
                          TextFormField(
                            controller: _emailCtrl,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: Colors.black),
                            decoration: authInputDecoration(
                              hint: 'Masukkan nomor HP atau email anda',
                              icon: Icons.person,
                            ).copyWith(
                              hintStyle: TextStyle(
                                color:
                                    _emailCtrl.text.trim().isEmpty
                                        ? AppColors.gray
                                        : Colors.black,
                              ),
                            ),
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Nomor HP atau email wajib diisi'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          _label('Password'),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _hide,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(color: Colors.black),
                            decoration: authInputDecoration(
                              hint: 'Masukkan password anda',
                              icon: Icons.lock,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hide
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _hide = !_hide),
                              ),
                            ).copyWith(
                              hintStyle: TextStyle(
                                color:
                                    _passCtrl.text.trim().isEmpty
                                        ? AppColors.gray
                                        : Colors.black,
                              ),
                            ),
                            validator:
                                (v) =>
                                    v == null || v.length < 8
                                        ? 'Password minimal 8 karakter'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                onChanged:
                                    (v) =>
                                        setState(() => _remember = v ?? false),
                                activeColor: AppColors.orange,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text(
                                'Ingat saya (opsional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Lupa password?',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OrangeButton(
                            text: _isLoading ? 'Memproses...' : 'Masuk',
                            onTap: _isLoading ? () {} : _login,
                            textStyle: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterStep1Page(),
                                  ),
                                );
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: 'Belum punya akun? ',
                                  style: TextStyle(color: AppColors.gray),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar Sekarang',
                                      style: TextStyle(
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      s,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.darkGray,
      ),
    ),
  );
}

class _HeaderCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _HeaderCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

String _normalizePhone(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('62')) return '+$digits';
  if (digits.startsWith('0')) return '+62${digits.substring(1)}';
  return '+62$digits';
}

bool _isPhoneInput(String input) {
  if (input.contains('@')) return false;
  final digits = input.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 8;
}
