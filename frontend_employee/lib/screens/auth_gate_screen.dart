import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_redirect());
  }

  Future<void> _redirect() async {
    await AuthService().restoreSession();
    if (!mounted) return;

    final route = AuthService().staffLandingRoute ?? '/welcome';
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
