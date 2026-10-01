import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/vehicle.dart';
import '../services/local_data_service.dart';

class VehicleFormPage extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormPage({super.key, this.vehicle});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String type;
  late String selectedYear;
  late String selectedTransmission;
  late String selectedColor;
  late bool isMainVehicle;

  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final platePrefixCtrl = TextEditingController(text: 'S');
  final plateCtrl = TextEditingController();

  bool get isEdit => widget.vehicle != null;

  final List<String> transmissions = ['Matic', 'Manual'];

  late final List<String> years;

  final List<Map<String, dynamic>> colors = [
    {'name': 'Putih', 'color': Colors.white},
    {'name': 'Hitam', 'color': Colors.black},
    {'name': 'Merah', 'color': Color(0xFFF04444)},
    {'name': 'Biru', 'color': Color(0xFF3B82F6)},
    {'name': 'Hijau', 'color': Color(0xFF22C55E)},
    {'name': 'Kuning', 'color': Color(0xFFF59E0B)},
    {'name': 'Ungu', 'color': Color(0xFF8B5CF6)},
    {'name': 'Abu', 'color': Color(0xFF6B7280)},
    {'name': 'Orange', 'color': Color(0xFFFF6534)},
    {'name': 'Custom', 'color': null},
  ];

  @override
  void initState() {
    super.initState();

    years = List.generate(
      30,
      (index) => (DateTime.now().year - index).toString(),
    );

    final v = widget.vehicle;

    type = v?.type ?? 'Motor';
    brandCtrl.text = v?.brand.isNotEmpty == true ? v!.brand : 'Honda';
    modelCtrl.text = v?.model.isNotEmpty == true ? v!.model : 'Beat Karbu';

    selectedYear =
        v?.year.isNotEmpty == true && years.contains(v!.year) ? v.year : '2011';

    selectedTransmission =
        v?.transmission.isNotEmpty == true &&
                transmissions.contains(v!.transmission)
            ? v.transmission
            : 'Matic';

    selectedColor = v?.color.isNotEmpty == true ? v!.color : 'Putih';

    platePrefixCtrl.text =
        v?.platePrefix.isNotEmpty == true ? v!.platePrefix : 'S';

    plateCtrl.text =
        v?.plateNumber.isNotEmpty == true ? v!.plateNumber : '5555 TLD';

    isMainVehicle = v?.isMain ?? true;
  }

  @override
  void dispose() {
    brandCtrl.dispose();
    modelCtrl.dispose();
    platePrefixCtrl.dispose();
    plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id:
          widget.vehicle?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      brand: brandCtrl.text.trim(),
      model: modelCtrl.text.trim(),
      year: selectedYear,
      transmission: selectedTransmission,
      color: selectedColor,
      platePrefix: platePrefixCtrl.text.trim().toUpperCase(),
      plateNumber: plateCtrl.text.trim().toUpperCase(),
      isMain: isMainVehicle,
    );

    await LocalDataService.upsertVehicle(vehicle);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tipe Kendaraan *'),
                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Expanded(
                            child: _TypeCard(
                              label: 'Motor',
                              icon: Icons.two_wheeler,
                              selected: type == 'Motor',
                              onTap: () => setState(() => type = 'Motor'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeCard(
                              label: 'Mobil',
                              icon: Icons.directions_car,
                              selected: type == 'Mobil',
                              onTap: () => setState(() => type = 'Mobil'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeCard(
                              label: 'Truk / Bus',
                              icon: Icons.local_shipping,
                              selected: type == 'Truk/Bus',
                              onTap: () => setState(() => type = 'Truk/Bus'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _label('Merk *'),
                      const SizedBox(height: 5),
                      _input(
                        controller: brandCtrl,
                        hint: 'Honda',
                        validatorText: 'Merk wajib diisi',
                      ),

                      const SizedBox(height: 10),
                      _label('Model *'),
                      const SizedBox(height: 5),
                      _input(
                        controller: modelCtrl,
                        hint: 'Beat Karbu',
                        validatorText: 'Model wajib diisi',
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Tahun *'),
                                const SizedBox(height: 5),
                                _dropdown(
                                  value: selectedYear,
                                  items: years,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => selectedYear = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Transmisi *'),
                                const SizedBox(height: 5),
                                _dropdown(
                                  value: selectedTransmission,
                                  items: transmissions,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(
                                        () => selectedTransmission = value,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _label('Warna Kendaraan *'),
                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 11,
                        runSpacing: 8,
                        children:
                            colors.map((item) {
                              final name = item['name'] as String;
                              final color = item['color'] as Color?;

                              return _ColorItem(
                                name: name,
                                color: color,
                                selected: selectedColor == name,
                                onTap:
                                    () => setState(() => selectedColor = name),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 12),
                      _label('Nomor Polisi *'),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: platePrefixCtrl,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.navy,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _input(
                              controller: plateCtrl,
                              hint: '5555 TLD',
                              validatorText: 'Nomor polisi wajib diisi',
                              textCapitalization: TextCapitalization.characters,
                              borderColor: AppColors.warmBorder,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.warmBorder),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jadikan kendaraan utama',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Otomatis dipilih saat order baru',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isMainVehicle,
                              activeColor: Colors.white,
                              activeTrackColor: AppColors.orange,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFDADADA),
                              onChanged: (value) {
                                setState(() => isMainVehicle = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Simpan Kendaraan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
    );
  }

  Widget _header() {
    return Container(
      height: 106,
      width: double.infinity,
      color: AppColors.navy,
      child: Stack(
        children: [
          const Positioned(
            right: -32,
            top: -34,
            child: CircleAvatar(radius: 64, backgroundColor: Color(0x223B82F6)),
          ),
          Positioned(
            left: 16,
            top: 36,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: AppColors.white15,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: 34,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Isi data kendaraan kamu',
                  style: TextStyle(color: Color(0xFFD9DDEB), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        color: AppColors.darkGray,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required String validatorText,
    Color borderColor = AppColors.orange,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        return null;
      },
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.red, width: 1.2),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.gray,
        size: 18,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.warmBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.2),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              ),
            );
          }).toList(),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF17172C) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    selected ? const Color(0xFF17172C) : AppColors.warmBorder,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: selected ? Colors.white : AppColors.gray,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: selected ? Colors.white : AppColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Positioned(
              right: 6,
              top: 5,
              child: CircleAvatar(
                radius: 7,
                backgroundColor: AppColors.orange,
                child: Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorItem extends StatelessWidget {
  final String name;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorItem({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = color == null;
    final isWhite = color == Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        child: Column(
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCustom ? Colors.white : color,
                border: Border.all(
                  color:
                      selected
                          ? AppColors.orange
                          : isWhite
                          ? AppColors.warmBorder
                          : Colors.transparent,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child:
                  isCustom
                      ? const Center(
                        child: Text('🎨', style: TextStyle(fontSize: 11)),
                      )
                      : selected
                      ? Icon(
                        Icons.check,
                        size: 15,
                        color:
                            isWhite || color == const Color(0xFFF59E0B)
                                ? AppColors.orange
                                : Colors.white,
                      )
                      : null,
            ),
            const SizedBox(height: 3),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: selected ? AppColors.orange : AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
