import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';
import '../services/auth_service.dart';
import '../utils/display_format.dart';

typedef JsonMap = Map<String, dynamic>;

class AdminCouponManagementScreen extends StatefulWidget {
  const AdminCouponManagementScreen({super.key});

  @override
  State<AdminCouponManagementScreen> createState() =>
      _AdminCouponManagementScreenState();
}

class _AdminCouponManagementScreenState
    extends State<AdminCouponManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _coupons = const [];
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final coupons = await _api.fetchCoupons();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  List<JsonMap> get _filteredCoupons {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _coupons;
    return _coupons.where((coupon) {
      return textValue(coupon['code']).toLowerCase().contains(query) ||
          textValue(coupon['description']).toLowerCase().contains(query) ||
          textValue(coupon['discountType']).toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _editCoupon({JsonMap? coupon}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CouponDialog(coupon: coupon),
    );
    if (result == true) await _loadCoupons();
  }

  Future<void> _deleteCoupon(JsonMap coupon) async {
    final id = intValue(coupon['id']);
    if (id <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa coupon'),
        content: Text('Xoa ma ${textValue(coupon['code'])}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteCoupon(id);
      if (!mounted) return;
      _showSnack(context, 'Da xoa coupon.');
      await _loadCoupons();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Quan ly coupon',
      onRefresh: _loadCoupons,
      actions: [
        IconButton(
          tooltip: 'Them coupon',
          onPressed: () => _editCoupon(),
          icon: const Icon(Icons.add),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadCoupons)
          : RefreshIndicator(
              onRefresh: _loadCoupons,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim code, mo ta, loai giam...',
                    resultText: '${_filteredCoupons.length} coupon',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: FilledButton.icon(
                      onPressed: () => _editCoupon(),
                      icon: const Icon(Icons.add),
                      label: const Text('Them coupon'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredCoupons.isEmpty)
                    const _EmptyState(message: 'Khong co coupon phu hop.')
                  else
                    ..._filteredCoupons.map(_couponCard),
                ],
              ),
            ),
    );
  }

  Widget _couponCard(JsonMap coupon) {
    final active = coupon['active'] == true;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.12),
          child: const Icon(Icons.local_offer_outlined, color: Colors.orange),
        ),
        title: Text(
          textValue(coupon['code'], 'Coupon #${coupon['id']}'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${textValue(coupon['discountType'], 'AMOUNT')} - ${formatMoney(coupon['discountValue'])}'
          '\nMin: ${formatMoney(coupon['minOrderAmount'])} | Max uses: ${textValue(coupon['maxUses'], 'Khong gioi han')}'
          '\n${textValue(coupon['description'], 'Khong co mo ta')}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 6,
          children: [
            _Badge(
              label: active ? 'ACTIVE' : 'OFF',
              color: active ? Colors.green : Colors.grey,
            ),
            IconButton(
              tooltip: 'Sua',
              onPressed: () => _editCoupon(coupon: coupon),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xoa',
              onPressed: () => _deleteCoupon(coupon),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponDialog extends StatefulWidget {
  const _CouponDialog({this.coupon});

  final JsonMap? coupon;

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _api = AdminApiService();
  late final TextEditingController _code;
  late final TextEditingController _description;
  late final TextEditingController _discountValue;
  late final TextEditingController _maxDiscountAmount;
  late final TextEditingController _minOrderAmount;
  late final TextEditingController _startAt;
  late final TextEditingController _endAt;
  late final TextEditingController _maxUses;
  late final TextEditingController _usedCount;
  String _discountType = 'AMOUNT';
  bool _active = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    _code = TextEditingController(text: textValue(coupon?['code']));
    _description = TextEditingController(
      text: textValue(coupon?['description']),
    );
    _discountType = textValue(coupon?['discountType'], 'AMOUNT').toUpperCase();
    if (_discountType != 'PERCENT') _discountType = 'AMOUNT';
    _discountValue = TextEditingController(
      text: _numberText(coupon?['discountValue']),
    );
    _maxDiscountAmount = TextEditingController(
      text: _numberText(coupon?['maxDiscountAmount']),
    );
    _minOrderAmount = TextEditingController(
      text: _numberText(coupon?['minOrderAmount']),
    );
    _startAt = TextEditingController(text: _dateText(coupon?['startAt']));
    _endAt = TextEditingController(text: _dateText(coupon?['endAt']));
    _maxUses = TextEditingController(text: textValue(coupon?['maxUses']));
    _usedCount = TextEditingController(
      text: textValue(coupon?['usedCount'], '0'),
    );
    _active = coupon?['active'] != false;
  }

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    _discountValue.dispose();
    _maxDiscountAmount.dispose();
    _minOrderAmount.dispose();
    _startAt.dispose();
    _endAt.dispose();
    _maxUses.dispose();
    _usedCount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final code = _code.text.trim().toUpperCase();
    final discountValue = double.tryParse(_discountValue.text.trim());
    final minOrder =
        double.tryParse(
          _minOrderAmount.text.trim().isEmpty
              ? '0'
              : _minOrderAmount.text.trim(),
        ) ??
        0;
    if (code.isEmpty || discountValue == null || discountValue <= 0) {
      setState(() => _error = 'Vui long nhap code va gia tri giam hop le.');
      return;
    }
    final body = {
      'code': code,
      'description': _description.text.trim(),
      'discountType': _discountType,
      'discountValue': discountValue,
      'maxDiscountAmount': _optionalDouble(_maxDiscountAmount.text),
      'minOrderAmount': minOrder,
      'startAt': _instantOrNull(_startAt.text),
      'endAt': _instantOrNull(_endAt.text),
      'maxUses': _optionalInt(_maxUses.text),
      'usedCount': int.tryParse(_usedCount.text.trim()) ?? 0,
      'active': _active,
    };
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final id = intValue(widget.coupon?['id']);
      if (id <= 0) {
        await _api.createCoupon(body);
      } else {
        await _api.updateCoupon(id, body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.coupon == null ? 'Them coupon' : 'Cap nhat coupon'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Mo ta'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _discountType,
                decoration: const InputDecoration(labelText: 'Loai giam'),
                items: const [
                  DropdownMenuItem(value: 'AMOUNT', child: Text('AMOUNT')),
                  DropdownMenuItem(value: 'PERCENT', child: Text('PERCENT')),
                ],
                onChanged: (value) =>
                    setState(() => _discountType = value ?? 'AMOUNT'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountValue,
                      decoration: const InputDecoration(labelText: 'Gia tri'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxDiscountAmount,
                      decoration: const InputDecoration(
                        labelText: 'Giam toi da',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minOrderAmount,
                      decoration: const InputDecoration(
                        labelText: 'Don toi thieu',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxUses,
                      decoration: const InputDecoration(
                        labelText: 'So lan dung toi da',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startAt,
                      decoration: const InputDecoration(
                        labelText: 'StartAt yyyy-MM-dd',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _endAt,
                      decoration: const InputDecoration(
                        labelText: 'EndAt yyyy-MM-dd',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usedCount,
                decoration: const InputDecoration(labelText: 'Da su dung'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: const Text('Dang kich hoat'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Luu'),
        ),
      ],
    );
  }

  String _numberText(dynamic value) {
    if (value == null) return '';
    final number = doubleValue(value);
    if (number == 0) return '';
    return number == number.roundToDouble()
        ? number.round().toString()
        : number.toString();
  }

  String _dateText(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double? _optionalDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? _optionalInt(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  String? _instantOrNull(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final date = DateTime.tryParse(text);
    if (date == null) return text;
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }
}

class AdminReviewModerationScreen extends StatefulWidget {
  const AdminReviewModerationScreen({super.key});

  @override
  State<AdminReviewModerationScreen> createState() =>
      _AdminReviewModerationScreenState();
}

class _AdminReviewModerationScreenState
    extends State<AdminReviewModerationScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _reviews = const [];
  bool _reportedOnly = false;
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await _api.fetchHotels();
      final reviews = await _api.fetchReviewsForHotels(hotels);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
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
        _errorMessage = 'Khong tai duoc danh sach review.';
        _isLoading = false;
      });
    }
  }

  Future<void> _moderate(JsonMap review, bool visible) async {
    final id = intValue(review['id']);
    if (id <= 0) return;

    try {
      await _api.moderateReview(id: id, visible: visible);
      if (!mounted) return;
      _showSnack(context, visible ? 'Da hien review.' : 'Da an review.');
      await _loadReviews();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  List<JsonMap> get _filteredReviews {
    final query = _query.trim().toLowerCase();
    return _reviews.where((review) {
      if (_reportedOnly && review['reported'] != true) return false;
      if (query.isEmpty) return true;
      return _matches(review, query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Kiem duyet danh gia',
      onRefresh: _loadReviews,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadReviews)
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim review, khach san, noi dung...',
                    resultText: '${_filteredReviews.length} review',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: FilterChip(
                      label: const Text('Chi review bi bao cao'),
                      selected: _reportedOnly,
                      onSelected: (value) {
                        setState(() => _reportedOnly = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _InfoPanel(
                    icon: Icons.info_outline,
                    title: 'Pham vi theo backend hien co',
                    message:
                        'Backend dang expose /reviews/by-hotel/{hotelId}, endpoint nay tra ve review dang hien thi. Review da an khong co endpoint list rieng nen khong hien trong man nay.',
                  ),
                  const SizedBox(height: 16),
                  if (_filteredReviews.isEmpty)
                    const _EmptyState(message: 'Khong co review phu hop.')
                  else
                    ..._filteredReviews.map(_reviewCard),
                ],
              ),
            ),
    );
  }

  Widget _reviewCard(JsonMap review) {
    final visible = review['visible'] != false;
    final reported = review['reported'] == true;
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
                  backgroundColor: Colors.amber.withValues(alpha: 0.16),
                  child: const Icon(
                    Icons.reviews_outlined,
                    color: Colors.amber,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 260),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textValue(
                          review['hotelName'],
                          'Khach san #${review['hotelId']}',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Booking #${textValue(review['bookingId'])} - Customer #${textValue(review['customerId'])}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _Badge(
                  label: '${intValue(review['rating'])}/5 sao',
                  color: Colors.amber.shade800,
                ),
                _Badge(
                  label: visible ? 'VISIBLE' : 'HIDDEN',
                  color: visible ? Colors.green : Colors.redAccent,
                ),
                if (reported)
                  const _Badge(label: 'REPORTED', color: Colors.redAccent),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              textValue(review['comment'], 'Khong co noi dung'),
              style: const TextStyle(fontSize: 15),
            ),
            if (textValue(review['ownerReply'], '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Phan hoi owner: ${textValue(review['ownerReply'])}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            if (reported &&
                textValue(review['reportReason'], '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Ly do bao cao: ${textValue(review['reportReason'])}',
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
                    title: 'Chi tiet review',
                    data: review,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: visible
                      ? () => _moderate(review, false)
                      : () => _moderate(review, true),
                  icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
                  label: Text(visible ? 'An review' : 'Hien review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminNotificationManagementScreen extends StatefulWidget {
  const AdminNotificationManagementScreen({super.key});

  @override
  State<AdminNotificationManagementScreen> createState() =>
      _AdminNotificationManagementScreenState();
}

class _AdminNotificationManagementScreenState
    extends State<AdminNotificationManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _notifications = const [];
  bool _unreadOnly = false;
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _api.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
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
        _errorMessage = 'Khong tai duoc thong bao.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(JsonMap notification) async {
    final id = intValue(notification['id']);
    if (id <= 0) return;
    try {
      await _api.markNotificationRead(id);
      if (!mounted) return;
      _showSnack(context, 'Da danh dau da doc.');
      await _loadNotifications();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  Future<void> _markMineReadAll() async {
    try {
      final count = await _api.markMyNotificationsReadAll();
      if (!mounted) return;
      _showSnack(context, 'Da danh dau $count thong bao cua tai khoan admin.');
      await _loadNotifications();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  Future<void> _showNotificationDialog({JsonMap? notification}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _NotificationFormDialog(notification: notification),
    );
    if (result == true) await _loadNotifications();
  }

  Future<void> _deleteNotification(JsonMap notification) async {
    final id = intValue(notification['id']);
    if (id <= 0) return;
    final confirmed = await _confirmAction(
      context,
      title: 'Xoa thong bao',
      message: 'Ban co chac muon xoa thong bao #$id?',
    );
    if (confirmed != true) return;
    try {
      await _api.deleteNotification(id);
      if (!mounted) return;
      _showSnack(context, 'Da xoa thong bao.');
      await _loadNotifications();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(context, error.message, isError: true);
    }
  }

  List<JsonMap> get _filteredNotifications {
    final query = _query.trim().toLowerCase();
    return _notifications.where((notification) {
      if (_unreadOnly && notification['read'] == true) return false;
      if (query.isEmpty) return true;
      return _matches(notification, query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Quan ly thong bao',
      onRefresh: _loadNotifications,
      actions: [
        IconButton(
          tooltip: 'Tao thong bao',
          onPressed: () => _showNotificationDialog(),
          icon: const Icon(Icons.add_alert_outlined),
        ),
        IconButton(
          tooltip: 'Doc tat ca thong bao cua admin',
          onPressed: _markMineReadAll,
          icon: const Icon(Icons.mark_email_read_outlined),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadNotifications)
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim title, message, type, user...',
                    resultText: '${_filteredNotifications.length} thong bao',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Chua doc'),
                          selected: _unreadOnly,
                          onSelected: (value) =>
                              setState(() => _unreadOnly = value),
                        ),
                        FilledButton.icon(
                          onPressed: () => _showNotificationDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Tao thong bao'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredNotifications.isEmpty)
                    const _EmptyState(message: 'Khong co thong bao phu hop.')
                  else
                    ..._filteredNotifications.map(_notificationCard),
                ],
              ),
            ),
    );
  }

  Widget _notificationCard(JsonMap notification) {
    final read = notification['read'] == true;
    final type = textValue(notification['type'], 'GENERAL');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: read ? Colors.grey.shade200 : _primary),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _typeColor(type).withValues(alpha: 0.12),
          child: Icon(Icons.notifications_outlined, color: _typeColor(type)),
        ),
        title: Text(
          textValue(notification['title'], 'Thong bao #${notification['id']}'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textValue(notification['message'])),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _Badge(label: type, color: _typeColor(type)),
                  _Badge(
                    label: read ? 'READ' : 'UNREAD',
                    color: read ? Colors.grey : Colors.orange,
                  ),
                  Text('User #${textValue(notification['userId'])}'),
                  Text(formatDate(notification['createdAt'], withTime: true)),
                  if (textValue(notification['relatedTable'], '').isNotEmpty)
                    Text(
                      '${textValue(notification['relatedTable'])} #${textValue(notification['relatedId'])}',
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Chi tiet',
              onPressed: () => _showJsonDetail(
                context,
                title: 'Chi tiet thong bao',
                data: notification,
              ),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'Cap nhat',
              onPressed: () =>
                  _showNotificationDialog(notification: notification),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Danh dau da doc',
              onPressed: read ? null : () => _markRead(notification),
              icon: const Icon(Icons.done_all_outlined),
            ),
            IconButton(
              tooltip: 'Xoa',
              onPressed: () => _deleteNotification(notification),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationFormDialog extends StatefulWidget {
  const _NotificationFormDialog({this.notification});

  final JsonMap? notification;

  @override
  State<_NotificationFormDialog> createState() =>
      _NotificationFormDialogState();
}

class _NotificationFormDialogState extends State<_NotificationFormDialog> {
  static const _types = [
    'GENERAL',
    'BOOKING',
    'PAYMENT',
    'PARKING',
    'SYSTEM',
    'REVIEW',
  ];

  final _api = AdminApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;
  late final TextEditingController _senderIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _relatedTableController;
  late final TextEditingController _relatedIdController;
  late String _type;
  late bool _read;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.notification != null;

  @override
  void initState() {
    super.initState();
    final notification = widget.notification;
    _userIdController = TextEditingController(
      text: textValue(notification?['userId'], ''),
    );
    _senderIdController = TextEditingController(
      text: textValue(notification?['senderId'], ''),
    );
    _titleController = TextEditingController(
      text: textValue(notification?['title'], ''),
    );
    _messageController = TextEditingController(
      text: textValue(notification?['message'], ''),
    );
    _relatedTableController = TextEditingController(
      text: textValue(notification?['relatedTable'], ''),
    );
    _relatedIdController = TextEditingController(
      text: textValue(notification?['relatedId'], ''),
    );
    final type = textValue(notification?['type'], 'GENERAL').toUpperCase();
    _type = _types.contains(type) ? type : 'GENERAL';
    _read = notification?['read'] == true;
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _senderIdController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _relatedTableController.dispose();
    _relatedIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final userId = int.tryParse(_userIdController.text.trim());
    if (userId == null || userId <= 0) {
      setState(() => _errorMessage = 'UserId khong hop le.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final senderId = _optionalInt(_senderIdController.text);
    final relatedId = _optionalInt(_relatedIdController.text);
    final createdAt = textValue(widget.notification?['createdAt'], '');
    final readAt = textValue(widget.notification?['readAt'], '');
    final body = {
      'user': {'id': userId},
      if (senderId != null) 'sender': {'id': senderId},
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'type': _type,
      'relatedTable': _blankToNull(_relatedTableController.text),
      'relatedId': relatedId,
      'read': _read,
      'createdAt': createdAt.isEmpty
          ? DateTime.now().toUtc().toIso8601String()
          : createdAt,
      'readAt': _read
          ? (readAt.isEmpty ? DateTime.now().toUtc().toIso8601String() : readAt)
          : null,
    };

    try {
      if (_isEdit) {
        await _api.updateNotification(
          intValue(widget.notification!['id']),
          body,
        );
      } else {
        await _api.createNotification(body);
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
      title: Text(_isEdit ? 'Cap nhat thong bao' : 'Tao thong bao'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  _InlineError(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          labelText: 'UserId nhan *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _requiredText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _senderIdController,
                        decoration: const InputDecoration(
                          labelText: 'SenderId',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message *'),
                  minLines: 2,
                  maxLines: 4,
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: _types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _relatedTableController,
                        decoration: const InputDecoration(
                          labelText: 'Related table',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _relatedIdController,
                        decoration: const InputDecoration(
                          labelText: 'Related id',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _read,
                  onChanged: (value) => setState(() => _read = value),
                  title: const Text('Da doc'),
                  contentPadding: EdgeInsets.zero,
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

  int? _optionalInt(String value) {
    final text = value.trim();
    if (text.isEmpty || text == '-') return null;
    return int.tryParse(text);
  }

  String? _blankToNull(String value) {
    final text = value.trim();
    return text.isEmpty || text == '-' ? null : text;
  }
}

class AdminSystemConfigScreen extends StatefulWidget {
  const AdminSystemConfigScreen({super.key});

  @override
  State<AdminSystemConfigScreen> createState() =>
      _AdminSystemConfigScreenState();
}

class _AdminSystemConfigScreenState extends State<AdminSystemConfigScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _configs = const [];
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final configs = await _api.fetchSystemConfigs();
      if (!mounted) return;
      setState(() {
        _configs = configs;
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
        _errorMessage = 'Khong tai duoc cau hinh he thong.';
        _isLoading = false;
      });
    }
  }

  Future<void> _showConfigDialog({JsonMap? config}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _SystemConfigDialog(config: config),
    );
    if (result == true) await _loadConfigs();
  }

  Future<JsonMap> _fetchFreshConfig(JsonMap config) async {
    final key = textValue(config['configKey']).trim();
    if (key.isEmpty) return config;
    return _api.fetchSystemConfigByKey(key);
  }

  Future<void> _showConfigDetail(JsonMap config) async {
    try {
      final freshConfig = await _fetchFreshConfig(config);
      if (!mounted) return;
      _showJsonDetail(context, title: 'Chi tiet cau hinh', data: freshConfig);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _editConfig(JsonMap config) async {
    try {
      final freshConfig = await _fetchFreshConfig(config);
      if (!mounted) return;
      await _showConfigDialog(config: freshConfig);
    } on ApiException catch (_) {
      if (!mounted) return;
      await _showConfigDialog(config: config);
    }
  }

  List<JsonMap> get _filteredConfigs {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _configs;
    return _configs.where((config) => _matches(config, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Cau hinh he thong',
      onRefresh: _loadConfigs,
      actions: [
        IconButton(
          tooltip: 'Them cau hinh',
          onPressed: () => _showConfigDialog(),
          icon: const Icon(Icons.add),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadConfigs)
          : RefreshIndicator(
              onRefresh: _loadConfigs,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim key, value, description...',
                    resultText: '${_filteredConfigs.length} cau hinh',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: FilledButton.icon(
                      onPressed: () => _showConfigDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Them / cap nhat key'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredConfigs.isEmpty)
                    const _EmptyState(message: 'Khong co cau hinh phu hop.')
                  else
                    ..._filteredConfigs.map(_configCard),
                ],
              ),
            ),
    );
  }

  Widget _configCard(JsonMap config) {
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
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.tune_outlined,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  textValue(config['configKey'], 'Config #${config['id']}'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _Badge(
                  label: textValue(config['dataType'], 'string'),
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              textValue(config['configValue'], '(empty)'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              textValue(config['description'], 'Khong co mo ta'),
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showConfigDetail(config),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: () => _editConfig(config),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Cap nhat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLocationManagementScreen extends StatefulWidget {
  const AdminLocationManagementScreen({super.key});

  @override
  State<AdminLocationManagementScreen> createState() =>
      _AdminLocationManagementScreenState();
}

class _AdminLocationManagementScreenState
    extends State<AdminLocationManagementScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _provinces = const [];
  List<JsonMap> _wards = const [];
  int? _selectedProvinceId;
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provinces = await _api.fetchProvinces();
      final selected =
          _selectedProvinceId ??
          (provinces.isEmpty ? null : intValue(provinces.first['id']));
      final wards = await _api.fetchWards(provinceId: selected);
      if (!mounted) return;
      setState(() {
        _provinces = provinces;
        _selectedProvinceId = selected;
        _wards = wards;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectProvince(int? provinceId) async {
    setState(() {
      _selectedProvinceId = provinceId;
      _wards = const [];
    });
    try {
      final wards = await _api.fetchWards(provinceId: provinceId);
      if (!mounted) return;
      setState(() => _wards = wards);
    } on ApiException catch (error) {
      if (mounted) _showSnack(context, error.message, isError: true);
    }
  }

  Future<void> _showProvinceDialog({JsonMap? province}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ProvinceDialog(province: province),
    );
    if (result == true) await _load();
  }

  Future<void> _showWardDialog({JsonMap? ward}) async {
    if (_provinces.isEmpty) {
      _showSnack(context, 'Can tao Province truoc.', isError: true);
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _WardDialog(
        provinces: _provinces,
        ward: ward,
        initialProvinceId: _selectedProvinceId,
      ),
    );
    if (result == true) await _selectProvince(_selectedProvinceId);
  }

  Future<void> _deleteProvince(JsonMap province) async {
    final id = intValue(province['id']);
    if (id <= 0) return;
    try {
      await _api.deleteProvince(id);
      if (!mounted) return;
      _showSnack(context, 'Da xoa Province.');
      _selectedProvinceId = null;
      await _load();
    } on ApiException catch (error) {
      if (mounted) _showSnack(context, error.message, isError: true);
    }
  }

  Future<void> _deleteWard(JsonMap ward) async {
    final id = intValue(ward['id']);
    if (id <= 0) return;
    try {
      await _api.deleteWard(id);
      if (!mounted) return;
      _showSnack(context, 'Da xoa Ward.');
      await _selectProvince(_selectedProvinceId);
    } on ApiException catch (error) {
      if (mounted) _showSnack(context, error.message, isError: true);
    }
  }

  List<JsonMap> get _filteredProvinces {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _provinces;
    return _provinces.where((item) => _matches(item, query)).toList();
  }

  List<JsonMap> get _filteredWards {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _wards;
    return _wards.where((item) => _matches(item, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Quan ly Province / Ward',
      onRefresh: _load,
      actions: [
        IconButton(
          tooltip: 'Them Province',
          onPressed: () => _showProvinceDialog(),
          icon: const Icon(Icons.add_location_alt_outlined),
        ),
        IconButton(
          tooltip: 'Them Ward',
          onPressed: () => _showWardDialog(),
          icon: const Icon(Icons.add_business_outlined),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim Province, Ward, code...',
                    resultText:
                        '${_filteredProvinces.length} province, ${_filteredWards.length} ward',
                    onChanged: (value) => setState(() => _query = value),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _showProvinceDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Province'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showWardDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Ward'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _provincePanel()),
                      const SizedBox(width: 16),
                      Expanded(child: _wardPanel()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _provincePanel() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Province',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_filteredProvinces.isEmpty)
              const _EmptyState(message: 'Chua co Province.')
            else
              ..._filteredProvinces.map((province) {
                final id = intValue(province['id']);
                final selected = id == _selectedProvinceId;
                return ListTile(
                  selected: selected,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: selected
                        ? _primary.withValues(alpha: 0.16)
                        : null,
                    child: const Icon(Icons.location_city_outlined),
                  ),
                  title: Text(
                    textValue(province['name'], 'Province #$id'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('Code: ${textValue(province['code'])}'),
                  onTap: () => _selectProvince(id),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Sua',
                        onPressed: () =>
                            _showProvinceDialog(province: province),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Xoa',
                        onPressed: () => _deleteProvince(province),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _wardPanel() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ward',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_filteredWards.isEmpty)
              const _EmptyState(message: 'Chua co Ward cho Province nay.')
            else
              ..._filteredWards.map((ward) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.apartment_outlined),
                  ),
                  title: Text(
                    textValue(ward['name'], 'Ward #${ward['id']}'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('Code: ${textValue(ward['code'])}'),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Sua',
                        onPressed: () => _showWardDialog(ward: ward),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Xoa',
                        onPressed: () => _deleteWard(ward),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class AdminAuditLogScreen extends StatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  State<AdminAuditLogScreen> createState() => _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends State<AdminAuditLogScreen> {
  final _api = AdminApiService();
  final _searchController = TextEditingController();

  List<JsonMap> _logs = const [];
  bool _isLoading = true;
  String _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final logs = await _api.fetchAuditLogs();
      logs.sort((left, right) {
        final createdCompare = (right['createdAt']?.toString() ?? '').compareTo(
          left['createdAt']?.toString() ?? '',
        );
        if (createdCompare != 0) return createdCompare;
        return intValue(right['id']).compareTo(intValue(left['id']));
      });
      if (!mounted) return;
      setState(() {
        _logs = logs;
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
        _errorMessage = 'Khong tai duoc audit log.';
        _isLoading = false;
      });
    }
  }

  List<JsonMap> get _filteredLogs {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _logs;
    return _logs.where((log) => _matches(log, query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Audit log',
      onRefresh: _loadLogs,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadLogs)
          : RefreshIndicator(
              onRefresh: _loadLogs,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SearchCard(
                    controller: _searchController,
                    hintText: 'Tim actor, action, target, detail...',
                    resultText: '${_filteredLogs.length} log',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  if (_filteredLogs.isEmpty)
                    const _EmptyState(message: 'Chua co audit log phu hop.')
                  else
                    ..._filteredLogs.map(_logCard),
                ],
              ),
            ),
    );
  }

  Widget _logCard(JsonMap log) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey.withValues(alpha: 0.12),
          child: const Icon(Icons.history_outlined, color: Colors.blueGrey),
        ),
        title: Text(
          textValue(log['action'], 'Action #${log['id']}'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textValue(log['detail'], 'Khong co detail')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text('Actor #${textValue(log['actorId'])}'),
                  Text(
                    '${textValue(log['targetTable'])} #${textValue(log['targetId'])}',
                  ),
                  Text(formatDate(log['createdAt'], withTime: true)),
                ],
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: 'Chi tiet',
          onPressed: () =>
              _showJsonDetail(context, title: 'Chi tiet audit log', data: log),
          icon: const Icon(Icons.visibility_outlined),
        ),
      ),
    );
  }
}

class AdminIntegrationHealthScreen extends StatefulWidget {
  const AdminIntegrationHealthScreen({super.key});

  @override
  State<AdminIntegrationHealthScreen> createState() =>
      _AdminIntegrationHealthScreenState();
}

class _AdminIntegrationHealthScreenState
    extends State<AdminIntegrationHealthScreen> {
  final _api = AdminApiService();

  JsonMap _actuator = const {};
  JsonMap _aiHealth = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _api.fetchActuatorHealth(),
        _api.fetchAiChatHealth(),
      ]);
      if (!mounted) return;
      setState(() {
        _actuator = results[0];
        _aiHealth = results[1];
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
        _errorMessage = 'Khong tai duoc trang thai tich hop.';
        _isLoading = false;
      });
    }
  }

  JsonMap get _components {
    final value = _actuator['components'];
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    return _AdminScaffold(
      title: 'Tich hop he thong',
      onRefresh: _loadHealth,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadHealth)
          : RefreshIndicator(
              onRefresh: _loadHealth,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _InfoPanel(
                    icon: Icons.integration_instructions_outlined,
                    title: 'Health check theo endpoint backend da co',
                    message:
                        'Man nay doc /actuator/health va /api/ai-chat/health. ChatAI chi dung cho hoi dap, khong tu dong tao booking va khong xu ly hinh anh.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _integrationCard(
                        title: 'SQL Server',
                        icon: Icons.storage_outlined,
                        component: _componentByName('db'),
                      ),
                      _integrationCard(
                        title: 'MinIO',
                        icon: Icons.image_outlined,
                        component: _componentByName('minio'),
                      ),
                      _integrationCard(
                        title: 'Firebase FCM',
                        icon: Icons.notifications_active_outlined,
                        component: _componentByName('firebase'),
                      ),
                      _integrationCard(
                        title: 'SMTP',
                        icon: Icons.email_outlined,
                        component: _componentByName('mail'),
                        fallback: 'Mail health chua duoc expose hoac dang tat.',
                      ),
                      _integrationCard(
                        title: 'ChatAI',
                        icon: Icons.smart_toy_outlined,
                        component: _aiHealth,
                      ),
                      _staticIntegrationCard(
                        title: 'VNPay',
                        icon: Icons.payments_outlined,
                        message:
                            'Backend co luong VNPay trong /api/payments, nhung chua expose health/config endpoint rieng.',
                      ),
                      _staticIntegrationCard(
                        title: 'Google Login',
                        icon: Icons.login_outlined,
                        message:
                            'Backend co Google login trong AuthService, nhung chua expose health/config endpoint rieng.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _rawPanel('Actuator health raw', _actuator),
                  const SizedBox(height: 12),
                  _rawPanel('ChatAI health raw', _aiHealth),
                ],
              ),
            ),
    );
  }

  JsonMap? _componentByName(String expected) {
    for (final entry in _components.entries) {
      if (entry.key.toLowerCase() == expected.toLowerCase() &&
          entry.value is Map) {
        return Map<String, dynamic>.from(entry.value as Map);
      }
    }
    for (final entry in _components.entries) {
      if (entry.key.toLowerCase().contains(expected.toLowerCase()) &&
          entry.value is Map) {
        return Map<String, dynamic>.from(entry.value as Map);
      }
    }
    return null;
  }

  Widget _integrationCard({
    required String title,
    required IconData icon,
    required JsonMap? component,
    String fallback = 'Backend chua expose health endpoint rieng.',
  }) {
    final status = textValue(
      component?['status'],
      component == null ? 'UNKNOWN' : 'UP',
    );
    final details = component?['details'];
    return SizedBox(
      width: 340,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _healthColor(
                      status,
                    ).withValues(alpha: 0.12),
                    child: Icon(icon, color: _healthColor(status)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _Badge(label: status, color: _healthColor(status)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                component == null ? fallback : _compactDetails(details),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _staticIntegrationCard({
    required String title,
    required IconData icon,
    required String message,
  }) {
    return SizedBox(
      width: 340,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueGrey.withValues(alpha: 0.12),
                child: Icon(icon, color: Colors.blueGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rawPanel(String title, JsonMap data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(data.toString()),
          ),
        ],
      ),
    );
  }
}

class _SystemConfigDialog extends StatefulWidget {
  const _SystemConfigDialog({this.config});

  final JsonMap? config;

  @override
  State<_SystemConfigDialog> createState() => _SystemConfigDialogState();
}

class _SystemConfigDialogState extends State<_SystemConfigDialog> {
  final _api = AdminApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;
  late final TextEditingController _typeController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.config != null;

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    _keyController = TextEditingController(
      text: textValue(config?['configKey'], ''),
    );
    _valueController = TextEditingController(
      text: textValue(config?['configValue'], ''),
    );
    _typeController = TextEditingController(
      text: textValue(config?['dataType'], 'string'),
    );
    _descriptionController = TextEditingController(
      text: textValue(config?['description'], ''),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _api.updateSystemConfig(
        key: _keyController.text,
        value: _valueController.text,
        dataType: _typeController.text,
        description: _descriptionController.text,
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
      title: Text(_isEdit ? 'Cap nhat cau hinh' : 'Them cau hinh'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  _InlineError(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _keyController,
                  enabled: !_isEdit,
                  decoration: const InputDecoration(labelText: 'Config key'),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Config value'),
                  minLines: 1,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Data type',
                    hintText: 'string, number, boolean, json...',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 1,
                  maxLines: 3,
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

class _ProvinceDialog extends StatefulWidget {
  const _ProvinceDialog({this.province});

  final JsonMap? province;

  @override
  State<_ProvinceDialog> createState() => _ProvinceDialogState();
}

class _ProvinceDialogState extends State<_ProvinceDialog> {
  final _api = AdminApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  bool _active = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final province = widget.province;
    _nameController = TextEditingController(
      text: textValue(province?['name'], ''),
    );
    _codeController = TextEditingController(
      text: textValue(province?['code'], ''),
    );
    _active = province?['active'] != false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Vui long nhap ten Province.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final body = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'active': _active,
    };
    try {
      final id = intValue(widget.province?['id']);
      if (id <= 0) {
        await _api.createProvince(body);
      } else {
        await _api.updateProvince(id, body);
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
    final editing = widget.province != null;
    return AlertDialog(
      title: Text(editing ? 'Sua Province' : 'Them Province'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null) ...[
              _InlineError(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('Active'),
              contentPadding: EdgeInsets.zero,
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
          onPressed: _isSaving ? null : _save,
          child: const Text('Luu'),
        ),
      ],
    );
  }
}

class _WardDialog extends StatefulWidget {
  const _WardDialog({
    required this.provinces,
    this.ward,
    this.initialProvinceId,
  });

  final List<JsonMap> provinces;
  final JsonMap? ward;
  final int? initialProvinceId;

  @override
  State<_WardDialog> createState() => _WardDialogState();
}

class _WardDialogState extends State<_WardDialog> {
  final _api = AdminApiService();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  int? _provinceId;
  bool _active = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final ward = widget.ward;
    _nameController = TextEditingController(text: textValue(ward?['name'], ''));
    _codeController = TextEditingController(text: textValue(ward?['code'], ''));
    _provinceId = intValue(ward?['provinceId']);
    if (_provinceId == 0) {
      _provinceId =
          widget.initialProvinceId ??
          (widget.provinces.isEmpty
              ? null
              : intValue(widget.provinces.first['id']));
    }
    _active = ward?['active'] != false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _provinceId == null) {
      setState(() => _errorMessage = 'Vui long nhap ten Ward va Province.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final body = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'active': _active,
      'province': {'id': _provinceId},
    };
    try {
      final id = intValue(widget.ward?['id']);
      if (id <= 0) {
        await _api.createWard(body);
      } else {
        await _api.updateWard(id, body);
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
    final editing = widget.ward != null;
    return AlertDialog(
      title: Text(editing ? 'Sua Ward' : 'Them Ward'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null) ...[
              _InlineError(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            DropdownButtonFormField<int>(
              initialValue: _provinceId,
              decoration: const InputDecoration(labelText: 'Province'),
              items: widget.provinces
                  .map(
                    (province) => DropdownMenuItem(
                      value: intValue(province['id']),
                      child: Text(textValue(province['name'])),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _provinceId = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('Active'),
              contentPadding: EdgeInsets.zero,
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
          onPressed: _isSaving ? null : _save,
          child: const Text('Luu'),
        ),
      ],
    );
  }
}

class _AdminScaffold extends StatelessWidget {
  const _AdminScaffold({
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

class _SearchCard extends StatelessWidget {
  const _SearchCard({
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
            _Badge(label: resultText, color: _primary),
            if (trailing != null) trailing!,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

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

Color _typeColor(String type) {
  final value = type.toUpperCase();
  if (value == 'BOOKING') return Colors.orange;
  if (value == 'PAYMENT') return Colors.green;
  if (value == 'REVIEW') return Colors.purple;
  if (value == 'MESSAGE') return Colors.blue;
  return Colors.blueGrey;
}

Color _healthColor(String status) {
  final value = status.toUpperCase();
  if (value == 'UP') return Colors.green;
  if (value == 'UNKNOWN') return Colors.orange;
  return Colors.redAccent;
}

String _compactDetails(dynamic details) {
  if (details is Map && details.isNotEmpty) {
    return details.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
  return 'Khong co detail bo sung.';
}

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vui long nhap thong tin.';
  }
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
