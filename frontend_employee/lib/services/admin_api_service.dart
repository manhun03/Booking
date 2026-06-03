import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'auth_service.dart';

class AdminApiService {
  factory AdminApiService() => _instance;

  AdminApiService._();

  static final AdminApiService _instance = AdminApiService._();

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> fetchDashboard() => _getMap('/admin/dashboard');

  Future<List<Map<String, dynamic>>> fetchUsers({
    int pageIndex = 1,
    int pageSize = 100,
  }) => _getList('/users?pageIndex=$pageIndex&pageSize=$pageSize');

  Future<Map<String, dynamic>> fetchUser(int id) => _getMap('/users/$id');

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) =>
      _postMap('/users', body: user);

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> user) =>
      _putMap('/users/$id', body: user);

  Future<Map<String, dynamic>> lockUser(int id) =>
      _patchMap('/admin/users/$id/lock');

  Future<Map<String, dynamic>> unlockUser(int id) =>
      _patchMap('/admin/users/$id/unlock');

  Future<List<Map<String, dynamic>>> fetchRoles() => _getList('/roles');

  Future<List<Map<String, dynamic>>> fetchPermissions() =>
      _getList('/permissions');

  Future<List<Map<String, dynamic>>> fetchProvinces() => _getList('/provinces');

  Future<Map<String, dynamic>> createProvince(Map<String, dynamic> province) =>
      _postMap('/provinces', body: province);

  Future<Map<String, dynamic>> updateProvince(
    int id,
    Map<String, dynamic> province,
  ) => _putMap('/provinces/$id', body: province);

  Future<void> deleteProvince(int id) => _delete('/provinces/$id');

  Future<List<Map<String, dynamic>>> fetchWards({int? provinceId}) =>
      _getList(provinceId == null ? '/wards' : '/wards?provinceId=$provinceId');

  Future<Map<String, dynamic>> createWard(Map<String, dynamic> ward) =>
      _postMap('/wards', body: ward);

  Future<Map<String, dynamic>> updateWard(int id, Map<String, dynamic> ward) =>
      _putMap('/wards/$id', body: ward);

  Future<void> deleteWard(int id) => _delete('/wards/$id');

  Future<List<String>> fetchPermissionModules() async {
    final data = await _get('/permissions/modules');
    if (data is List) return data.map((item) => item.toString()).toList();
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<List<Map<String, dynamic>>> fetchHotels({
    int pageIndex = 1,
    int pageSize = 100,
  }) => _getList('/hotels?pageIndex=$pageIndex&pageSize=$pageSize');

  Future<Map<String, dynamic>> fetchHotel(int id) => _getMap('/hotels/$id');

  Future<Map<String, dynamic>> approveHotel(int id) =>
      _patchMap('/admin/hotels/$id/approve');

  Future<Map<String, dynamic>> rejectHotel(int id) =>
      _patchMap('/admin/hotels/$id/reject');

  Future<Map<String, dynamic>> lockHotel(int id) =>
      _patchMap('/admin/hotels/$id/lock');

  Future<Map<String, dynamic>> unlockHotel(int id) =>
      _patchMap('/admin/hotels/$id/unlock');

  Future<List<Map<String, dynamic>>> fetchBookings({
    int pageIndex = 1,
    int pageSize = 100,
  }) => _getList('/bookings?pageIndex=$pageIndex&pageSize=$pageSize');

  Future<Map<String, dynamic>> fetchBooking(int id) => _getMap('/bookings/$id');

  Future<Map<String, dynamic>> forceCompleteBooking(int id) =>
      _patchMap('/bookings/$id/force-complete');

  Future<List<Map<String, dynamic>>> fetchPayments() => _getList('/payments');

  Future<Map<String, dynamic>> refundPayment(
    int id, {
    num? amount,
    String? reason,
  }) {
    return _postMap(
      '/payments/$id/refund',
      body: {
        if (amount != null) 'amount': amount,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviewsForHotels(
    List<Map<String, dynamic>> hotels,
  ) async {
    final reviews = <Map<String, dynamic>>[];
    for (final hotel in hotels) {
      final hotelId = _intValue(hotel['id']);
      if (hotelId == null) continue;
      final hotelReviews = await fetchReviewsByHotel(hotelId);
      for (final review in hotelReviews) {
        reviews.add({
          ...review,
          'hotelId': hotelId,
          'hotelName': hotel['name'],
        });
      }
    }
    reviews.sort((left, right) {
      return (right['createdAt']?.toString() ?? '').compareTo(
        left['createdAt']?.toString() ?? '',
      );
    });
    return reviews;
  }

  Future<List<Map<String, dynamic>>> fetchReviewsByHotel(int hotelId) =>
      _getList('/reviews/by-hotel/$hotelId');

  Future<Map<String, dynamic>> moderateReview({
    required int id,
    required bool visible,
  }) => _postMap('/reviews/$id/moderate', body: {'visible': visible});

  Future<List<Map<String, dynamic>>> fetchNotifications() =>
      _getList('/notifications');

  Future<Map<String, dynamic>> markNotificationRead(int id) =>
      _postMap('/notifications/$id/read');

  Future<int> markMyNotificationsReadAll() async {
    final data = await _request('POST', '/notifications/read-all');
    if (data is int) return data;
    if (data is num) return data.toInt();
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchSystemConfigs() =>
      _getList('/admin/system-configs');

  Future<Map<String, dynamic>> updateSystemConfig({
    required String key,
    required String value,
    required String dataType,
    required String description,
  }) {
    final encodedKey = Uri.encodeComponent(key.trim());
    return _putMap(
      '/admin/system-configs/$encodedKey',
      body: {
        'configKey': key.trim(),
        'configValue': value.trim(),
        'dataType': dataType.trim().isEmpty ? 'string' : dataType.trim(),
        'description': description.trim(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs() =>
      _getList('/admin/audit-logs');

  Future<Map<String, dynamic>> fetchActuatorHealth() =>
      _requestRawMap('${AppConstants.backendBaseUrl}/actuator/health');

  Future<Map<String, dynamic>> fetchAiChatHealth() =>
      _requestRawMap('${AppConstants.apiBaseUrl}/ai-chat/health');

  Future<Map<String, dynamic>> _getMap(String endpoint) async {
    final data = await _get(endpoint);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final data = await _get(endpoint);
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> _postMap(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final data = await _request('POST', endpoint, body: body);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<Map<String, dynamic>> _putMap(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final data = await _request('PUT', endpoint, body: body);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<Map<String, dynamic>> _patchMap(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final data = await _request('PATCH', endpoint, body: body);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<dynamic> _get(String endpoint) => _request('GET', endpoint);

  Future<void> _delete(String endpoint) async {
    await AuthService().ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .delete(uri, headers: _headers)
        .timeout(AppConstants.apiTimeout);
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> _requestRawMap(String url) async {
    await AuthService().ensureActiveSession(url);
    final response = await _client
        .get(Uri.parse(url), headers: _headers)
        .timeout(AppConstants.apiTimeout);
    final decoded = _decodeResponse(response);
    final success = response.statusCode >= 200 && response.statusCode < 300;
    if (success && decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map<String, dynamic>) {
      throw ApiException(
        decoded['message']?.toString() ??
            'Yeu cau khong thanh cong (${response.statusCode}).',
      );
    }
    throw ApiException('Yeu cau khong thanh cong (${response.statusCode}).');
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await AuthService().ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = switch (method) {
      'GET' =>
        await _client
            .get(uri, headers: _headers)
            .timeout(AppConstants.apiTimeout),
      'POST' =>
        await _client
            .post(uri, headers: _headers, body: encodedBody ?? '{}')
            .timeout(AppConstants.apiTimeout),
      'PUT' =>
        await _client
            .put(uri, headers: _headers, body: encodedBody ?? '{}')
            .timeout(AppConstants.apiTimeout),
      'PATCH' =>
        await _client
            .patch(uri, headers: _headers, body: encodedBody ?? '{}')
            .timeout(AppConstants.apiTimeout),
      _ => throw ApiException('HTTP method khong ho tro: $method'),
    };
    return _handleResponse(response);
  }

  Map<String, String> get _headers {
    final token = AuthService().currentSession?.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException('Phien dang nhap da het han.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = _decodeResponse(response);
    final success = response.statusCode >= 200 && response.statusCode < 300;

    if (decoded is Map<String, dynamic>) {
      if (success && decoded['success'] != false) return decoded['data'];

      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw ApiException(errors.join('\n'));
      }

      throw ApiException(
        decoded['message']?.toString() ?? 'Yeu cau khong thanh cong.',
      );
    }

    if (success) return decoded;
    throw ApiException('Yeu cau khong thanh cong (${response.statusCode}).');
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

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'content', 'records']) {
        final value = data[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    throw const ApiException('Du lieu backend khong hop le.');
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
