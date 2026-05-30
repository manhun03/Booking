import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/chat_socket.dart';
import '../services/owner_api_service.dart';
import '../utils/constants.dart';
import '../utils/display_format.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, this.conversation});

  final Map<String, dynamic>? conversation;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _message = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = const [];
  ChatSocketConnection? _socket;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  int get _otherUserId => intValue(widget.conversation?['userId']);
  int? get _currentUserId => AuthService().currentSession?.userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _message.dispose();
    _scrollController.dispose();
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
      _handleSocketMessage,
      onError: (error) {
        if (!mounted) return;
        setState(() => _error = 'Mat ket noi realtime: $error');
      },
    );
  }

  Future<void> _load() async {
    if (_otherUserId <= 0) {
      setState(() {
        _loading = false;
        _error = 'Khong tim thay nguoi nhan.';
      });
      return;
    }
    try {
      final messages = await _api.fetchMessages(_otherUserId);
      final unread = messages.where((message) {
        return message['read'] != true &&
            intValue(message['receiverId']) == _currentUserId;
      }).toList();
      await Future.wait(
        unread.map((message) => _api.markMessageRead(intValue(message['id']))),
      );
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      _markVisibleIncomingAsRead();
      _moveToEnd();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  void _handleSocketMessage(Map<String, dynamic> raw) {
    final senderId = intValue(raw['senderId']);
    final receiverId = intValue(raw['receiverId']);
    final currentUserId = _currentUserId;
    if (currentUserId == null || _otherUserId <= 0) return;

    final belongsToConversation =
        (senderId == currentUserId && receiverId == _otherUserId) ||
        (senderId == _otherUserId && receiverId == currentUserId);
    if (!belongsToConversation) return;

    setState(() {
      _upsertMessage(raw);
      _sending = false;
      _error = null;
    });
    _markMessageReadIfNeeded(raw);
    _moveToEnd();
  }

  Future<void> _send() async {
    final content = _message.text.trim();
    if (content.isEmpty || _otherUserId <= 0) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    _message.clear();

    try {
      final sent = await _api.sendMessage(
        receiverId: _otherUserId,
        content: content,
      );
      if (!mounted) return;
      setState(() {
        _upsertMessage(sent);
        _sending = false;
        _error = null;
      });
      _moveToEnd();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _upsertMessage(Map<String, dynamic> message) {
    final id = intValue(message['id']);
    final nextMessages = List<Map<String, dynamic>>.from(_messages);
    final index = id <= 0
        ? -1
        : nextMessages.indexWhere((item) => intValue(item['id']) == id);
    if (index >= 0) {
      nextMessages[index] = message;
    } else {
      nextMessages.add(message);
    }
    nextMessages.sort((left, right) {
      final leftDate = DateTime.tryParse(left['createdAt']?.toString() ?? '');
      final rightDate = DateTime.tryParse(right['createdAt']?.toString() ?? '');
      if (leftDate != null && rightDate != null) {
        return leftDate.compareTo(rightDate);
      }
      return intValue(left['id']).compareTo(intValue(right['id']));
    });
    _messages = nextMessages;
  }

  void _markVisibleIncomingAsRead() {
    for (final message in _messages) {
      _markMessageReadIfNeeded(message);
    }
  }

  void _markMessageReadIfNeeded(Map<String, dynamic> message) {
    final id = intValue(message['id']);
    if (id <= 0 || message['read'] == true) return;
    if (intValue(message['receiverId']) != _currentUserId) return;

    unawaited(_api.markMessageRead(id));
  }

  void _moveToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = textValue(widget.conversation?['displayName'], 'Khach hang');
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 16)),
            Text(
              textValue(widget.conversation?['email'], ''),
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _content()),
          _input(),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _load, child: const Text('Thu lai')),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(child: Text('Bat dau cuoc tro chuyen.'));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(18),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _bubble(_messages[index]),
    );
  }

  Widget _bubble(Map<String, dynamic> message) {
    final mine = intValue(message['senderId']) == _currentUserId;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: mine ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                textValue(message['content'], ''),
                style: TextStyle(color: mine ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formatDate(message['createdAt'], withTime: true),
              style: const TextStyle(color: Colors.black45, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _message,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Nhap tin nhan...',
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sending ? null : _send,
            style: IconButton.styleFrom(backgroundColor: _primaryBlue),
            icon: _sending
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
