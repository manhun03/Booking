import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
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

  static const Duration apiTimeout = Duration(seconds: 30);
  static const String loginEndpoint = '/auth/login';
  static const String invalidCredentials = 'Email hoac mat khau khong dung.';
  static const String networkError =
      'Khong ket noi duoc backend. Vui long thu lai.';
  static const String serverError =
      'Backend dang gap loi. Vui long thu lai sau.';
}
