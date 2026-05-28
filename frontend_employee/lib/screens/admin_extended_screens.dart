import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';
import '../services/auth_service.dart';
import '../utils/display_format.dart';

typedef JsonMap = Map<String, dynamic>;

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
                    trailing: FilterChip(
                      label: const Text('Chua doc'),
                      selected: _unreadOnly,
                      onSelected: (value) =>
                          setState(() => _unreadOnly = value),
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
              tooltip: 'Danh dau da doc',
              onPressed: read ? null : () => _markRead(notification),
              icon: const Icon(Icons.done_all_outlined),
            ),
          ],
        ),
      ),
    );
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
                  onPressed: () => _showJsonDetail(
                    context,
                    title: 'Chi tiet cau hinh',
                    data: config,
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Chi tiet'),
                ),
                FilledButton.icon(
                  onPressed: () => _showConfigDialog(config: config),
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
