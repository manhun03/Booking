import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

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

  AuthSession? get currentSession => _session;
  Map<String, dynamic>? get cachedUser => _cachedUser;
  ValueNotifier<int> get profileVersion => _profileVersion;

  bool get isAuthenticated =>
      _session != null && _session!.accessToken.trim().isNotEmpty;

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
    required String email,
    required String password,
  }) async {
    final nameParts = _splitFullName(fullName);
    final data = await _post(
      AppConstants.signupEndpoint,
      body: {
        'lastName': nameParts.lastName,
        'firstName': nameParts.firstName,
        'email': email,
        'password': password,
        'role': 'Customer',
      },
    );

    return _setSession(data);
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

  Future<List<Map<String, dynamic>>> fetchRoomsByHotel(int hotelId) async {
    final data = await _get(
      '/rooms/by-hotel',
      queryParameters: {'hotelId': hotelId},
    );

    return _listFromData(data).map(_mapRoom).toList();
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
    String? note,
    String? paymentMethod,
  }) async {
    final checkIn = checkInDate ?? DateTime.now().add(const Duration(days: 1));
    final checkOut = checkOutDate ?? checkIn.add(const Duration(days: 1));
    final data = await _post(
      '/bookings/request',
      body: {
        'roomId': roomId,
        'checkInDate': checkIn.toUtc().toIso8601String(),
        'checkOutDate': checkOut.toUtc().toIso8601String(),
        'guestCount': guestCount < 1 ? 1 : guestCount,
        'paidAmount': paidAmount < 0 ? 0 : paidAmount,
        'paymentMethod': paymentMethod,
        'note': note,
      },
    );

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Invalid booking response.');
    }
    return _mapBooking(data);
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
          'imageUrl': favorite['imageUrl'],
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
    _notifyProfileChanged();
  }

  Future<dynamic> _post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  Future<dynamic> _get(
    String endpoint, {
    Map<String, Object?>? queryParameters,
  }) async {
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
    final response = await _client
        .put(
          Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
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
      'icon': Icons.apartment_outlined,
      'color': palette.first,
      'palette': palette,
      'colors': [palette.first, palette.last],
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
    final roomUnitPrice =
        _numValue(raw['roomUnitPrice']) ?? raw['roomUnitPrice'];
    final displayAmount = totalAmount is num ? totalAmount : roomUnitPrice;
    final palette = _bookingPalette(id);

    return {
      'id': id,
      'roomId': _intValue(raw['roomId']),
      'customerId': _intValue(raw['customerId']),
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
      'statusColor': _statusColor(status),
      'statusAlignment': _isHistoryStatus(status) ? 'end' : 'start',
      'palette': palette,
      'variant': id % 4,
      'isHistory': _isHistoryStatus(status),
      'backend': raw,
    };
  }

  Map<String, dynamic> _mapFavoriteHotel(Map<String, dynamic> raw) {
    final hotelId = _intValue(raw['hotelId']) ?? 0;
    final palette = _hotelPalette(hotelId);
    return {
      'id': hotelId,
      'favoriteId': _intValue(raw['id']),
      'name': _stringValue(raw['hotelName']) ?? 'Hotel #$hotelId',
      'location': 'Dang cap nhat dia chi',
      'price': 'Xem gia phong',
      'rating': '4.7',
      'date': 'Ngay gan nhat',
      'guests': '2 nguoi lon (1 phong)',
      'imageUrl': _stringValue(raw['imageUrl']),
      'colors': [palette.first, palette.last],
      'palette': palette,
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
      'status': _stringValue(raw['status']) ?? '',
      'createdAt': _stringValue(raw['createdAt']) ?? '',
      'backend': raw,
    };
  }

  void _refreshSessionUser(Map<String, dynamic> user) {
    final session = _session;
    if (session == null) return;

    _session = AuthSession(
      userId: session.userId,
      fullName: _stringValue(user['fullName']),
      email: session.email,
      roles: session.roles,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
    );
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

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF2864A7);
      case 'COMPLETED':
        return const Color(0xFF22C55E);
      case 'CANCELLED':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Da xac nhan';
      case 'COMPLETED':
        return 'Hoan thanh';
      case 'CANCELLED':
        return 'Da huy';
      default:
        return 'Dang cho xac nhan';
    }
  }

  bool _isHistoryStatus(String status) {
    return status == 'COMPLETED' || status == 'CANCELLED';
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
    return session;
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
