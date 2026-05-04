import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/create_new_password_screen.dart';
import 'screens/otp_screen.dart';

import 'utils/theme.dart';

void main() {
  runApp(const HHBNBookingApp());
}

class HHBNBookingApp extends StatelessWidget {
  const HHBNBookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HHBN Booking',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/createNewPassword': (context) => const CreateNewPasswordScreen(),
      },
    );
  }
}
