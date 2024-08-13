import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'changeNotifier.dart';

class SocketService {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();

  // Socket instance
  late IO.Socket _socket;

  // Chat notifier instance
  late ChatNotifier _chatNotifier;

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();

  // Stream subscription for connectivity changes
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Factory constructor
  factory SocketService(ChatNotifier chatNotifier) {
    _instance._chatNotifier = chatNotifier;
    return _instance;
  }

  // Private constructor
  SocketService._internal() {
    _initializeSocket();
    _monitorConnectivity();
  }

  // Getter for socket
  IO.Socket get socket => _socket;

  // Initialize the socket connection
  void _initializeSocket() {
    _socket = IO.io(
      'https://casamax-casachat-server.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(-1)
          .setReconnectionDelay(2000)
          .setTimeout(10000)
          .enableForceNewConnection()
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    _socket.connect();

    // Handle socket events
    _socket.on('connect', (_) {
      print('Connected to the server');
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from the server');
    });

    _socket.on('error', (error) {
      print('Connection error: $error');
    });

    // Listen for new messages and update the ChatNotifier
    _socket.on('message', (data) {
      if (data != null && data is Map<String, dynamic>) {
        _chatNotifier.addMessage(data);
      }
    });

    _socket.on('newChatMessage', (data) {
      if (data != null && data is Map<String, dynamic>) {
        _chatNotifier.addMessage(data);
      }
    });

    _socket.on('newChatList', (data) {
      if (data != null && data is Map<String, dynamic>) {
        _chatNotifier.updateChatList(data);
      }
    });

    _socket.on('updateChatList', (data) {
      if (data != null && data is Map<String, dynamic>) {
        _chatNotifier.updateChatList(data);
      }
    });
  }

  // Monitor internet connectivity
  void _monitorConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.cast<ConnectivityResult>().listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        print("No internet connection. Disconnecting socket...");
        _socket.disconnect();
      } else {
        print("Internet connection available. Reconnecting socket...");
        _socket.connect();
      }
    });

  }

  // Send a message
  void sendMessage(String event, dynamic data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    } else {
      print("Socket is not connected. Cannot send message.");
    }
  }

  // Dispose of the socket and subscriptions
  void dispose() {
    _connectivitySubscription.cancel();
    _socket.dispose();
  }
}
