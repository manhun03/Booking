import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'session_store.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthSession {
  const AuthSession({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.fullName,
    this.roles = const [],
    this.accessTokenExpiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: _intValue(json['userId']),
      fullName: _stringValue(json['fullName']),
      email: _stringValue(json['email']) ?? '',
      roles: _stringList(json['roles']),
      accessToken: _stringValue(json['accessToken']) ?? '',
      refreshToken: _stringValue(json['refreshToken']) ?? '',
      accessTokenExpiresAt: _dateTimeValue(json['accessTokenExpiresAt']),
    );
  }

  final int? userId;
  final String? fullName;
  final String email;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;

  bool hasRole(String roleName) {
    final expected = _normalizeRole(roleName);
    return roles.any((role) => _normalizeRole(role) == expected);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'roles': roles,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt?.toIso8601String(),
    };
  }

  static String _normalizeRole(String value) {
    return value.toLowerCase().replaceFirst('role_', '').trim();
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static DateTime? _dateTimeValue(dynamic value) {
    final text = _stringValue(value);
    return text == null ? null : DateTime.tryParse(text);
  }
}

class AuthService {
  factory AuthService() => _instance;

  AuthService._();

  static final AuthService _instance = AuthService._();

  final http.Client _client = http.Client();
  AuthSession? _session;
  bool _restoreAttempted = false;

  AuthSession? get currentSession => _session;

  bool get isAuthenticated =>
      _session != null && _session!.accessToken.trim().isNotEmpty;

  bool get isAdmin => _session?.hasRole('Admin') ?? false;
  bool get isOwner => _session?.hasRole('Owner') ?? false;
  bool get isStaff => isAdmin || isOwner;

  String? get staffLandingRoute {
    if (isAdmin) return '/admin-dashboard';
    if (isOwner) return '/home';
    return null;
  }

  Future<bool> restoreSession({bool force = false}) async {
    if (_session != null && !force) return true;
    if (_restoreAttempted && !force) return isAuthenticated;

    _restoreAttempted = true;
    final stored = readStoredSession();
    if (stored == null || stored.trim().isEmpty) return false;

    try {
      final decoded = jsonDecode(stored);
      if (decoded is! Map<String, dynamic>) {
        clearStoredSession();
        return false;
      }

      final session = AuthSession.fromJson(decoded);
      if (session.accessToken.isEmpty) {
        clearStoredSession();
        return false;
      }

      _session = session;
      if (!isStaff) {
        logout();
        return false;
      }

      return true;
    } catch (_) {
      _session = null;
      clearStoredSession();
      return false;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      AppConstants.loginEndpoint,
      body: {'email': email.trim(), 'password': password},
    );

    final session = _setSession(data);
    if (!isStaff) {
      logout();
      throw const ApiException(
        'Tai khoan nay khong co quyen truy cap cong quan tri.',
      );
    }

    return session;
  }

  Future<Map<String, dynamic>> fetchAdminDashboard() async {
    final data = await _get('/admin/dashboard');
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  void logout() {
    _session = null;
    clearStoredSession();
  }

  Future<dynamic> _get(String endpoint) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> _post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = _session?.accessToken;
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = _decodeResponse(response);
    final isSuccessStatus =
        response.statusCode >= 200 && response.statusCode < 300;

    if (decoded is Map<String, dynamic>) {
      final apiSuccess = decoded['success'];
      final message = decoded['message']?.toString();
      final errors = decoded['errors'];

      if (isSuccessStatus && apiSuccess != false) {
        return decoded['data'];
      }

      if (errors is List && errors.isNotEmpty) {
        throw ApiException(errors.join('\n'));
      }

      throw ApiException(
        message == null || message.isEmpty
            ? _defaultErrorMessage(response.statusCode)
            : message,
      );
    }

    if (isSuccessStatus) return decoded;
    throw ApiException(_defaultErrorMessage(response.statusCode));
  }

  dynamic _decodeResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  AuthSession _setSession(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phan hoi dang nhap khong hop le.');
    }

    final session = AuthSession.fromJson(data);
    if (session.accessToken.isEmpty) {
      throw const ApiException('Backend khong tra ve token dang nhap.');
    }

    _session = session;
    writeStoredSession(jsonEncode(session.toJson()));
    return session;
  }

  String _defaultErrorMessage(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return AppConstants.invalidCredentials;
    }
    if (statusCode >= 500) return AppConstants.serverError;
    return AppConstants.networkError;
  }
}
