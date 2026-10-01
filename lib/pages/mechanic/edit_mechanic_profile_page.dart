import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // 1. PERBAIKAN: Wajib import Dio untuk mengatasi 'Undefined class Dio'

import '../../constants/app_colors.dart';
import '../../services/api.dart'; // 2. BEST PRACTICE: Siap digunakan jika memakai ApiService

class EditMechanicProfilePage extends StatefulWidget {
  const EditMechanicProfilePage({super.key});

  @override
  State<EditMechanicProfilePage> createState() =>
      _EditMechanicProfilePageState();
}

class _EditMechanicProfilePageState extends State<EditMechanicProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMechanicProfile();
  }

  Future<void> _loadMechanicProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = _cleanPhone(prefs.getString('phone') ?? '');
      _isLoading = false;
    });
  }

  String _cleanPhone(String value) {
    var text = value.replaceAll('+62', '').trim();
    if (text.startsWith('0')) text = text.substring(1);
    return text.trim();
  }

  String get _initials {
    final text = _nameController.text.trim();
    if (text.isEmpty) return 'M';
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _saveMechanicProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    try {
      // 3. IMPLEMENTASI BEST PRACTICE:
      // Menggunakan ApiService terpusat jauh lebih bersih daripada menginisialisasi BaseOptions manual di sini
      final response = await ApiService.client.put(
        '/profile/update',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': '+62 ${_phoneController.text.trim()}',
        },
      );

      if (response.statusCode == 200) {
        await prefs.setString('name', _nameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());
        await prefs.setString('phone', '+62 ${_phoneController.text.trim()}');

        if (mounted) Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      String errorMsg = "Gagal memperbarui profil di PostgreSQL server.";
      if (e.response != null && e.response?.data['message'] != null) {
        errorMsg = e.response?.data['message'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    // 4. PERBAIKAN: Menghapus 'boxShadow: appShadow' karena variabel appShadow belum di-import di file ini
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: const Color(0xFFFFE4DC),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: const Color(0xFFFF7043),
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'Nama Lengkap Mekanik',
                          controller: _nameController,
                          icon: Icons.person,
                          validatorText: 'Nama lengkap wajib diisi',
                        ),
                        const SizedBox(height: 16),
                        _buildPhoneField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Email Aktif',
                          controller: _emailController,
                          icon: Icons.email,
                          validatorText: 'Email wajib diisi',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
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

  Widget _buildHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFF10163A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 50,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Edit Profil Mekanik',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 0,
            child: GestureDetector(
              onTap: _saveMechanicProfile,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator:
              (v) => v == null || v.trim().isEmpty ? validatorText : null,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F8F6),
            prefixIcon: Icon(icon, color: const Color(0xFFFF7043), size: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF7043),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor HP / WhatsApp',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator:
              (v) =>
                  v == null || v.trim().isEmpty ? 'Nomor HP wajib diisi' : null,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F8F6),
            prefixIcon: Container(
              width: 56,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: const Text(
                '+62',
                style: TextStyle(
                  color: Color(0xFFFF7043),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF7043),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
