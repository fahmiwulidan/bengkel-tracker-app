import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../services/local_data_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _photoPath = '';
  String _userId = '1'; // ✅ Tambahkan variabel untuk menampung ID user aktif

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalDataService.getProfile();
    _userId =
        profile['id'] ?? '1'; // ✅ Ambil ID asli dari SharedPreferences lokal
    _nameController.text = profile['name'] ?? 'Pengguna';
    _emailController.text = profile['email'] ?? 'pengguna@gmail.com';

    final rawPhone = profile['phone'] ?? '';
    _phoneController.text = rawPhone.isNotEmpty ? _cleanPhone(rawPhone) : '';

    _photoPath = profile['photo'] ?? '';
    if (mounted) setState(() {});
  }

  String _cleanPhone(String value) {
    var text = value.replaceAll('+62', '').trim();
    if (text.startsWith('0')) text = text.substring(1);
    return text.trim();
  }

  String get _initials {
    final text = _nameController.text.trim();
    if (text.isEmpty) return 'FW';
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ PERBAIKAN 1: Oper parameter 'id' yang required ke LocalDataService
    await LocalDataService.saveProfile(
      id: _userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '+62 ${_phoneController.text.trim()}',
      photoPath: _photoPath,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context), onSave: _saveProfile),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 54, 16, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 70),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.warmBorder),
                    // ✅ PERBAIKAN 2: Ganti 'appShadow' kustom dengan BoxShadow bawaan yang aman
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _ProfilePhoto(
                          initials: _initials,
                          photoPath: _photoPath,
                          onTap: _pickPhoto,
                        ),
                        const SizedBox(height: 25),
                        const Divider(height: 1, color: Color(0xFFF1EFEA)),
                        const SizedBox(height: 21),
                        _ValidatedField(
                          label: 'Nama Lengkap',
                          controller: _nameController,
                          icon: Icons.person,
                          validatorText: 'Nama lengkap wajib diisi',
                        ),
                        const SizedBox(height: 13),
                        _PhoneField(controller: _phoneController),
                        const SizedBox(height: 13),
                        _EmailField(controller: _emailController),
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
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  const _Header({required this.onBack, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      color: AppColors.navy,
      child: Stack(
        children: [
          const Positioned(
            right: -44,
            top: -66,
            child: CircleAvatar(radius: 94, backgroundColor: Color(0x333B82F6)),
          ),
          Positioned(
            left: 18,
            top: 42,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white15,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 49,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Edit Profil',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 42,
            right: 16,
            child: GestureDetector(
              onTap: onSave,
              child: Container(
                height: 31,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(11),
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
}

class _ProfilePhoto extends StatelessWidget {
  final String initials;
  final String photoPath;
  final VoidCallback onTap;
  const _ProfilePhoto({
    required this.initials,
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFFFFE4DC),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.orange,
                  backgroundImage: _avatarImage(photoPath),
                  child:
                      photoPath.isEmpty
                          ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                          : null,
                ),
              ),
              Positioned(
                right: 6,
                bottom: 7,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Ganti Profil',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _avatarImage(String photoPath) {
    if (photoPath.isEmpty) return null;
    if (kIsWeb) return NetworkImage(photoPath);
    return FileImage(File(photoPath));
  }
}

class _ValidatedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String validatorText;
  const _ValidatedField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.validatorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator:
              (value) =>
                  value == null || value.trim().isEmpty ? validatorText : null,
          onChanged: (_) => (context as Element).markNeedsBuild(),
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 0,
            ),
            prefixIcon: _FieldIcon(icon: icon),
            suffixIcon:
                controller.text.trim().isEmpty
                    ? null
                    : const Icon(
                      Icons.check_circle,
                      color: AppColors.brightGreen,
                      size: 20,
                    ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor HP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Nomor HP wajib diisi'
                      : null,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F8F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            prefixIcon: Container(
              width: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.warmBorder)),
              ),
              child: const Text(
                '+62',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.warmBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Email wajib diisi'
                      : null,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F8F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            prefixIcon: const _FieldIcon(icon: Icons.email),
            suffixIcon: TextButton(
              onPressed: () {},
              child: const Text(
                'Ubah',
                style: TextStyle(color: AppColors.orange, fontSize: 12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.warmBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.red, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldIcon extends StatelessWidget {
  final IconData icon;
  const _FieldIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.warmBorder)),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 11,
          backgroundColor: const Color(0xFFD0D0D0),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
