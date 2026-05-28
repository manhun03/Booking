// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'chat_socket_base.dart';

class _WebChatSocketConnection implements ChatSocketConnection {
  _WebChatSocketConnection({
    required this.socketUrl,
    required this.accessToken,
  }) {
    _connect();
  }

  final String socketUrl;
  final String accessToken;
  final StreamController<Map<String, dynamic>> _messages =
      StreamController<Map<String, dynamic>>.broadcast();

  html.WebSocket? _socket;
  bool _connected = false;
  int _receipt = 0;
  final List<String> _pendingFrames = [];

  @override
  Stream<Map<String, dynamic>> get messages => _messages.stream;

  @override
  void sendMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  }) {
    _sendFrame(
      'SEND',
      {'destination': '/app/chat.send', 'content-type': 'application/json'},
      {'receiverId': receiverId, 'bookingId': bookingId, 'content': content},
    );
  }

  @override
  void markRead(int messageId) {
    _sendFrame(
      'SEND',
      {'destination': '/app/chat.read', 'content-type': 'application/json'},
      {'messageId': messageId},
    );
  }

  @override
  void close() {
    if (_connected) {
      _sendRaw('DISCONNECT\nreceipt:disconnect-${_receipt++}\n\n\u0000');
    }
    _socket?.close();
    _messages.close();
  }

  void _connect() {
    _socket = html.WebSocket(socketUrl);
    _socket!.onOpen.listen((_) {
      _sendRaw(
        'CONNECT\n'
        'accept-version:1.2\n'
        'heart-beat:10000,10000\n'
        'Authorization:Bearer $accessToken\n'
        '\n'
        '\u0000',
        immediate: true,
      );
    });
    _socket!.onMessage.listen((event) {
      final data = event.data;
      if (data is String) {
        _handleData(data);
      }
    });
    _socket!.onClose.listen((_) {
      _connected = false;
    });
  }

  void _handleData(String data) {
    if (data.trim().isEmpty) return;
    for (final rawFrame in data.split('\u0000')) {
      if (rawFrame.trim().isEmpty) continue;
      final frame = _parseFrame(rawFrame);
      if (frame.command == 'CONNECTED') {
        _connected = true;
        _subscribe('/user/queue/messages', 'chat-messages');
        _flushPendingFrames();
      } else if (frame.command == 'MESSAGE' && frame.body.trim().isNotEmpty) {
        final decoded = jsonDecode(frame.body);
        if (decoded is Map) {
          _messages.add(decoded.map((key, value) => MapEntry('$key', value)));
        }
      } else if (frame.command == 'ERROR') {
        _messages.addError(frame.body.isEmpty ? 'WebSocket error' : frame.body);
      }
    }
  }

  void _subscribe(String destination, String id) {
    _sendRaw('SUBSCRIBE\nid:$id\ndestination:$destination\n\n\u0000');
  }

  void _sendFrame(
    String command,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) {
    final encodedBody = jsonEncode(body);
    final buffer = StringBuffer(command);
    buffer.write('\n');
    headers.forEach((key, value) {
      buffer.write('$key:$value\n');
    });
    buffer.write('\n');
    buffer.write(encodedBody);
    buffer.write('\u0000');
    _sendRaw(buffer.toString());
  }

  void _sendRaw(String frame, {bool immediate = false}) {
    final socket = _socket;
    if (socket == null || socket.readyState != html.WebSocket.OPEN) {
      if (!immediate) _pendingFrames.add(frame);
      return;
    }
    if (!immediate && !_connected) {
      _pendingFrames.add(frame);
      return;
    }
    socket.send(frame);
  }

  void _flushPendingFrames() {
    final frames = List<String>.from(_pendingFrames);
    _pendingFrames.clear();
    frames.forEach(_sendRaw);
  }

  _StompFrame _parseFrame(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    final command = lines.first.trim();
    var index = 1;
    while (index < lines.length && lines[index].trim().isNotEmpty) {
      index++;
    }
    final body = index + 1 >= lines.length
        ? ''
        : lines.sublist(index + 1).join('\n');
    return _StompFrame(command, body);
  }
}

class _StompFrame {
  const _StompFrame(this.command, this.body);

  final String command;
  final String body;
}

ChatSocketConnection createChatSocketConnection({
  required String socketUrl,
  required String accessToken,
}) {
  return _WebChatSocketConnection(
    socketUrl: socketUrl,
    accessToken: accessToken,
  );
}
