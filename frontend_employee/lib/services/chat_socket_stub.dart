import 'dart:async';

import 'chat_socket_base.dart';

class _UnsupportedChatSocketConnection implements ChatSocketConnection {
  final StreamController<Map<String, dynamic>> _messages =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messages => _messages.stream;

  @override
  void sendMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  }) {}

  @override
  void markRead(int messageId) {}

  @override
  void close() {
    _messages.close();
  }
}

ChatSocketConnection createChatSocketConnection({
  required String socketUrl,
  required String accessToken,
}) {
  return _UnsupportedChatSocketConnection();
}
