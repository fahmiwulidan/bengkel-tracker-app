import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool lightBottom;
  const AuthBackground({super.key, required this.child, this.lightBottom = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBottom ? const Color(0xFFF9F8F6) : const Color(0xFF12172E),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: lightBottom
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF11142B), Color(0xFF0A3B67)],
                      ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _BgPainter(lightBottom: lightBottom)),
          ),
          child,
        ],
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  final bool lightBottom;
  _BgPainter({required this.lightBottom});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = const Color(0xFF6A2F38).withOpacity(.25);
    canvas.drawCircle(Offset(size.width * .93, size.height * .12), 140, p1);
    if (lightBottom) {
      canvas.drawCircle(Offset(size.width * .10, size.height * .22), 70, p1);
      canvas.drawCircle(Offset(size.width * .90, size.height * .06), 100, Paint()..color = const Color(0xFF0D4770).withOpacity(.52));
    } else {
      canvas.drawCircle(Offset(size.width * .05, size.height * .86), 120, Paint()..color = const Color(0xFF6A2F38).withOpacity(.23));
      canvas.drawCircle(Offset(size.width * .80, size.height * .82), 80, Paint()..color = const Color(0xFF064A78).withOpacity(.42));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OrangeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  const OrangeButton({super.key, required this.text, this.onTap, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textStyle ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
  Widget? prefix,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: prefix ?? Icon(icon, color: const Color(0xFFC9C9C9), size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFFF8F7F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE7E3DD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.orange),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
    ),
  );
}
