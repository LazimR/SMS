import 'dart:async';
import 'dart:io';

Future<bool> sendData({
  required String host,
  required int port,
  required int level,
  required String lat,
  required String long,
}) async {
  Socket? socket;
  try {
    socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );
    socket.write('$level\n$lat\n$long');
    await socket.flush();
    return true;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  } finally {
    await socket?.close();
  }
}
