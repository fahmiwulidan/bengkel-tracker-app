import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page.dart';
import '../mechanic/mechanic_home_page.dart';
import 'home_splash_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _isLoggedIn;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final String role = prefs.getString('role') ?? 'customer';

    setState(() {
      _isLoggedIn = isLoggedIn;
      _role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn!) {
      return const HomeSplashPage();
    }

    if (_role == 'mechanic') {
      return const MechanicHomePage();
    }

    return const HomePage();
  }
}
