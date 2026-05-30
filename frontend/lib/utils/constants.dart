import 'package:flutter/foundation.dart';

class AppConstants {
  // App info
  static const String appName = 'StaySmart';
  static const String appVersion = '1.0.0';
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '883824205385-182f65ondho5qnima9ladd5j7qk2b40h.apps.googleusercontent.com',
  );

  static String get backendBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride.replaceFirst(RegExp(r'/api/?$'), '');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    return '$backendBaseUrl/api';
  }

  static String get chatWebSocketUrl {
    final baseUrl = backendBaseUrl.replaceFirst(RegExp(r'/$'), '');
    if (baseUrl.startsWith('https://')) {
      return 'wss://${baseUrl.substring('https://'.length)}/ws';
    }
    if (baseUrl.startsWith('http://')) {
      return 'ws://${baseUrl.substring('http://'.length)}/ws';
    }
    return '$baseUrl/ws';
  }

  // Durations
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Padding and margins
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double smallBorderRadius = 4.0;

  // Font sizes
  static const double largeHeadline = 28.0;
  static const double mediumHeadline = 24.0;
  static const double smallHeadline = 20.0;
  static const double bodyTextLarge = 16.0;
  static const double bodyTextMedium = 14.0;
  static const double bodyTextSmall = 12.0;
  static const double labelText = 13.0;

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/register';
  static const String googleLoginEndpoint = '/auth/google';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // Error messages
  static const String networkError =
      'Network error occurred. Please check your connection.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
}
