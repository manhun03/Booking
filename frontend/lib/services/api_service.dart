import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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

  bool get isCustomer => hasRole('Customer');

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

class ApiService {
  factory ApiService() => _instance;

  ApiService._();

  static final ApiService _instance = ApiService._();

  final http.Client _client = http.Client();

  AuthSession? _session;
  Map<String, dynamic>? _cachedUser;
  final ValueNotifier<int> _profileVersion = ValueNotifier<int>(0);
  bool _restoreAttempted = false;

  AuthSession? get currentSession => _session;
  Map<String, dynamic>? get cachedUser => _cachedUser;
  ValueNotifier<int> get profileVersion => _profileVersion;

  bool get isAuthenticated =>
      _session != null && _session!.accessToken.trim().isNotEmpty;

  Future<bool> restoreSession({bool force = false}) async {
    if (_session != null && !force) {
      return true;
    }
    if (_restoreAttempted && !force) {
      return isAuthenticated;
    }

    _restoreAttempted = true;
    final stored = readStoredSession();
    if (stored == null || stored.trim().isEmpty) {
      return false;
    }

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
      if (_shouldRefreshSession(session)) {
        await refreshSession();
      }

      return isAuthenticated;
    } on ApiException {
      _session = null;
      _cachedUser = null;
      clearStoredSession();
      return false;
    } catch (_) {
      return isAuthenticated;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      AppConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    return _setSession(data);
  }

  Future<AuthSession> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    final nameParts = _splitFullName(fullName);
    final data = await _post(
      AppConstants.signupEndpoint,
      body: {
        'lastName': nameParts.lastName,
        'firstName': nameParts.firstName,
        'username': username.trim(),
        'email': email,
        'password': password,
        'role': 'Customer',
      },
    );

