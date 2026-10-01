import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'auth_widgets.dart';
import 'verification_success_page.dart';

class RegisterStep2Page extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  const RegisterStep2Page({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  final _formKey = GlobalKey<FormState>();
  String vehicle = 'Motor';
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final platePrefixCtrl = TextEditingController(text: 'S');
  final plateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    brandCtrl.dispose();
    modelCtrl.dispose();
    yearCtrl.dispose();
    colorCtrl.dispose();
    platePrefixCtrl.dispose();
    plateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (_) => VerificationSuccessPage(
              name: widget.name,
              phone: widget.phone,
              email: widget.email,
            ),
      ),
      (_) => false,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User wajib klik tombol, tidak bisa asal klik di luar skrin
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              18,
            ), // Sesuai dengan border radius card bawaanmu
          ),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color:
                    AppColors
                        .brightGreen, // Menggunakan konstanta warna milikmu
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pendaftaran Berhasil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Syne', // Konsisten dengan font header halaman
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          content: const Text(
            'Akun Bengkel Tracker kamu telah berhasil dibuat. Silakan masuk untuk mulai menggunakan layanan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: AppColors.darkGray,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width:
                  double
                      .infinity, // Membuat tombol lebar penuh agar mudah ditekan di HP
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: OrangeButton(
                  // Menggunakan widget tombol kustom bawaan proyekmu
                  text: 'Masuk Sekarang',
                  onTap: () {
                    // 1. Tutup pop-up dialog terlebih dahulu
                    Navigator.of(context).pop();

                    // 2. Alihkan ke halaman sukses bawaanmu atau langsung ke LoginPage
                    // Menggunakan pushAndRemoveUntil agar tumpukan backstack register bersih total
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => VerificationSuccessPage(
                              name: widget.name,
                              phone: widget.phone,
                              email: widget.email,
                            ),
                      ),
                      (_) => false,
                    );
                  },
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      lightBottom: true,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF9F8F6),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _card(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    height: 186,
    child: Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.navy),
          ),
        ),
        Positioned(
          top: -62,
          right: -42,
          child: _HeaderCircle(size: 198, color: const Color(0x800F3460)),
        ),
        Positioned(
          top: 42,
          left: -76,
          child: _HeaderCircle(size: 150, color: const Color(0x800F3460)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    'Data Kendaraan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      height: 0.95,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 42),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StepDone(label: 'Data Diri'),
                  _StepActive(label: 'Kendaraan'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _card() => Container(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE6E1DA)),
    ),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Jenis Kendaraan *'),
            Row(
              children: [
                _VehicleOption(
                  label: 'Motor',
                  icon: Icons.two_wheeler,
                  selected: vehicle == 'Motor',
                  onTap: () => setState(() => vehicle = 'Motor'),
                ),
                const SizedBox(width: 8),
                _VehicleOption(
                  label: 'Mobil',
                  icon: Icons.directions_car,
                  selected: vehicle == 'Mobil',
                  onTap: () => setState(() => vehicle = 'Mobil'),
                ),
                const SizedBox(width: 8),
                _VehicleOption(
                  label: 'Truk/Bus',
                  icon: Icons.local_shipping,
                  selected: vehicle == 'Truk/Bus',
                  onTap: () => setState(() => vehicle = 'Truk/Bus'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _label('Merk *'),
            TextFormField(
              controller: brandCtrl,
              onChanged: (_) => setState(() {}),
              decoration: _hintDecoration(
                hint: _brandHint(),
                icon: _vehicleFieldIcon(),
                suffixIcon: _fieldCheckIcon(brandCtrl.text.trim().isNotEmpty),
                hasText: brandCtrl.text.trim().isNotEmpty,
              ),
              validator: _required,
            ),
            const SizedBox(height: 8),
            _label('Model *'),
            TextFormField(
              controller: modelCtrl,
              onChanged: (_) => setState(() {}),
              decoration: _hintDecoration(
                hint: _modelHint(),
                icon: _vehicleFieldIcon(),
                suffixIcon: _fieldCheckIcon(modelCtrl.text.trim().isNotEmpty),
                hasText: modelCtrl.text.trim().isNotEmpty,
              ),
              validator: _required,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tahun *'),
                      TextFormField(
                        controller: yearCtrl,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        decoration: _hintDecoration(
                          hint: 'Isi Tahun Kendaraan (misal: 2010)',
                          icon: Icons.calendar_month,
                          hasText: yearCtrl.text.trim().isNotEmpty,
                        ),
                        validator: _required,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Warna'),
                      TextFormField(
                        controller: colorCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: _hintDecoration(
                          hint: 'Tuliskan warna kendaraan',
                          icon: Icons.circle,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 8),
                            child: Center(
                              widthFactor: 1,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: _colorForName(colorCtrl.text),
                              ),
                            ),
                          ),
                          hasText: colorCtrl.text.trim().isNotEmpty,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _label('Nomor Polisi *'),
            Row(
              children: [
                SizedBox(width: 56, child: _platePrefixField()),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: plateCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: _hintDecoration(
                      hint: '5555 TLD',
                      icon: Icons.confirmation_number,
                      hasText: plateCtrl.text.trim().isNotEmpty,
                    ),
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrangeButton(
              text: 'Masuk',
              onTap: _submit,
              textStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    ),
  );
  InputDecoration _hintDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    Widget? prefix,
    required bool hasText,
  }) {
    return authInputDecoration(
      hint: hint,
      icon: icon,
      suffixIcon: suffixIcon,
      prefix: prefix,
    ).copyWith(
      hintStyle: TextStyle(color: hasText ? Colors.black : AppColors.gray),
    );
  }

  Widget? _fieldCheckIcon(bool show) =>
      show
          ? const Icon(Icons.check_circle, color: AppColors.brightGreen)
          : null;

  IconData _vehicleFieldIcon() {
    switch (vehicle) {
      case 'Mobil':
        return Icons.directions_car;
      case 'Truk/Bus':
        return Icons.local_shipping;
      default:
        return Icons.two_wheeler;
    }
  }

  String _brandHint() {
    switch (vehicle) {
      case 'Mobil':
        return 'Tuliskan Merk Mobil (misal: Toyota)';
      case 'Truk/Bus':
        return 'Tuliskan Merk Truk/Bus (misal: Mercedes-Benz)';
      default:
        return 'Tuliskan Merk Motor (misal: Honda)';
    }
  }

  String _modelHint() {
    switch (vehicle) {
      case 'Mobil':
        return 'Tuliskan Model Mobil (misal: Avanza)';
      case 'Truk/Bus':
        return 'Tuliskan Model Truk/Bus (misal: Dutro)';
      default:
        return 'Tuliskan Model Motor (misal: Beat)';
    }
  }

  Widget _platePrefixField() {
    return TextFormField(
      controller: platePrefixCtrl,
      textAlign: TextAlign.center,
      maxLength: 2,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color:
            platePrefixCtrl.text.trim().isEmpty ? AppColors.gray : Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor:
            platePrefixCtrl.text.trim().isEmpty
                ? const Color(0xFFF8F7F5)
                : AppColors.navy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7E3DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
        ),
        hintText: 'S',
        hintStyle: const TextStyle(
          color: AppColors.gray,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorForName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'hitam':
        return const Color(0xFF111827);
      case 'putih':
        return const Color(0xFFF8FAFC);
      case 'merah':
        return AppColors.red;
      case 'biru':
        return AppColors.blue;
      case 'pink':
        return const Color(0xFFF472B6);
      case 'ungu':
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'hijau':
        return AppColors.brightGreen;
      case 'kuning':
        return AppColors.yellow;
      case 'oranye':
      case 'orange':
        return AppColors.orange;
      case 'silver':
        return const Color(0xFFCBD5E1);
      case 'abu-abu':
      case 'abu abu':
        return AppColors.darkGray;
      case 'coklat':
        return AppColors.brown;
      default:
        return const Color(0xFFD4D1CD);
    }
  }

  String? _required(String? v) => v == null || v.isEmpty ? 'Wajib diisi' : null;
  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
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

class _VehicleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : const Color(0xFFF8F7F5),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE6E1DA)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppColors.gray,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: selected ? Colors.white : AppColors.gray,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDone extends StatelessWidget {
  final String label;
  const _StepDone({required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.brightGreen,
        child: Icon(Icons.check, color: Colors.white, size: 18),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          color: AppColors.brightGreen,
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

class _StepActive extends StatelessWidget {
  final String label;
  const _StepActive({required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.orange,
        child: Text(
          '2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10.5,
          color: AppColors.orange,
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _HeaderCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _HeaderCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
