import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'auth_service.dart';

class OwnerApiService {
  factory OwnerApiService() => _instance;

  OwnerApiService._();

  static final OwnerApiService _instance = OwnerApiService._();

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> fetchDashboard() =>
      _getMap('/statistics/owner/dashboard');

  Future<List<Map<String, dynamic>>> fetchHotels() => _getList('/hotels/owner');

  Future<List<Map<String, dynamic>>> fetchRooms() => _getList('/rooms/owner');

  Future<List<Map<String, dynamic>>> fetchRoomTypes() =>
      _getList('/room-types');

  Future<Map<String, dynamic>> createHotel(Map<String, dynamic> hotel) =>
      _postMap('/hotels/owner', body: hotel);

  Future<Map<String, dynamic>> updateHotel(
    int id,
    Map<String, dynamic> hotel,
  ) => _putMap('/hotels/owner/$id', body: hotel);

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> room) =>
      _postMap('/rooms/owner', body: room);

  Future<Map<String, dynamic>> updateRoom(int id, Map<String, dynamic> room) =>
      _putMap('/rooms/owner/$id', body: room);

  Future<List<Map<String, dynamic>>> fetchBookings() =>
      _getList('/bookings?pageSize=100');

  Future<Map<String, dynamic>> fetchBooking(int id) => _getMap('/bookings/$id');

  Future<Map<String, dynamic>> confirmBooking(int id) =>
      _postMap('/bookings/$id/confirm');

  Future<Map<String, dynamic>> rejectBooking(int id) =>
      _postMap('/bookings/$id/reject', body: {});

  Future<Map<String, dynamic>> checkInBooking(int id) =>
      _postMap('/bookings/$id/check-in');

  Future<Map<String, dynamic>> checkOutBooking(int id) =>
      _postMap('/bookings/$id/check-out');

  Future<List<Map<String, dynamic>>> fetchRevenueChart({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _getList(
      '/statistics/owner/revenue?startDate=${_date(startDate)}&endDate=${_date(endDate)}',
    );
  }

  Future<Map<String, dynamic>> fetchRevenueComparison({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _getMap(
      '/statistics/owner/revenue-comparison?periodType=DAILY&currentStartDate=${_date(startDate)}&currentEndDate=${_date(endDate)}',
    );
  }

  Future<List<Map<String, dynamic>>> fetchTopRooms({int limit = 5}) =>
      _getList('/statistics/owner/top-rooms?limit=$limit');

  Future<List<Map<String, dynamic>>> fetchNotifications() =>
      _getList('/notifications/my');

  Future<void> markAllNotificationsRead() =>
      _post('/notifications/read-all', body: {});

  Future<void> markNotificationRead(int id) =>
      _post('/notifications/$id/read', body: {});

  Future<Map<String, dynamic>> fetchSettings() => _getMap('/owner/settings');

  Future<Map<String, dynamic>> updateSettings({
    required double depositRate,
    required int minBookingNotice,
    required bool allowReview,
  }) {
    return _putMap(
      '/owner/settings',
      body: {
        'depositRate': depositRate,
        'minBookingNotice': minBookingNotice,
        'allowReview': allowReview,
      },
    );
  }

  Future<bool> validateBankInfo() async {
    final data = await _get('/owner/settings/bank-info/validate');
    return data == true;
  }

  Future<Map<String, dynamic>> updateBankInfo({
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
  }) {
    return _putMap(
      '/owner/settings/bank-info',
      body: {
        'bankName': bankName.trim(),
        'bankAccountNumber': bankAccountNumber.trim(),
        'bankAccountName': bankAccountName.trim(),
        'bankQrCodeUrl': null,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviewsForHotels(
    List<Map<String, dynamic>> hotels,
  ) async {
    final results = <Map<String, dynamic>>[];
    for (final hotel in hotels) {
      final id = _intValue(hotel['id']);
      if (id == null) continue;
      final reviews = await _getList('/reviews/by-hotel/$id');
      for (final review in reviews) {
        results.add({...review, 'hotelName': hotel['name']});
      }
    }
    results.sort((left, right) {
      return (right['createdAt']?.toString() ?? '').compareTo(
        left['createdAt']?.toString() ?? '',
      );
    });
    return results;
  }

  Future<Map<String, dynamic>> replyReview(int id, String reply) =>
      _postMap('/reviews/$id/reply', body: {'reply': reply.trim()});

  Future<List<Map<String, dynamic>>> fetchConversations() =>
      _getList('/messages/conversations');

  Future<List<Map<String, dynamic>>> fetchMessages(int userId) =>
      _getList('/messages/conversation/$userId');

  Future<Map<String, dynamic>> markMessageRead(int id) =>
      _postMap('/messages/$id/read');

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  }) {
    return _postMap(
      '/messages',
      body: {
        'receiverId': receiverId,
        'bookingId': bookingId,
        'content': content.trim(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchPayments() => _getList('/payments');

  Future<Map<String, dynamic>> _getMap(String endpoint) async {
    final data = await _get(endpoint);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    final data = await _get(endpoint);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<Map<String, dynamic>> _postMap(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final data = await _post(endpoint, body: body);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<Map<String, dynamic>> _putMap(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    await AuthService().ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .put(uri, headers: _headers, body: jsonEncode(body))
        .timeout(AppConstants.apiTimeout);
    final data = _handleResponse(response);
    if (data is Map<String, dynamic>) return data;
    throw const ApiException('Du lieu backend khong hop le.');
  }

  Future<dynamic> _get(String endpoint) async {
    await AuthService().ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(AppConstants.apiTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> _post(String endpoint, {Map<String, dynamic>? body}) async {
    await AuthService().ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await _client
        .post(uri, headers: _headers, body: jsonEncode(body ?? const {}))
        .timeout(AppConstants.apiTimeout);
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

  String _date(DateTime value) {
    String two(int part) => part.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