    return _setSession(data);
  }

  Future<AuthSession> loginWithGoogle({
    required String idToken,
    String role = 'Customer',
  }) async {
    final data = await _post(
      AppConstants.googleLoginEndpoint,
      body: {
        'idToken': idToken.trim(),
        'role': role,
      },
    );

    return _setSession(data);
  }

  Future<AuthSession> refreshSession() async {
    final refreshToken = _session?.refreshToken.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException('Refresh token was not found.');
    }

    final data = await _post(
      '/auth/refresh-token',
      body: {'refreshToken': refreshToken},
    );
    return _setSession(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _post(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> sendEmailVerification({
    required String email,
  }) async {
    final data = await _post(
      '/auth/send-email-verification',
      body: {'email': email.trim()},
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid email verification response.');
    }
    return {
      'message': _stringValue(data['message']) ?? '',
      'token': _stringValue(data['token']),
      'expiresAt': _dateTimeValue(data['expiresAt']),
      'backend': data,
    };
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String token,
  }) async {
    final data = await _post(
      '/auth/verify-email',
      body: {'token': token.trim()},
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid email verification response.');
    }
    return {
      'message': _stringValue(data['message']) ?? '',
      'backend': data,
    };
  }

  Future<List<Map<String, dynamic>>> fetchChatConversations() async {
    final data = await _get('/messages/conversations');
    return _listFromData(data).map(_mapChatConversation).toList();
  }

  Future<List<Map<String, dynamic>>> fetchChatContacts() async {
    final data = await _get('/messages/contacts');
    return _listFromData(data).map(_mapChatConversation).toList();
  }

  Future<List<Map<String, dynamic>>> fetchChatMessages(int otherUserId) async {
    final data = await _get('/messages/conversation/$otherUserId');
    return _listFromData(data).map(_mapChatMessage).toList();
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  }) async {
    final data = await _post(
      '/messages',
      body: {
        'receiverId': receiverId,
        'bookingId': bookingId,
        'content': content,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid chat message response.');
    }
    return _mapChatMessage(data);
  }

  Future<Map<String, dynamic>> markChatMessageRead(int id) async {
    final data = await _post('/messages/$id/read');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid chat message response.');
    }
    return _mapChatMessage(data);
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final data = await _get('/notifications/my');
    return _listFromData(data).map(_mapNotification).toList();
  }

  Future<void> markNotificationRead(int id) async {
    await _post('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _post('/notifications/read-all');
  }

  Future<void> registerFcmToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('FCM token cannot be empty.');
    }
    await _post('/users/fcm-token', body: {'token': trimmed});
  }

  Future<Map<String, dynamic>> sendAiChatMessage({
    required String message,
    String? threadId,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const ApiException('Message cannot be empty.');
    }

    final data = await _postRaw(
      '/ai-chat/chat',
      body: {
        'message': trimmedMessage,
        if (threadId != null && threadId.trim().isNotEmpty)
          'threadId': threadId.trim(),
      },
    );

    return _mapAiChatResponse(data);
  }

  Future<List<Map<String, dynamic>>> fetchCoupons() async {
    try {
      final data = await _get('/coupons/active');
      return _activeCouponsFromData(data);
    } on ApiException {
      final data = await _get('/coupons');
      return _activeCouponsFromData(data);
    }
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required num amount,
  }) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const ApiException('Coupon code cannot be empty.');
    }
    final data = await _get(
      '/coupons/validate',
      queryParameters: {'code': normalizedCode, 'amount': amount},
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid coupon validation response.');
    }
    return {
      'code': _stringValue(data['code']) ?? normalizedCode,
      'discountAmount': _numValue(data['discountAmount']) ?? 0,
      'finalAmount': _numValue(data['finalAmount']) ?? amount,
      'backend': data,
    };
  }

  Future<List<Map<String, dynamic>>> fetchHotels({
    String? keyword,
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final trimmedKeyword = keyword?.trim();
    final data = trimmedKeyword == null || trimmedKeyword.isEmpty
        ? await _get(
            '/hotels/all-with-province',
            queryParameters: {
              'pageIndex': pageIndex,
              'pageSize': pageSize,
            },
          )
        : await _get(
            '/hotels/search',
            queryParameters: {'keyword': trimmedKeyword},
          );

    return _listFromData(data).map(_mapHotel).toList();
  }

  Future<Map<String, dynamic>> fetchHotel(int id) async {
    final data = await _get('/hotels/$id/with-location');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid hotel response.');
    }
    return _mapHotel(data);
  }

  Future<List<Map<String, dynamic>>> fetchHotelImages(int hotelId) async {
    final data = await _get('/hotels/$hotelId/images/ordered');
    return _listFromData(data).map(_mapHotelImage).toList();
  }

  Future<List<Map<String, dynamic>>> fetchReviewsByHotel(int hotelId) async {
    final data = await _get('/reviews/by-hotel/$hotelId');
    return _listFromData(data);
  }

  Future<Map<String, dynamic>> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    final trimmedComment = comment?.trim();
    final data = await _post(
      '/reviews',
      body: {
        'bookingId': bookingId,
        'rating': rating,
        if (trimmedComment != null && trimmedComment.isNotEmpty)
          'comment': trimmedComment,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid review response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> createHotel({
    required String name,
    required String street,
    required String phone,
    required String description,
    int? wardId,
    String status = 'ACTIVE',
  }) async {
    final data = await _post(
      '/hotels',
      body: {
        'name': name,
        'street': street,
        'phone': phone,
        'description': description,
        'wardId': wardId,
        'status': status,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid hotel response.');
    }
    return _mapHotel(data['data'] ?? data);
  }

  Future<Map<String, dynamic>> updateHotel({
    required int id,
    required String name,
    required String street,
    required String phone,
    required String description,
    String status = 'ACTIVE',
  }) async {
    final data = await _put(
      '/hotels/$id',
      body: {
        'name': name,
        'street': street,
        'phone': phone,
        'description': description,
        'status': status,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid hotel response.');
    }
    return _mapHotel(data['data'] ?? data);
  }

  Future<void> deleteHotel(int id) async {
    await _delete('/hotels/$id');
  }

  Future<List<Map<String, dynamic>>> fetchRoomsByHotel(int hotelId) async {
    final data = await _get(
      '/rooms/by-hotel',
      queryParameters: {'hotelId': hotelId},
    );

    return _listFromData(data).map(_mapRoom).toList();
  }

  Future<int?> fetchRoomPriceForDates({
    required int roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    final data = await _get('/time-slots/room/$roomId');
    final checkIn = _dateOnlyUtc(checkInDate);
    final checkOut = _dateOnlyUtc(checkOutDate);

    for (final slot in _listFromData(data)) {
      if (slot['active'] != true) continue;
      final start = _dateTimeValue(slot['startDate']);
      final end = _dateTimeValue(slot['endDate']);
      if (start == null || end == null) continue;
      if (!start.toUtc().isAfter(checkIn) && !end.toUtc().isBefore(checkOut)) {
        return _numValue(slot['price'])?.round();
      }
    }
    return null;
  }

  Future<Map<String, bool>> fetchRoomAvailability({
    required int roomId,
    required DateTime from,
    required DateTime to,
    int? excludedBookingId,
  }) async {
    final data = await _get(
      '/time-slots/room/$roomId/availability',
      queryParameters: {
        'from': _dateKey(from),
        'to': _dateKey(to),
        if (excludedBookingId != null) 'excludedBookingId': excludedBookingId,
      },
    );

    final availability = <String, bool>{};
    for (final item in _listFromData(data)) {
      final date = _stringValue(item['date']);
      if (date == null) continue;
      availability[date] = item['available'] == true;
    }
    return availability;
  }

  Future<List<Map<String, dynamic>>> fetchMyBookings({
    int pageIndex = 1,
    int pageSize = 50,
  }) async {
    final data = await _get(
      '/bookings/my-bookings',
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );

    return _listFromData(data).map(_mapBooking).toList();
  }

  Future<Map<String, dynamic>> createBooking({
    required int roomId,
    required int guestCount,
    required int paidAmount,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? customerAddress,
    String? note,
    String? paymentMethod,
  }) async {
    final checkIn = _dateOnlyUtc(
      checkInDate ?? DateTime.now().add(const Duration(days: 1)),
    );
    final checkOut =
        _dateOnlyUtc(checkOutDate ?? checkIn.add(const Duration(days: 1)));
    final data = await _post(
      '/bookings/request',
      body: {
        'roomId': roomId,
        'checkInDate': checkIn.toIso8601String(),
        'checkOutDate': checkOut.toIso8601String(),
        'guestCount': guestCount < 1 ? 1 : guestCount,
        'paidAmount': paidAmount < 0 ? 0 : paidAmount,
        'customerAddress': customerAddress?.trim(),
        'paymentMethod': paymentMethod,
        'note': note,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid booking response.');
    }
    return _mapBooking(data);
  }

  Future<Map<String, dynamic>> cancelBooking({
    required int id,
    String? reason,
  }) async {
    final trimmedReason = reason?.trim();
    final data = await _post(
      '/bookings/$id/cancel',
      body: {
        if (trimmedReason != null && trimmedReason.isNotEmpty)
          'reason': trimmedReason,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid booking cancellation response.');
    }
    return _mapBooking(data);
  }

  Future<Map<String, dynamic>> changeBooking({
    required int id,
    int? roomId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestCount,
    String? note,
  }) async {
    final trimmedNote = note?.trim();
    final data = await _put(
      '/bookings/$id/change',
      body: {
        if (roomId != null) 'roomId': roomId,
        if (checkInDate != null)
          'checkInDate': _dateOnlyUtc(checkInDate).toIso8601String(),
        if (checkOutDate != null)
          'checkOutDate': _dateOnlyUtc(checkOutDate).toIso8601String(),
        if (guestCount != null) 'guestCount': guestCount < 1 ? 1 : guestCount,
        if (trimmedNote != null && trimmedNote.isNotEmpty) 'note': trimmedNote,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid booking change response.');
    }
    return _mapBooking(data);
  }

  Future<Map<String, dynamic>> initiatePayment({
    required int bookingId,
    int? amount,
    String provider = 'VNPAY',
    String method = 'VNPAY',
  }) async {
    final data = await _post(
      '/payments/initiate',
      body: {
        'bookingId': bookingId,
        'amount': amount,
        'provider': provider,
        'method': method,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid payment response.');
    }
    return _mapPayment(data);
  }

  Future<Map<String, dynamic>> completePayment({
    required String transactionCode,
    String? gatewayTransactionId,
    String status = 'COMPLETED',
  }) async {
    final data = await _post(
      '/payments/webhook',
      body: {
        'transactionCode': transactionCode,
        'gatewayTransactionId': gatewayTransactionId,
        'status': status,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid payment completion response.');
    }
    return _mapPayment(data);
  }

  Future<List<Map<String, dynamic>>> fetchPaymentsForBooking(
    int bookingId,
  ) async {
    final data = await _get('/payments/by-booking/$bookingId');
    return _listFromData(data).map(_mapPayment).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPaymentCards() async {
    final data = await _get('/payment-cards');
    return _listFromData(data).map(_mapPaymentCard).toList();
  }

  Future<Map<String, dynamic>> addPaymentCard({
    required String cardNumber,
    required String cardHolderName,
    required String expiry,
    String? brand,
    bool defaultCard = false,
  }) async {
    final data = await _post(
      '/payment-cards',
      body: {
        'cardNumber': cardNumber.trim(),
        'cardHolderName': cardHolderName.trim(),
        'expiry': expiry.trim(),
        'brand': brand?.trim(),
        'defaultCard': defaultCard,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid payment card response.');
    }
    return _mapPaymentCard(data);
  }

  Future<Map<String, dynamic>> setDefaultPaymentCard(int id) async {
    final data = await _post('/payment-cards/$id/default');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid payment card response.');
    }
    return _mapPaymentCard(data);
  }

  Future<void> deletePaymentCard(int id) async {
    await _delete('/payment-cards/$id');
  }

  Future<List<Map<String, dynamic>>> fetchFavoriteHotels() async {
    final data = await _get('/favorites/my-favorites');
    final favorites = _listFromData(data);
    final mapped = <Map<String, dynamic>>[];

    for (final favorite in favorites) {
      final hotelId = _intValue(favorite['hotelId']);
      if (hotelId == null) {
        mapped.add(_mapFavoriteHotel(favorite));
        continue;
      }

      try {
        final hotel = await fetchHotel(hotelId);
        mapped.add({
          ...hotel,
          'favoriteId': favorite['id'],
          'favoriteCreatedAt': _dateTimeValue(favorite['createdAt']),
          'imageUrl': favorite['imageUrl'] ?? hotel['imageUrl'],
        });
      } on ApiException {
        mapped.add(_mapFavoriteHotel(favorite));
      }
    }

    return mapped;
  }

  Future<bool> toggleFavorite(int hotelId) async {
    final data = await _post('/favorites/$hotelId/toggle');
    return data == true;
  }

  Future<bool> isFavoriteHotel(int hotelId) async {
    final data = await _get('/favorites/$hotelId/is-favorite');
    return data == true;
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final data = await _get('/users/me');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid user response.');
    }
    final user = _mapUser(data);
    _cachedUser = user;
    _notifyProfileChanged();
    return user;
  }

  Future<Map<String, dynamic>> updateCurrentUser({
    required String firstName,
    required String lastName,
    required String phone,
    String? avatarUrl,
  }) async {
    final data = await _put(
      '/users/me',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'avatarUrl': avatarUrl?.trim(),
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid user response.');
    }
    final user = _mapUser(data);
    _cachedUser = user;
    _refreshSessionUser(user);
    _notifyProfileChanged();
    return user;
  }

  Future<Map<String, dynamic>> uploadCurrentUserAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    await _ensureActiveSession('/users/me/avatar');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.apiBaseUrl}/users/me/avatar'),
    );
    request.headers.addAll(_uploadHeaders);
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse =
        await request.send().timeout(AppConstants.apiTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    final data = _handleResponse(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid avatar upload response.');
    }

    final user = _mapUser(data);
    _cachedUser = user;
    _refreshSessionUser(user);
    _notifyProfileChanged();
    return user;
  }

  Future<bool> healthCheck() async {
    final uri = Uri.parse('${AppConstants.backendBaseUrl}/actuator/health');
    try {
      final response = await _client.get(uri).timeout(AppConstants.apiTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _session = null;
    _cachedUser = null;
    clearStoredSession();
    _notifyProfileChanged();
  }

  Future<dynamic> _post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _ensureActiveSession(endpoint);
    final response = await _client
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Future<dynamic> _postRaw(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _ensureActiveSession(endpoint);
    final response = await _client
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    final decoded = _decodeResponse(response);
    final isSuccessStatus =
        response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccessStatus) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final message = _stringValue(decoded['message']) ??
          _stringValue(decoded['error']) ??
          _stringValue(decoded['detail']);
      if (message != null) {
        throw ApiException(message);
      }
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      throw ApiException(decoded.trim());
    }

    throw ApiException(_defaultErrorMessage(response.statusCode));
  }

  Future<dynamic> _get(
    String endpoint, {
    Map<String, Object?>? queryParameters,
  }) async {
    await _ensureActiveSession(endpoint);
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint').replace(
      queryParameters: _queryParameters(queryParameters),
    );
    final response = await _client
        .get(
          uri,
          headers: _headers,
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Future<dynamic> _put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    await _ensureActiveSession(endpoint);
    final response = await _client
        .put(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Future<dynamic> _delete(String endpoint) async {
    await _ensureActiveSession(endpoint);
    final response = await _client
        .delete(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Map<String, String>? _queryParameters(Map<String, Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return null;
    return parameters.map((key, value) => MapEntry(key, value.toString()));
  }

  List<Map<String, dynamic>> _listFromData(dynamic data) {
    if (data is List) {
      return data.map(_mapFrom).where((item) => item.isNotEmpty).toList();
    }
    if (data is Map) {
      final items = data['data'] ?? data['content'] ?? data['items'];
      if (items is List) {
        return items.map(_mapFrom).where((item) => item.isNotEmpty).toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const {};
  }

  Map<String, dynamic> _mapHotel(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final street = _stringValue(raw['street']);
    final ward = _stringValue(raw['wardName']);
    final province = _stringValue(raw['provinceName']);
    final location = [street, ward, province]
        .where((item) => item != null && item.isNotEmpty)
        .join(', ');
    final palette = _hotelPalette(id);

    final description =
        _stringValue(raw['description']) ?? 'Dang cap nhat mo ta khach san.';

    return {
      'id': id,
      'ownerId': _intValue(raw['ownerId']),
      'wardId': _intValue(raw['wardId']),
      'name': _stringValue(raw['name']) ?? 'Hotel #$id',
      'location': location.isEmpty ? 'Dang cap nhat dia chi' : location,
      'street': street,
      'phone': _stringValue(raw['phone']),
      'description': description,
      'subtitle': description,
      'status': _stringValue(raw['status']),
      'rating': 4.7,
      'reviews': '0 danh gia',
      'price': 'Xem gia phong',
      'date': 'Ngay gan nhat',
      'rooms': '2 nguoi lon, 1 phong',
      'guests': '2 nguoi lon (1 phong)',
      'nights': '1 dem',
      'image': '\u{1F3E8}',
      'imageUrl': _resourceUrl(raw['imageUrl']),
      'icon': Icons.apartment_outlined,
      'color': palette.first,
      'palette': palette,
      'colors': [palette.first, palette.last],
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapHotelImage(Map<String, dynamic> raw) {
    return {
      'id': _intValue(raw['id']),
      'hotelId': _intValue(raw['hotelId']),
      'imageUrl': _resourceUrl(raw['imageUrl']) ?? '',
      'objectKey': _stringValue(raw['objectKey']),
      'isPrimary': raw['isPrimary'] == true || raw['primary'] == true,
      'sortOrder': _intValue(raw['sortOrder']) ?? 0,
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapRoom(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final capacity = _intValue(raw['capacity']) ?? 1;
    final price = (_numValue(raw['price']) ?? 0).round();
    final roomNumber = _stringValue(raw['roomNumber']) ?? '$id';

    return {
      'id': id,
      'hotelId': _intValue(raw['hotelId']),
      'roomTypeId': _intValue(raw['roomTypeId']),
      'roomNumber': roomNumber,
      'name': 'Phong $roomNumber',
      'type': '$capacity nguoi lon',
      'capacity': capacity,
      'guests': '$capacity nguoi lon',
      'image': '\u{1F3E8}',
      'amenities': const [
        {'name': 'Giuong doi', 'icon': '-'},
        {'name': 'Phong tam rieng', 'icon': '-'},
        {'name': 'WiFi mien phi', 'icon': '-'},
      ],
      'policies': const [
        'Co the huy theo chinh sach cua khach san',
        'Thanh toan va xac nhan theo yeu cau dat phong',
      ],
      'price': price,
      'oldPrice': price > 0 ? (price * 1.08).round() : null,
      'taxAndFee': 0,
      'extraFee': 0,
      'description': capacity >= 3
          ? 'Phu hop cho gia dinh hoac nhom nho'
          : 'Phu hop cho chuyen di ca nhan hoac cap doi',
      'cancellationPolicy': 'Theo chinh sach cua khach san',
      'paymentNote': 'Thanh toan va xac nhan theo yeu cau dat phong',
      'status': _stringValue(raw['status']),
      'selected': false,
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapBooking(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final status = (_stringValue(raw['status']) ?? '').toUpperCase();
    final checkIn = _dateTimeValue(raw['checkInDate']);
    final checkOut = _dateTimeValue(raw['checkOutDate']);
    final guestCount = _intValue(raw['guestCount']) ?? 1;
    final totalAmount = _numValue(raw['totalAmount']) ?? raw['totalAmount'];
    final totalAmountValue = _numValue(raw['totalAmount']) ?? 0;
    final paidAmountValue = _numValue(raw['paidAmount']) ?? 0;
    final remainingAmount =
        (totalAmountValue - paidAmountValue).clamp(0, totalAmountValue);
    final paymentStatusCode = totalAmountValue <= 0
        ? 'UNPAID'
        : paidAmountValue >= totalAmountValue
            ? 'COMPLETED'
            : paidAmountValue > 0
                ? 'PARTIAL'
                : 'UNPAID';
    final roomUnitPrice =
        _numValue(raw['roomUnitPrice']) ?? raw['roomUnitPrice'];
    final displayAmount = totalAmount is num ? totalAmount : roomUnitPrice;
    final palette = _bookingPalette(id);

    return {
      'id': id,
      'roomId': _intValue(raw['roomId']),
      'hotelId': _intValue(raw['hotelId']),
      'ownerId': _intValue(raw['ownerId']),
      'customerId': _intValue(raw['customerId']),
      'customerAddress': _stringValue(raw['customerAddress']) ?? '',
      'name': _stringValue(raw['hotelName']) ?? 'Booking #$id',
      'location': _stringValue(raw['roomNumber']) == null
          ? 'Dang cap nhat phong'
          : 'Phong ${_stringValue(raw['roomNumber'])}',
      'price': displayAmount is num
          ? '${_formatCurrency(displayAmount)} VND'
          : 'Dang cap nhat gia',
      'date': _dateRange(checkIn, checkOut),
      'detailDate': _dateRange(checkIn, checkOut),
      'guests': '$guestCount nguoi (1 phong)',
      'detailGuests': '$guestCount nguoi (1 phong)',
      'rating': '4.7',
      'status': _statusLabel(status),
      'statusCode': status,
      'totalAmount': totalAmountValue,
      'paidAmount': paidAmountValue,
      'remainingAmount': remainingAmount,
      'paymentStatus': _paymentStatusLabel(paymentStatusCode),
      'paymentStatusCode': paymentStatusCode,
      'reviewed': raw['reviewed'] == true,
      'statusColor': _statusColor(status),
      'statusAlignment': _isHistoryStatus(status) ? 'end' : 'start',
      'palette': palette,
      'variant': id % 4,
      'isHistory': _isHistoryStatus(status),
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapPayment(Map<String, dynamic> raw) {
    final statusCode = (_stringValue(raw['status']) ?? 'PENDING').toUpperCase();
    return {
      'id': _intValue(raw['id'] ?? raw['paymentId']),
      'bookingId': _intValue(raw['bookingId']),
      'amount': _numValue(raw['amount']),
      'method': _stringValue(raw['method']),
      'provider': _stringValue(raw['provider']),
      'status': _paymentStatusLabel(statusCode),
      'statusCode': statusCode,
      'transactionCode': _stringValue(raw['transactionCode']),
      'gatewayTransactionId': _stringValue(raw['gatewayTransactionId']),
      'checkoutUrl': _stringValue(raw['checkoutUrl']),
      'failureReason': _stringValue(raw['failureReason']),
      'refundedAmount': _numValue(raw['refundedAmount']) ?? 0,
      'paidAt': _stringValue(raw['paidAt']),
      'refundedAt': _stringValue(raw['refundedAt']),
      'createdAt': _stringValue(raw['createdAt']),
      'updatedAt': _stringValue(raw['updatedAt']),
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapFavoriteHotel(Map<String, dynamic> raw) {
    final hotelId = _intValue(raw['hotelId']) ?? 0;
    final palette = _hotelPalette(hotelId);
    return {
      'id': hotelId,
      'favoriteId': _intValue(raw['id']),
      'hotelId': hotelId,
      'name': _stringValue(raw['hotelName']) ?? 'Hotel #$hotelId',
      'location': 'Dang cap nhat dia chi',
      'price': 'Xem gia phong',
      'rating': '4.7',
      'date': 'Ngay gan nhat',
      'guests': '2 nguoi lon (1 phong)',
      'imageUrl': _stringValue(raw['imageUrl']),
      'favoriteCreatedAt': _dateTimeValue(raw['createdAt']),
      'colors': [palette.first, palette.last],
      'palette': palette,
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapNotification(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final createdAt = _dateTimeValue(raw['createdAt']);
    final type = (_stringValue(raw['type']) ?? 'GENERAL').toUpperCase();
    return {
      'id': id,
      'userId': _intValue(raw['userId']),
      'senderId': _intValue(raw['senderId']),
      'title': _stringValue(raw['title']) ?? 'Thong bao moi',
      'message': _stringValue(raw['message']) ?? '',
      'type': type,
      'relatedTable': _stringValue(raw['relatedTable']),
      'relatedId': _intValue(raw['relatedId']),
      'read': raw['read'] == true,
      'createdAt': createdAt,
      'readAt': _dateTimeValue(raw['readAt']),
      'time': _formatChatTime(createdAt),
      'icon': _notificationIcon(type),
      'colors': _notificationPalette(id),
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapCoupon(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final code = _stringValue(raw['code']) ?? 'COUPON$id';
    final discountType =
        (_stringValue(raw['discountType']) ?? '').toUpperCase();
    final discountValue = _numValue(raw['discountValue']) ?? 0;
    final discountText = discountType == 'PERCENT'
        ? 'Giam ${discountValue.round()}%'
        : 'Giam ${_formatCurrency(discountValue)} VND';
    final description = _stringValue(raw['description']) ??
        'Ap dung ma uu dai $code cho lan dat phong tiep theo.';
    final palette = _couponPalette(id);

    return {
      'id': id,
      'code': code,
      'title': '$discountText voi ma $code',
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxDiscountAmount': _numValue(raw['maxDiscountAmount']),
      'minOrderAmount': _numValue(raw['minOrderAmount']),
      'startAt': _dateTimeValue(raw['startAt']),
      'endAt': _dateTimeValue(raw['endAt']),
      'maxUses': _intValue(raw['maxUses']),
      'usedCount': _intValue(raw['usedCount']) ?? 0,
      'active': raw['active'] == true,
      'colors': palette,
      'icon': _couponIcon(id),
      'backend': raw,
    };
  }

  List<Map<String, dynamic>> _activeCouponsFromData(dynamic data) {
    return _listFromData(data)
        .map(_mapCoupon)
        .where(_isCouponCurrentlyUsable)
        .toList();
  }

  bool _isCouponCurrentlyUsable(Map<String, dynamic> coupon) {
    if (coupon['active'] != true) return false;
    final now = DateTime.now();
    final startAt = coupon['startAt'];
    if (startAt is DateTime && now.isBefore(startAt.toLocal())) {
      return false;
    }
    final endAt = coupon['endAt'];
    if (endAt is DateTime && now.isAfter(endAt.toLocal())) {
      return false;
    }
    final maxUses = _intValue(coupon['maxUses']);
    final usedCount = _intValue(coupon['usedCount']) ?? 0;
    return maxUses == null || usedCount < maxUses;
  }

  Map<String, dynamic> _mapPaymentCard(Map<String, dynamic> raw) {
    final id = _intValue(raw['id']) ?? 0;
    final last4 = _stringValue(raw['last4']) ?? '0000';
    final brand = (_stringValue(raw['brand']) ?? 'CARD').toUpperCase();
    final expiryMonth = _intValue(raw['expiryMonth']);
    final expiryYear = _intValue(raw['expiryYear']);
    final expiry = expiryMonth == null || expiryYear == null
        ? '--/--'
        : '${expiryMonth.toString().padLeft(2, '0')}/${(expiryYear % 100).toString().padLeft(2, '0')}';
    final palette = _cardPalette(id);

    return {
      'id': id,
      'customerId': _intValue(raw['customerId']),
      'holder': _stringValue(raw['cardHolderName']) ?? 'CARDHOLDER',
      'cardHolderName': _stringValue(raw['cardHolderName']) ?? 'CARDHOLDER',
      'brand': brand,
      'bank': brand,
      'last4': last4,
      'number': '**** $last4',
      'displayNumber': '**** **** **** $last4',
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'expiry': expiry,
      'defaultCard': raw['defaultCard'] == true,
      'primary': raw['defaultCard'] == true,
      'createdAt': _dateTimeValue(raw['createdAt']),
      'updatedAt': _dateTimeValue(raw['updatedAt']),
      'colors': palette,
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapUser(Map<String, dynamic> raw) {
    final firstName = _stringValue(raw['firstName']) ?? '';
    final lastName = _stringValue(raw['lastName']) ?? '';
    final fullName = [lastName, firstName]
        .where((item) => item.trim().isNotEmpty)
        .join(' ')
        .trim();

    return {
      'id': _intValue(raw['id']),
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName.isEmpty ? 'Customer' : fullName,
      'email': _stringValue(raw['email']) ?? '',
      'phone': _stringValue(raw['phone']) ?? '',
      'avatarUrl': _resourceUrl(raw['avatarUrl']) ?? '',
      'emailVerified': raw['emailVerified'] == true,
      'status': _stringValue(raw['status']) ?? '',
      'createdAt': _stringValue(raw['createdAt']) ?? '',
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapChatConversation(Map<String, dynamic> raw) {
    final userId = _intValue(raw['userId']) ?? 0;
    final lastMessageAt = _dateTimeValue(raw['lastMessageAt']);
    return {
      'id': userId,
      'userId': userId,
      'name': _stringValue(raw['displayName']) ??
          _stringValue(raw['email']) ??
          'User #$userId',
      'email': _stringValue(raw['email']) ?? '',
      'message': _stringValue(raw['lastMessage']) ?? 'Bat dau tro chuyen',
      'time': _formatChatTime(lastMessageAt),
      'lastMessageAt': lastMessageAt,
      'unread': _intValue(raw['unreadCount']) ?? 0,
      'online': false,
      'tag': 'Chat',
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapChatMessage(Map<String, dynamic> raw) {
    final createdAt = _dateTimeValue(raw['createdAt']);
    return {
      'id': _intValue(raw['id']) ?? 0,
      'senderId': _intValue(raw['senderId']),
      'receiverId': _intValue(raw['receiverId']),
      'bookingId': _intValue(raw['bookingId']),
      'content': _stringValue(raw['content']) ?? '',
      'read': raw['read'] == true,
      'createdAt': createdAt,
      'readAt': _dateTimeValue(raw['readAt']),
      'time': _formatChatTime(createdAt),
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapAiChatResponse(dynamic raw) {
    final threadId = _aiThreadId(raw);
    final content = _aiText(raw) ?? 'AI chua tra ve noi dung phu hop.';

    return {
      'threadId': threadId,
      'content': content,
      'backend': raw,
    };
  }

  void _refreshSessionUser(Map<String, dynamic> user) {
    final session = _session;
    if (session == null) return;

    _session = AuthSession(
      userId: session.userId ?? _intValue(user['id']),
      fullName: _stringValue(user['fullName']),
      email: session.email,
      roles: session.roles,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
    );
    _persistSession();
  }

  void _notifyProfileChanged() {
    _profileVersion.value++;
  }

  List<Color> _hotelPalette(int seed) {
    const palettes = <List<Color>>[
      [Color(0xFF6A8D73), Color(0xFFE7F1E8)],
      [Color(0xFF0891B2), Color(0xFFDDF4F8)],
      [Color(0xFFB56576), Color(0xFFF6E4E8)],
      [Color(0xFFD97706), Color(0xFFFFF1D6)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  List<Color> _bookingPalette(int seed) {
    const palettes = <List<Color>>[
      [Color(0xFFD8A969), Color(0xFFF8E6C8), Color(0xFF7B4A2A)],
      [Color(0xFF7E9277), Color(0xFFF3EFE2), Color(0xFF313A36)],
      [Color(0xFFB5653C), Color(0xFFF0C28A), Color(0xFF6A3F2D)],
      [Color(0xFF9D947F), Color(0xFFF2EEE4), Color(0xFF6D675D)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  List<Color> _couponPalette(int seed) {
    const palettes = <List<Color>>[
      [Color(0xFFE9C088), Color(0xFFB95D34)],
      [Color(0xFFFFB3C7), Color(0xFFE74C6A)],
      [Color(0xFF1FAA59), Color(0xFF74C67A)],
      [Color(0xFF0B5574), Color(0xFF8AC6D8)],
      [Color(0xFF80C565), Color(0xFF2D8CCB)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  IconData _couponIcon(int seed) {
    const icons = <IconData>[
      Icons.apartment,
      Icons.local_offer,
      Icons.location_on,
      Icons.hotel,
      Icons.beach_access,
    ];
    return icons[seed.abs() % icons.length];
  }

  List<Color> _notificationPalette(int seed) {
    const palettes = <List<Color>>[
      [Color(0xFF2864A7), Color(0xFF68A5E8)],
      [Color(0xFFD97706), Color(0xFFFBBF24)],
      [Color(0xFF16A34A), Color(0xFF86EFAC)],
      [Color(0xFF7C3AED), Color(0xFFC4B5FD)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  IconData _notificationIcon(String type) {
    switch (type) {
      case 'BOOKING':
        return Icons.book_online_outlined;
      case 'PAYMENT':
        return Icons.payments_outlined;
      case 'REVIEW':
        return Icons.rate_review_outlined;
      case 'SYSTEM':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  List<Color> _cardPalette(int seed) {
    const palettes = <List<Color>>[
      [Color(0xFF201A59), Color(0xFF4B3DA3)],
      [Color(0xFF050505), Color(0xFF2A2A2A)],
      [Color(0xFF0B5574), Color(0xFF38BDF8)],
      [Color(0xFF6D28D9), Color(0xFFA78BFA)],
    ];
    return palettes[seed.abs() % palettes.length];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF2864A7);
      case 'CHECKED_IN':
        return const Color(0xFF7C3AED);
      case 'COMPLETED':
      case 'CHECKED_OUT':
        return const Color(0xFF22C55E);
      case 'CANCELLED':
      case 'REJECTED':
      case 'NO_SHOW':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Dang cho xac nhan';
      case 'CONFIRMED':
        return 'Da xac nhan';
      case 'CHECKED_IN':
        return 'Da check-in';
      case 'CHECKED_OUT':
        return 'Da check-out';
      case 'COMPLETED':
        return 'Hoan thanh';
      case 'CANCELLED':
        return 'Da huy';
      case 'REJECTED':
        return 'Da tu choi';
      case 'NO_SHOW':
        return 'Khong den';
      default:
        return 'Dang cho xac nhan';
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Da thanh toan';
      case 'FAILED':
        return 'Thanh toan that bai';
      case 'REFUNDED':
        return 'Da hoan tien';
      case 'PARTIALLY_REFUNDED':
        return 'Hoan tien mot phan';
      case 'PARTIAL':
        return 'Thanh toan mot phan';
      case 'UNPAID':
        return 'Chua thanh toan';
      case 'PENDING':
      default:
        return 'Dang cho thanh toan';
    }
  }

  bool _isHistoryStatus(String status) {
    return status == 'COMPLETED' ||
        status == 'CHECKED_OUT' ||
        status == 'CANCELLED' ||
        status == 'REJECTED' ||
        status == 'NO_SHOW';
  }

  String _dateRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) return 'Dang cap nhat ngay';
    return '${_formatDate(checkIn)} - ${_formatDate(checkOut)}';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _formatChatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final now = DateTime.now();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '$hour:$minute';
    }
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _formatCurrency(num amount) {
    return amount.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  num? _numValue(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return num.tryParse(trimmed.replaceAll(',', '')) ??
          num.tryParse(trimmed.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    return null;
  }

  String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _aiText(dynamic value) {
    if (value is String) return _stringValue(value);

    if (value is List) {
      for (final item in value.reversed) {
        final text = _aiText(item);
        if (text != null) return text;
      }
      return null;
    }

    if (value is! Map) return null;

    final directKeys = [
      'reply',
      'answer',
      'response',
      'outputText',
      'output_text',
      'content',
      'text',
    ];
    for (final key in directKeys) {
      final raw = value[key];
      final text = raw is Map || raw is List ? _aiText(raw) : _stringValue(raw);
      if (text != null) return text;
    }

    final message = value['message'];
    if (message is String) {
      final text = _stringValue(message);
      if (text != null) return text;
    }
    if (message is Map || message is List) {
      final text = _aiText(message);
      if (text != null) return text;
    }

    final choices = value['choices'];
    if (choices is List) {
      for (final choice in choices) {
        final text = _aiText(choice);
        if (text != null) return text;
      }
    }

    final messages = value['messages'];
    if (messages is List) {
      for (final item in messages.reversed) {
        if (item is Map) {
          final role = _stringValue(item['role'])?.toLowerCase();
          if (role == null || role == 'assistant' || role == 'ai') {
            final text = _aiText(item);
            if (text != null) return text;
          }
        } else {
          final text = _aiText(item);
          if (text != null) return text;
        }
      }
    }

    final data = value['data'];
    if (data != null) {
      final text = _aiText(data);
      if (text != null) return text;
    }

    final output = value['output'];
    if (output != null) {
      final text = _aiText(output);
      if (text != null) return text;
    }

    return null;
  }

  String? _aiThreadId(dynamic value) {
    if (value is! Map) return null;
    for (final key in [
      'threadId',
      'thread_id',
      'conversationId',
      'conversation_id',
      'sessionId',
      'session_id',
    ]) {
      final text = _stringValue(value[key]);
      if (text != null) return text;
    }
    final data = value['data'];
    if (data is Map) return _aiThreadId(data);
    return null;
  }

  String? _resourceUrl(dynamic value) {
    final text = _stringValue(value);
    if (text == null) return null;
    if (text.startsWith('http://') || text.startsWith('https://')) {
      return text;
    }
    if (text.startsWith('/')) {
      return '${AppConstants.backendBaseUrl}$text';
    }
    return text;
  }

  DateTime? _dateTimeValue(dynamic value) {
    final text = _stringValue(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  DateTime _dateOnlyUtc(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
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

  Map<String, String> get _uploadHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
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

    if (isSuccessStatus) {
      return decoded;
    }

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
      throw const ApiException('Invalid authentication response.');
    }

    final session = AuthSession.fromJson(data);
    if (session.accessToken.isEmpty) {
      throw const ApiException('Authentication token was not returned.');
    }

    _session = session;
    _persistSession();
    return session;
  }

  bool _shouldRefreshSession(AuthSession session) {
    final expiresAt = session.accessTokenExpiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(
          expiresAt.toUtc().subtract(const Duration(minutes: 2)),
        );
  }

  void _persistSession() {
    final session = _session;
    if (session == null) {
      clearStoredSession();
      return;
    }
    writeStoredSession(jsonEncode(session.toJson()));
  }

  Future<void> _ensureActiveSession(String endpoint) async {
    if (_isAuthEndpoint(endpoint)) return;

    final session = _session;
    if (session == null || !_shouldRefreshSession(session)) {
      return;
    }

    try {
      await refreshSession();
    } on ApiException {
      logout();
      rethrow;
    } catch (_) {
      // Keep the current token when refresh cannot be reached; the request may
      // still succeed if the token is not actually expired yet.
    }
  }

  bool _isAuthEndpoint(String endpoint) {
    if (endpoint == '/auth/change-password') return false;
    return endpoint.startsWith('/auth/');
  }

  _NameParts _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return const _NameParts(firstName: '', lastName: '');
    }
    if (parts.length == 1) {
      return _NameParts(firstName: parts.first, lastName: '');
    }

    return _NameParts(
      firstName: parts.last,
      lastName: parts.take(parts.length - 1).join(' '),
    );
  }

  String _defaultErrorMessage(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return AppConstants.invalidCredentials;
    }
    if (statusCode >= 500) {
      return AppConstants.serverError;
    }
    return AppConstants.networkError;
  }
}

class _NameParts {
  const _NameParts({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}
