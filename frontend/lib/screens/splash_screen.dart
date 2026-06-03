import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  void _navigateToWelcome() {
    Timer(const Duration(seconds: 3), () {
      unawaited(_finishSplash());
    });
  }

  Future<void> _finishSplash() async {
    final hasSession = await ApiService().restoreSession();
    final isCustomer = ApiService().currentSession?.isCustomer ?? false;
    if (hasSession && !isCustomer) {
      ApiService().logout();
    }
    if (!mounted) return;
    unawaited(
      Navigator.of(context).pushReplacementNamed(
        hasSession && isCustomer ? '/home' : '/welcome',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.colorPrimary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // StaySmart Logo Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            const Text(
              AppStrings.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
