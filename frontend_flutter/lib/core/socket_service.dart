import 'package:chat_app/core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  final _storage = FlutterSecureStorage();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket not initialized. Call initSocket() first.');
    }
    return _socket!;
  }
  
  bool get isConnected => _socket?.connected ?? false;

  Future<void> initSocket() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    String? token = await _storage.read(key: 'token');
    
    if (token == null) {
      return;
    }

    _socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect() 
          .build(),
    );

    _socket!.onConnect((_) {
    });

    _socket!.onDisconnect((_) {
    });

    _socket!.onConnectError((data) {
    });
    
    _socket!.onError((data) {
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}