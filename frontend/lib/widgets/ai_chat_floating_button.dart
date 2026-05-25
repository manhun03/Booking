import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';

class AiChatFloatingButton extends StatefulWidget {
  const AiChatFloatingButton({super.key});

  @override
  State<AiChatFloatingButton> createState() => _AiChatFloatingButtonState();
}

class _AiChatFloatingButtonState extends State<AiChatFloatingButton> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_AiChatMessage> _messages = [];
  bool _isOpen = false;
  bool _isSending = false;
  String? _threadId;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.width < 700;
    final right = isCompact ? 16.0 : 24.0;
    final bottom = (isCompact ? 84.0 : 24.0) + media.viewPadding.bottom;

    return Positioned(
      right: right,
      bottom: bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isOpen) ...[
            _buildPanel(context, isCompact: isCompact),
            const SizedBox(height: 12),
          ],
          _buildLauncher(),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context, {required bool isCompact}) {
    final media = MediaQuery.of(context);
    final width = isCompact ? media.size.width - 32 : 380.0;
    final height =
        math.min(media.size.height * 0.68, isCompact ? 480.0 : 560.0);

    return Material(
      color: AppColors.white,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ApiService().isAuthenticated
                  ? _buildChatBody()
                  : _buildLoginPrompt(),
            ),
            if (ApiService().isAuthenticated) _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      decoration: const BoxDecoration(
        color: AppColors.colorPrimary,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI StaySmart',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hỏi về đặt phòng, khách sạn và tài khoản',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFEAF3FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSending ? null : _clearConversation,
            icon: const Icon(Icons.refresh, color: AppColors.white, size: 18),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isOpen = false;
              });
            },
            icon: const Icon(Icons.close, color: AppColors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody() {
    final visibleMessages = _messages.isEmpty
        ? [
            _AiChatMessage.assistant(
              'Xin chào, tôi có thể hỗ trợ bạn tìm khách sạn, kiểm tra đặt phòng hoặc giải đáp thắc mắc khi sử dụng StaySmart.',
            ),
          ]
        : _messages;

    return Column(
      children: [
        if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            itemCount: visibleMessages.length + (_isSending ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isSending && index == visibleMessages.length) {
                return _buildTypingBubble();
              }
              return _buildMessageBubble(visibleMessages[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.colorPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vui lòng đăng nhập để chat với AI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI chat dùng phiên đăng nhập hiện tại để cá nhân hóa câu trả lời.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isOpen = false;
                });
                unawaited(Navigator.of(context).pushNamed('/login'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCCD2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFC81E3A),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_AiChatMessage message) {
    final isUser = message.isUser;
    final bubbleColor =
        isUser ? AppColors.colorPrimary : const Color(0xFFF3F6FA);
    final textColor = isUser ? AppColors.white : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 288),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: textColor.withValues(alpha: 0.68),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'AI đang trả lời...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => unawaited(_sendMessage()),
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.colorPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            height: 42,
            child: ElevatedButton(
              onPressed: _isSending ? null : () => unawaited(_sendMessage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: const Color(0xFFB8C0CC),
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.send_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLauncher() {
    return Material(
      color: AppColors.colorPrimary,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          setState(() {
            _isOpen = !_isOpen;
            _errorMessage = null;
          });
          _scrollToBottom();
        },
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            _isOpen ? Icons.keyboard_arrow_down : Icons.smart_toy_outlined,
            color: AppColors.white,
            size: _isOpen ? 28 : 26,
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (!ApiService().isAuthenticated) {
      setState(() {
        _errorMessage = 'Vui lòng đăng nhập trước khi chat với AI.';
      });
      return;
    }

    _messageController.clear();
    setState(() {
      _messages.add(_AiChatMessage.user(text));
      _isSending = true;
      _errorMessage = null;
    });
    _scrollToBottom();

    try {
      final response = await ApiService().sendAiChatMessage(
        message: text,
        threadId: _threadId,
      );
      if (!mounted) return;
      setState(() {
        _threadId = response['threadId'] as String? ?? _threadId;
        _messages.add(
          _AiChatMessage.assistant(response['content']?.toString() ?? ''),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      _threadId = null;
      _errorMessage = null;
    });
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

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _AiChatMessage {
  _AiChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  factory _AiChatMessage.user(String text) {
    return _AiChatMessage(
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );
  }

  factory _AiChatMessage.assistant(String text) {
    return _AiChatMessage(
      text: text,
      isUser: false,
      createdAt: DateTime.now(),
    );
  }

  final String text;
  final bool isUser;
  final DateTime createdAt;
}
