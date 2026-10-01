import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'pages/auth/auth_gate.dart';

void main() {
  runApp(const BengkelTrackApp());
}

class BengkelTrackApp extends StatelessWidget {
  const BengkelTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bengkel Track',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange),
      ),
      home: const AuthGate(),
    );
  }
}
