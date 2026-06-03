// Template for API Service - Uncomment and implement when ready
// To use this service:
// 1. Add 'http' package to pubspec.yaml
// 2. Uncomment this file
// 3. Implement the actual API calls

/*
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  // Create a named constructor
  ApiService._privateConstructor();
  
  // Single instance throughout the app
  static final ApiService _instance = ApiService._privateConstructor();
  
  // Factory to return the instance
  factory ApiService() {
    return _instance;
  }

  // HTTP client
  final http.Client _httpClient = http.Client();

  // Headers
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Login API
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Save token here
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception(AppConstants.invalidCredentials);
      } else {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception(AppConstants.networkError);
    }
  }

  // Sign up API
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.signupEndpoint}'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception(AppConstants.networkError);
    }
  }

  // Google Login API
  Future<Map<String, dynamic>> googleLogin({required String token}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.googleLoginEndpoint}'),
        headers: _headers,
        body: json.encode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception(AppConstants.networkError);
    }
  }

  // Forgot Password API
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.forgotPasswordEndpoint}'),
        headers: _headers,
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception(AppConstants.networkError);
    }
  }

  // Reset Password API
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.resetPasswordEndpoint}'),
        headers: _headers,
        body: json.encode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception(AppConstants.networkError);
    }
  }

  // Dispose
  void dispose() {
    _httpClient.close();
  }
}
*/
