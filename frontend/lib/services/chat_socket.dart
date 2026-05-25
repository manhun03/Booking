import 'chat_socket_stub.dart' if (dart.library.html) 'chat_socket_web.dart';
import 'chat_socket_base.dart';
export 'chat_socket_base.dart';

ChatSocketConnection connectChatSocket({
  required String socketUrl,
  required String accessToken,
}) {
  return createChatSocketConnection(
    socketUrl: socketUrl,
    accessToken: accessToken,
  );
}
