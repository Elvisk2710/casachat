import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:casachat/components/chatTile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatList extends StatefulWidget {
  final String user;

  ChatList({super.key, required this.user});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true; // Track loading state
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }
  void _initializeSocket() {
    print(widget.user);
    _socket = IO.io(
        'http://192.168.1.13:5000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection() // Enable reconnection attempts
            .setReconnectionAttempts(3) // Limit reconnection attempts
            .setReconnectionDelay(1000) // Delay between reconnections
            .build());

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to Socket.IO server');
      _socket.emit('join', {'user': widget.user});
    });

    _socket.on('updateChatList', (data) {
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    });


    _socket.on('reconnect_attempt', (_) {
      print('Reconnection Attempt');
    });

    _socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));

    _socket.onError((error) => print('Socket.IO error: $error'));
  }


  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Container(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _data['chats']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final chat = _data['chats'][index];
                      return ChatTile(
                        name: chat['firstname'] + ' ' + chat['lastname'],
                        time: chat['timestamp'],
                        lastMessage: chat['message'],
                        chatId: chat['id'],
                        user: widget.user,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _socket.dispose(); // Dispose the socket connection
    super.dispose();
  }
}
