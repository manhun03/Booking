import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/chat_socket.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class MessageChatScreen extends StatefulWidget {
  const MessageChatScreen({
    super.key,
    this.contact,
  });

  final Map<String, dynamic>? contact;

  @override
  State<MessageChatScreen> createState() => _MessageChatScreenState();
}

class _MessageChatScreenState extends State<MessageChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  ChatSocketConnection? _socket;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  int? get _currentUserId => _api.currentSession?.userId;

  int? get _otherUserId {
    final data = widget.contact;
    if (data == null) return null;
    return _intValue(data['userId']) ?? _intValue(data['id']);
  }

  String get _contactName {
    final name = widget.contact?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Lien he';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    _socketSubscription?.cancel();
    _socket?.close();
    super.dispose();
  }

  Future<void> _init() async {
    final restored = await _api.restoreSession();
    if (!restored || !_api.isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Vui long dang nhap de su dung tin nhan.';
      });
      return;
    }

    if (_otherUserId == null || _otherUserId == 0) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Khong tim thay nguoi nhan.';
      });
      return;
    }

    if (_api.currentSession?.userId == null) {
      await _api.fetchCurrentUser();
    }

    _connectSocket();
    await _loadMessages();
  }

  void _connectSocket() {
    final token = _api.currentSession?.accessToken;
    if (token == null || token.trim().isEmpty || _socket != null) {
      return;
    }

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

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final messages = await _api.fetchChatMessages(_otherUserId!);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
      });
      _markVisibleIncomingAsRead();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Khong tai duoc tin nhan: $error';
      });
    }
  }

  void _handleSocketMessage(Map<String, dynamic> raw) {
    final message = _normalizeSocketMessage(raw);
    final senderId = _intValue(message['senderId']);
    final receiverId = _intValue(message['receiverId']);
    final currentUserId = _currentUserId;
    final otherUserId = _otherUserId;
    if (currentUserId == null || otherUserId == null) return;

    final belongsToConversation =
        (senderId == currentUserId && receiverId == otherUserId) ||
            (senderId == otherUserId && receiverId == currentUserId);
    if (!belongsToConversation) return;

    setState(() {
      _upsertMessage(message);
      _sending = false;
    });
    _markMessageReadIfNeeded(message);
    _scrollToBottom();
  }

  Map<String, dynamic> _normalizeSocketMessage(Map<String, dynamic> raw) {
    final createdAt = _dateTimeValue(raw['createdAt']);
    return {
      'id': _intValue(raw['id']) ?? 0,
      'senderId': _intValue(raw['senderId']),
      'receiverId': _intValue(raw['receiverId']),
      'bookingId': _intValue(raw['bookingId']),
      'content': raw['content']?.toString() ?? '',
      'read': raw['read'] == true,
      'createdAt': createdAt,
      'readAt': _dateTimeValue(raw['readAt']),
      'time': _formatChatTime(createdAt),
      'backend': raw,
    };
  }

  Future<void> _sendMessage() async {
    final content = _composerController.text.trim();
    final receiverId = _otherUserId;
    if (content.isEmpty || receiverId == null || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    _composerController.clear();

    try {
      final message = await _api.sendChatMessage(
        receiverId: receiverId,
        content: content,
      );
      if (!mounted) return;
      setState(() {
        _upsertMessage(message);
        _sending = false;
        _error = null;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Khong gui duoc tin nhan: $error';
      });
    }
  }

  void _upsertMessage(Map<String, dynamic> message) {
    final id = _intValue(message['id']);
    final index = id == null || id == 0
        ? -1
        : _messages.indexWhere((item) => _intValue(item['id']) == id);
    if (index >= 0) {
      _messages[index] = message;
    } else {
      _messages.add(message);
    }
    _messages.sort((a, b) {
      final left = a['createdAt'];
      final right = b['createdAt'];
      if (left is DateTime && right is DateTime) {
        return left.compareTo(right);
      }
      return (_intValue(a['id']) ?? 0).compareTo(_intValue(b['id']) ?? 0);
    });
  }

  void _markVisibleIncomingAsRead() {
    _messages.forEach(_markMessageReadIfNeeded);
  }

  void _markMessageReadIfNeeded(Map<String, dynamic> message) {
    final id = _intValue(message['id']);
    if (id == null || id == 0 || message['read'] == true) return;
    if (_intValue(message['receiverId']) != _currentUserId) return;
    _api.markChatMessageRead(id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_contactName),
          ],
        ),
        backgroundColor: AppColors.colorPrimary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            tooltip: 'Tai lai',
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              if (_error != null) _buildErrorBanner(),
              Expanded(child: _buildMessages()),
              _buildComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade50,
      child: Text(
        _error!,
        style: TextStyle(color: Colors.red.shade900),
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Chua co tin nhan. Hay bat dau cuoc tro chuyen.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(18),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final mine = _intValue(message['senderId']) == _currentUserId;
        return _buildBubble(message, mine: mine);
      },
    );
  }

  Widget _buildBubble(Map<String, dynamic> message, {required bool mine}) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.colorPrimary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: mine ? null : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['content']?.toString() ?? '',
              style: TextStyle(
                color: mine ? AppColors.white : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['time']?.toString() ?? '',
              style: TextStyle(
                color: mine
                    ? AppColors.white.withValues(alpha: 0.75)
                    : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _composerController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Nhap tin nhan',
                filled: true,
                fillColor: AppColors.colorBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: ElevatedButton(
              onPressed: _sending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  DateTime? _dateTimeValue(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : DateTime.tryParse(text);
  }

  String _formatChatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
