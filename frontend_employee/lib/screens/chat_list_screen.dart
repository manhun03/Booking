import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/chat_socket.dart';
import '../services/owner_api_service.dart';
import '../utils/constants.dart';
import '../utils/display_format.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _conversations = const [];
  bool _loading = true;
  String? _error;
  ChatSocketConnection? _socket;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socket?.close();
    super.dispose();
  }

  Future<void> _init() async {
    await AuthService().restoreSession();
    _connectSocket();
    await _load();
  }

  void _connectSocket() {
    if (!kIsWeb) return;
    final token = AuthService().currentSession?.accessToken;
    if (token == null || token.trim().isEmpty || _socket != null) return;

    final socket = connectChatSocket(
      socketUrl: AppConstants.chatWebSocketUrl,
      accessToken: token,
    );
    _socket = socket;
    _socketSubscription = socket.messages.listen(
      (_) => unawaited(_load(silent: true)),
      onError: (_) {},
    );
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final conversations = await _api.fetchConversations();
      var unreadMessages = <Map<String, dynamic>>[];
      try {
        unreadMessages = await _api.fetchUnreadMessages();
      } catch (_) {
        unreadMessages = const [];
      }
      final unreadByUser = _unreadByOtherUser(unreadMessages);
      final merged = conversations.map((conversation) {
        final userId = intValue(conversation['userId'] ?? conversation['id']);
        return {
          ...conversation,
          'unreadCount':
              unreadByUser[userId] ?? intValue(conversation['unreadCount']),
        };
      }).toList();
      if (!mounted) return;
      setState(() {
        _conversations = merged;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _open(Map<String, dynamic> conversation) async {
    await Navigator.pushNamed(context, '/chat-detail', arguments: conversation);
    if (mounted) _load();
  }

  Map<int, int> _unreadByOtherUser(List<Map<String, dynamic>> messages) {
    final currentUserId = AuthService().currentSession?.userId;
    final counts = <int, int>{};
    for (final message in messages) {
      final senderId = intValue(message['senderId']);
      final receiverId = intValue(message['receiverId']);
      final otherUserId = senderId == currentUserId ? receiverId : senderId;
      if (otherUserId <= 0) continue;
      counts[otherUserId] = (counts[otherUserId] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Tin nhan ho tro'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextButton(onPressed: _load, child: const Text('Thu lai')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _conversations.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 180),
                        Center(child: Text('Chua co cuoc hoi thoai nao.')),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _conversations.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _conversation(_conversations[index]),
                    ),
            ),
    );
  }

  Widget _conversation(Map<String, dynamic> conversation) {
    final unread = intValue(conversation['unreadCount']);
    final name = textValue(conversation['displayName'], 'Khach hang');
    return ListTile(
      onTap: () => _open(conversation),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE7EDFB),
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: _primaryBlue),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        textValue(conversation['lastMessage'], 'Chua co tin nhan'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatDate(conversation['lastMessageAt'], withTime: true),
            style: const TextStyle(color: Colors.black45, fontSize: 11),
          ),
          if (unread > 0) ...[
            const SizedBox(height: 5),
            CircleAvatar(
              radius: 10,
              backgroundColor: _primaryBlue,
              child: Text(
                '$unread',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
