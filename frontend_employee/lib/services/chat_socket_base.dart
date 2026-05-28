import 'dart:async';

abstract class ChatSocketConnection {
  Stream<Map<String, dynamic>> get messages;

  void sendMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  });

  void markRead(int messageId);

  void close();
}
