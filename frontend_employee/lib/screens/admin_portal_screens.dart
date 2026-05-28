import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';
import '../services/auth_service.dart';
import '../utils/display_format.dart';

typedef JsonMap = Map<String, dynamic>;

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _users = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _api.fetchUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc danh sach nguoi dung.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUser(JsonMap user) async {
    final id = intValue(user['id']);
    if (id <= 0) return;
    final locked = _isInactive(user['status']);
    try {
      if (locked) {
        await _api.unlockUser(id);
      } else {
        await _api.lockUser(id);
      }
      if (!mounted) return;
      _showSnack(
        context,
        locked ? 'Da mo khoa tai khoan.' : 'Da khoa tai khoan.',
      );
      await _loadUsers();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  Future<void> _showUserForm({JsonMap? user}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
    );
    if (result == true) await _loadUsers();
  }

  List<JsonMap> get _filteredUsers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _users;
    return _users.where((user) {
      return [
        user['id'],
        user['firstName'],
        user['lastName'],
        user['email'],
        user['phone'],
        user['status'],
      ].any(
        (value) => value?.toString().toLowerCase().contains(query) ?? false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Quan ly nguoi dung',
      onRefresh: _loadUsers,
      actions: [
        IconButton(
          tooltip: 'Tao nguoi dung',
          onPressed: () => _showUserForm(),
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadUsers)
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _searchController,
                    hintText: 'Tim theo ten, email, sdt, trang thai...',
                    resultText: '${_filteredUsers.length} nguoi dung',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: FilledButton.icon(
                      onPressed: () => _showUserForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tao tai khoan'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredUsers.isEmpty)
                    const _EmptyState(message: 'Khong co nguoi dung phu hop.')
                  else
                    ..._filteredUsers.map(_userCard),
                ],
              ),
            ),
    );
  }

  Widget _userCard(JsonMap user) {
    final fullName = _fullName(user);
    final status = textValue(user['status'], 'ACTIVE');
    final inactive = _isInactive(status);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: _primary.withValues(alpha: 0.12),
                  child: Text(
                    fullName.isEmpty ? '?' : fullName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty
                            ? 'Nguoi dung #${user['id']}'
                            : fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        textValue(user['email']),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: status, color: _statusColor(status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _InlineInfo(Icons.phone_outlined, textValue(user['phone'])),
                _InlineInfo(
                  Icons.verified_user_outlined,
                  user['emailVerified'] == true
                      ? 'Email da xac minh'
                      : 'Email chua xac minh',
                ),
                _InlineInfo(
                  Icons.calendar_today_outlined,
                  'Tao: ${formatDate(user['createdAt'], withTime: true)}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showJsonDetail(
                    context,
                    title: 'Chi tiet nguoi dung',
                    data: user,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showUserForm(user: user),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Cap nhat'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: inactive ? Colors.green : Colors.redAccent,
                  ),
                  onPressed: () => _toggleUser(user),
                  icon: Icon(inactive ? Icons.lock_open : Icons.lock_outline),
                  label: Text(inactive ? 'Mo khoa' : 'Khoa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminRolePermissionScreen extends StatefulWidget {
  const AdminRolePermissionScreen({super.key});

  @override
  State<AdminRolePermissionScreen> createState() =>
      _AdminRolePermissionScreenState();
}

class _AdminRolePermissionScreenState extends State<AdminRolePermissionScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _roles = const [];
  List<JsonMap> _permissions = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _api.fetchRoles(),
        _api.fetchPermissions(),
      ]);
      if (!mounted) return;
      setState(() {
        _roles = results[0];
        _permissions = results[1];
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc vai tro va quyen.';
        _isLoading = false;
      });
    }
  }

  List<JsonMap> get _filteredRoles {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _roles;
    return _roles.where((role) => _matches(role, query)).toList();
  }

  List<JsonMap> get _filteredPermissions {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _permissions;
    return _permissions
        .where((permission) => _matches(permission, query))
        .toList();
  }

  Map<String, List<JsonMap>> get _permissionsByModule {
    final grouped = <String, List<JsonMap>>{};
    for (final permission in _filteredPermissions) {
      final module = textValue(permission['module'], 'general');
      grouped.putIfAbsent(module, () => []).add(permission);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Vai tro va phan quyen',
      onRefresh: _loadData,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadData)
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _searchController,
                    hintText: 'Tim role, permission, module...',
                    resultText:
                        '${_filteredRoles.length} role, ${_filteredPermissions.length} quyen',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  _InfoPanel(
                    icon: Icons.security_outlined,
                    title: 'RBAC dang duoc bao ve bang JWT',
                    message:
                        'Frontend doc role/permission tu backend. API quan trong da duoc bao ve bang @PreAuthorize va permission key.',
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Danh sach vai tro',
                    child: _filteredRoles.isEmpty
                        ? const _EmptyState(message: 'Khong co vai tro.')
                        : Column(
                            children: _filteredRoles.map(_roleTile).toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Quyen theo module',
                    child: _permissionsByModule.isEmpty
                        ? const _EmptyState(message: 'Khong co quyen.')
                        : Column(
                            children: _permissionsByModule.entries.map((entry) {
                              return ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text('${entry.value.length} quyen'),
                                children: entry.value
                                    .map(
                                      (permission) =>
                                          _permissionTile(permission),
                                    )
                                    .toList(),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _roleTile(JsonMap role) {
    final active = role['active'] == true;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _primary.withValues(alpha: 0.12),
        child: const Icon(Icons.admin_panel_settings_outlined),
      ),
      title: Text(
        textValue(role['name'], 'Role #${role['id']}'),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(textValue(role['description'], 'Khong co mo ta')),
      trailing: _StatusBadge(
        label: active ? 'ACTIVE' : 'INACTIVE',
        color: active ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _permissionTile(JsonMap permission) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 12, right: 0),
      leading: const Icon(Icons.key_outlined, size: 18),
      title: Text(textValue(permission['permissionKey'])),
      subtitle: Text(textValue(permission['description'], 'Khong co mo ta')),
    );
  }
}

class AdminHotelManagementScreen extends StatefulWidget {
  const AdminHotelManagementScreen({super.key});

  @override
  State<AdminHotelManagementScreen> createState() =>
      _AdminHotelManagementScreenState();
}

class _AdminHotelManagementScreenState
    extends State<AdminHotelManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _hotels = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await _api.fetchHotels();
      if (!mounted) return;
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc danh sach khach san.';
        _isLoading = false;
      });
    }
  }

  Future<void> _runHotelAction(
    JsonMap hotel,
    String successMessage,
    Future<JsonMap> Function(int id) action,
  ) async {
    final id = intValue(hotel['id']);
    if (id <= 0) return;
    try {
      await action(id);
      if (!mounted) return;
      _showSnack(context, successMessage);
      await _loadHotels();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  List<JsonMap> get _filteredHotels {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _hotels;
    return _hotels.where((hotel) => _matches(hotel, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Quan ly khach san',
      onRefresh: _loadHotels,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadHotels)
          : RefreshIndicator(
              onRefresh: _loadHotels,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _searchController,
                    hintText: 'Tim khach san, dia chi, trang thai...',
                    resultText: '${_filteredHotels.length} khach san',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredHotels.isEmpty)
                    const _EmptyState(message: 'Khong co khach san phu hop.')
                  else
                    ..._filteredHotels.map(_hotelCard),
                ],
              ),
            ),
    );
  }

  Widget _hotelCard(JsonMap hotel) {
    final status = textValue(hotel['status']);
    final address = [hotel['street'], hotel['wardName'], hotel['provinceName']]
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .join(', ');
    final locked = status.toUpperCase() == 'SUSPENDED';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.withValues(alpha: 0.12),
                  child: const Icon(Icons.domain_outlined, color: Colors.teal),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 260),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textValue(hotel['name'], 'Khach san #${hotel['id']}'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        address.isEmpty ? 'Chua co dia chi' : address,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: status, color: _statusColor(status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _InlineInfo(
                  Icons.person_outline,
                  'Owner #${textValue(hotel['ownerId'])}',
                ),
                _InlineInfo(Icons.phone_outlined, textValue(hotel['phone'])),
                _InlineInfo(
                  Icons.visibility_off_outlined,
                  hotel['isDeleted'] == true
                      ? 'Da xoa mem'
                      : 'Dang hien thi trong DB',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showJsonDetail(
                    context,
                    title: 'Chi tiet khach san',
                    data: hotel,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: () => _runHotelAction(
                    hotel,
                    'Da duyet khach san.',
                    _api.approveHotel,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Duyet'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _runHotelAction(
                    hotel,
                    'Da tu choi khach san.',
                    _api.rejectHotel,
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Tu choi'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: locked ? Colors.green : Colors.redAccent,
                  ),
                  onPressed: () => _runHotelAction(
                    hotel,
                    locked ? 'Da mo khoa khach san.' : 'Da khoa khach san.',
                    locked ? _api.unlockHotel : _api.lockHotel,
                  ),
                  icon: Icon(locked ? Icons.lock_open : Icons.lock_outline),
                  label: Text(locked ? 'Mo khoa' : 'Khoa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends State<AdminBookingManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _bookings = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await _api.fetchBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc danh sach booking.';
        _isLoading = false;
      });
    }
  }

  Future<void> _forceComplete(JsonMap booking) async {
    final id = intValue(booking['id']);
    if (id <= 0) return;
    final confirmed = await _confirmAction(
      context,
      title: 'Force-complete booking #$id?',
      message:
          'Thao tac nay danh dau booking hoan tat thu cong. Chi dung khi can xu ly nghiep vu bat thuong.',
    );
    if (confirmed != true) return;

    try {
      await _api.forceCompleteBooking(id);
      if (!mounted) return;
      _showSnack(context, 'Da force-complete booking.');
      await _loadBookings();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  List<JsonMap> get _filteredBookings {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _bookings;
    return _bookings.where((booking) => _matches(booking, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Quan ly booking',
      onRefresh: _loadBookings,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadBookings)
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _searchController,
                    hintText:
                        'Tim booking, khach hang, khach san, trang thai...',
                    resultText: '${_filteredBookings.length} booking',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredBookings.isEmpty)
                    const _EmptyState(message: 'Khong co booking phu hop.')
                  else
                    ..._filteredBookings.map(_bookingCard),
                ],
              ),
            ),
    );
  }

  Widget _bookingCard(JsonMap booking) {
    final status = textValue(booking['status']);
    final canForceComplete = !const {
      'COMPLETED',
      'CANCELLED',
      'REJECTED',
    }.contains(status.toUpperCase());

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.14),
                  child: const Icon(
                    Icons.book_online_outlined,
                    color: Colors.orange,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${booking['id']} - ${textValue(booking['hotelName'])}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${textValue(booking['customerName'])} - ${textValue(booking['customerEmail'])}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: status, color: _statusColor(status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _InlineInfo(
                  Icons.meeting_room_outlined,
                  'Phong ${textValue(booking['roomNumber'])}',
                ),
                _InlineInfo(
                  Icons.event_available_outlined,
                  '${formatDate(booking['checkInDate'])} - ${formatDate(booking['checkOutDate'])}',
                ),
                _InlineInfo(
                  Icons.people_outline,
                  '${intValue(booking['guestCount'])} khach',
                ),
                _InlineInfo(
                  Icons.payments_outlined,
                  formatMoney(booking['totalAmount']),
                ),
                _InlineInfo(
                  Icons.account_balance_wallet_outlined,
                  'Da tra ${formatMoney(booking['paidAmount'])}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showJsonDetail(
                    context,
                    title: 'Chi tiet booking',
                    data: booking,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: canForceComplete
                      ? () => _forceComplete(booking)
                      : null,
                  icon: const Icon(Icons.done_all_outlined),
                  label: const Text('Force-complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPaymentManagementScreen extends StatefulWidget {
  const AdminPaymentManagementScreen({super.key});

  @override
  State<AdminPaymentManagementScreen> createState() =>
      _AdminPaymentManagementScreenState();
}

class _AdminPaymentManagementScreenState
    extends State<AdminPaymentManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _payments = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await _api.fetchPayments();
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc danh sach thanh toan.';
        _isLoading = false;
      });
    }
  }

  Future<void> _showRefundDialog(JsonMap payment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _RefundDialog(payment: payment),
    );
    if (result == true) await _loadPayments();
  }

  List<JsonMap> get _filteredPayments {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _payments;
    return _payments.where((payment) => _matches(payment, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Quan ly thanh toan',
      onRefresh: _loadPayments,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadPayments)
          : RefreshIndicator(
              onRefresh: _loadPayments,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchHeader(
                    controller: _searchController,
                    hintText:
                        'Tim payment, booking, ma giao dich, trang thai...',
                    resultText: '${_filteredPayments.length} giao dich',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredPayments.isEmpty)
                    const _EmptyState(message: 'Khong co giao dich phu hop.')
                  else
                    ..._filteredPayments.map(_paymentCard),
                ],
              ),
            ),
    );
  }

  Widget _paymentCard(JsonMap payment) {
    final status = textValue(payment['status']);
    final refundable = _canRefund(status);
    final amount = doubleValue(payment['amount']);
    final refunded = doubleValue(payment['refundedAmount']);
    final remaining = (amount - refunded).clamp(0, double.infinity);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Colors.indigo,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment #${payment['id']} - Booking #${textValue(payment['bookingId'])}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${textValue(payment['provider'], 'LOCAL')} / ${textValue(payment['method'], 'UNKNOWN')}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: status, color: _statusColor(status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _InlineInfo(Icons.attach_money, formatMoney(amount)),
                _InlineInfo(
                  Icons.undo_outlined,
                  'Da hoan ${formatMoney(refunded)}',
                ),
                _InlineInfo(
                  Icons.savings_outlined,
                  'Con lai ${formatMoney(remaining)}',
                ),
                _InlineInfo(
                  Icons.receipt_long_outlined,
                  textValue(payment['transactionCode']),
                ),
                _InlineInfo(
                  Icons.calendar_today_outlined,
                  formatDate(payment['createdAt'], withTime: true),
                ),
              ],
            ),
            if (textValue(payment['failureReason'], '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Ly do loi: ${textValue(payment['failureReason'])}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showJsonDetail(
                    context,
                    title: 'Chi tiet thanh toan',
                    data: payment,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: refundable && remaining > 0
                      ? () => _showRefundDialog(payment)
                      : null,
                  icon: const Icon(Icons.currency_exchange_outlined),
                  label: const Text('Hoan tien'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({this.user});

  final JsonMap? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _api = AdminApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  late final TextEditingController _passwordController;

  bool _isSaving = false;
  String? _errorMessage;
  String _status = 'ACTIVE';

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _firstNameController = TextEditingController(
      text: textValue(user?['firstName'], ''),
    );
    _lastNameController = TextEditingController(
      text: textValue(user?['lastName'], ''),
    );
    _emailController = TextEditingController(
      text: textValue(user?['email'], ''),
    );
    _phoneController = TextEditingController(
      text: textValue(user?['phone'], ''),
    );
    _avatarController = TextEditingController(
      text: textValue(user?['avatarUrl'], ''),
    );
    _passwordController = TextEditingController();
    _status = textValue(user?['status'], 'ACTIVE').toUpperCase();
    if (!const ['ACTIVE', 'INACTIVE'].contains(_status)) {
      _status = 'ACTIVE';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final body = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'avatarUrl': _avatarController.text.trim().isEmpty
          ? null
          : _avatarController.text.trim(),
      'status': _status,
    };

    if (!_isEdit) {
      body['email'] = _emailController.text.trim();
      body['password'] = _passwordController.text;
    }

    try {
      if (_isEdit) {
        await _api.updateUser(intValue(widget.user!['id']), body);
      } else {
        await _api.createUser(body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Cap nhat nguoi dung' : 'Tao nguoi dung'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  _InlineError(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Ten'),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Ho'),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isEdit,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _isEdit ? null : _emailText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'So dien thoai'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarController,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
                if (!_isEdit) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Mat khau'),
                    obscureText: true,
                    validator: (value) {
                      if ((value ?? '').length < 6) {
                        return 'Mat khau toi thieu 6 ky tu.';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Trang thai'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                    DropdownMenuItem(
                      value: 'INACTIVE',
                      child: Text('INACTIVE'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Phan quyen role hien duoc backend kiem soat bang JWT/RBAC. Man nay tao va cap nhat thong tin tai khoan.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Luu'),
        ),
      ],
    );
  }
}

class _RefundDialog extends StatefulWidget {
  const _RefundDialog({required this.payment});

  final JsonMap payment;

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  final _api = AdminApiService();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  double get _remaining {
    final amount = doubleValue(widget.payment['amount']);
    final refunded = doubleValue(widget.payment['refundedAmount']);
    return (amount - refunded).clamp(0, double.infinity);
  }

  @override
  void initState() {
    super.initState();
    final remaining = _remaining;
    if (remaining > 0) {
      _amountController.text = remaining.round().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _refund() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0 || amount > _remaining) {
      setState(() {
        _errorMessage = 'So tien hoan khong hop le.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _api.refundPayment(
        intValue(widget.payment['id']),
        amount: amount,
        reason: _reasonController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hoan tien payment #${widget.payment['id']}'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('So tien con co the hoan: ${formatMoney(_remaining)}'),
            const SizedBox(height: 12),
            if (_errorMessage != null) ...[
              _InlineError(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'So tien hoan'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Ly do hoan tien'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _refund,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Hoan tien'),
        ),
      ],
    );
  }
}

class _AdminPageScaffold extends StatelessWidget {
  const _AdminPageScaffold({
    required this.title,
    required this.body,
    this.onRefresh,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final Future<void> Function()? onRefresh;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (onRefresh != null)
            IconButton(
              tooltip: 'Tai lai',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ...actions,
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: body,
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.hintText,
    required this.resultText,
    required this.onChanged,
    this.trailing,
  });

  final TextEditingController controller;
  final String hintText;
  final String resultText;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 14,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 520,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            _StatusBadge(label: resultText, color: _primary),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thu lai')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}

const _primary = Color(0xFF3F63B5);

bool _matches(JsonMap data, String query) {
  return data.values.any((value) {
    return value?.toString().toLowerCase().contains(query) ?? false;
  });
}

bool _isInactive(dynamic status) =>
    status?.toString().toUpperCase() == 'INACTIVE';

bool _canRefund(String status) {
  return const {
    'COMPLETED',
    'PARTIALLY_REFUNDED',
  }.contains(status.toUpperCase());
}

Color _statusColor(dynamic status) {
  final value = status?.toString().toUpperCase() ?? '';
  if (const {'ACTIVE', 'COMPLETED', 'CONFIRMED', 'APPROVED'}.contains(value)) {
    return Colors.green;
  }
  if (const {
    'PENDING',
    'PENDING_APPROVAL',
    'PENDING_PAYMENT',
  }.contains(value)) {
    return Colors.orange;
  }
  if (const {
    'FAILED',
    'REJECTED',
    'CANCELLED',
    'INACTIVE',
    'SUSPENDED',
  }.contains(value)) {
    return Colors.redAccent;
  }
  if (const {'REFUNDED', 'PARTIALLY_REFUNDED'}.contains(value)) {
    return Colors.purple;
  }
  return Colors.blueGrey;
}

String _fullName(JsonMap user) {
  final firstName = textValue(user['firstName'], '');
  final lastName = textValue(user['lastName'], '');
  return [
    firstName,
    lastName,
  ].where((part) => part.trim().isNotEmpty).join(' ').trim();
}

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vui long nhap thong tin.';
  }
  return null;
}

String? _emailText(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui long nhap email.';
  if (!text.contains('@')) return 'Email khong hop le.';
  return null;
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ),
  );
}

Future<bool?> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xac nhan'),
        ),
      ],
    ),
  );
}

void _showJsonDetail(
  BuildContext context, {
  required String title,
  required JsonMap data,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final rows = data.entries.toList()
        ..sort((left, right) => left.key.compareTo(right.key));
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rows.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(child: Text(textValue(entry.value))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dong'),
          ),
        ],
      );
    },
  );
}
