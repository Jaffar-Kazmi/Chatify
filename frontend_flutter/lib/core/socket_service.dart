import 'package:chat_app/core/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();
  bool _isInitialized = false;

  SocketService._internal();

  Future<void> initSocket() async {
    if (_isInitialized && _socket != null && _socket!.connected) {
      print('Socket already initialized and connected');
      return;
    }

    String token = await _storage.read(key: 'token') ?? '';

    if (token.isEmpty) {
      print('No token found, cannot initialize socket');
      return;
    }

    // Dispose old socket if exists
    if (_socket != null) {
      _socket!.dispose();
    }

    _socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
      _isInitialized = true;
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onConnectError((data) {
      print('Socket connection error: $data');
    });

    _socket!.onError((data) {
      print('Socket error: $data');
    });
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isInitialized = false;
    }
  }

  Future<void> reconnect() async {
    await disconnect();
    await initSocket();
  }

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket not initialized. Call initSocket() first.');
    }
    return _socket!;
  }

  bool get isConnected => _socket?.connected ?? false;
}