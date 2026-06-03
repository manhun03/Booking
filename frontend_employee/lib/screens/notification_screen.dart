import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _api.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _markAll() async {
    try {
      await _api.markAllNotificationsRead();
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (item['read'] == true) return;
    await _api.markNotificationRead(intValue(item['id']));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Thong bao'),
        actions: [
          IconButton(
            tooltip: 'Danh dau tat ca da doc',
            onPressed: _markAll,
            icon: const Icon(Icons.done_all, color: _primaryBlue),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('Chua co thong bao.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, index) => _tile(_items[index]),
                    ),
            ),
    );
  }

  Widget _tile(Map<String, dynamic> item) {
    final unread = item['read'] != true;
    final type = textValue(item['type'], 'SYSTEM');
    final icon = switch (type) {
      'BOOKING' => Icons.book_online,
      'PAYMENT' => Icons.payments_outlined,
      'REVIEW' => Icons.star_outline,
      _ => Icons.notifications_none,
    };
    return Material(
      color: unread ? _primaryBlue.withValues(alpha: 0.05) : Colors.white,
      child: InkWell(
        onTap: () => _markRead(item),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: _primaryBlue.withValues(alpha: 0.12),
            child: Icon(icon, color: _primaryBlue),
          ),
          title: Text(
            textValue(item['title']),
            style: TextStyle(
              fontWeight: unread ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(textValue(item['message'])),
              const SizedBox(height: 5),
              Text(
                formatDate(item['createdAt'], withTime: true),
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          trailing: unread
              ? const CircleAvatar(radius: 5, backgroundColor: _primaryBlue)
              : null,
        ),
      ),
    );
  }
}
