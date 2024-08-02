import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:casachat/components/chat_bubble.dart';
import 'package:casachat/utils/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatDetails extends StatefulWidget {
  final String name;
  final String id;
  final String user;

  ChatDetails(
      {super.key, required this.name, required this.user, required this.id});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  List _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket(widget.id);
  }

  void _initializeSocket(receiver) async {
    _socket = IO.io(
        'http://192.168.1.13:5000',
        IO.OptionBuilder()
            .setTransports(['polling'])
            .enableReconnection() // Enable reconnection attempts
            .setReconnectionAttempts(3) // Limit reconnection attempts
            .setReconnectionDelay(1000) // Delay between reconnections
            .build());

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to Socket.IO server');
      List<String> roomId = [widget.user, widget.id];
      roomId.sort();
      String chatRoomId = roomId.join("_");
      _socket.emit('joinRoom',
          {'roomId': chatRoomId, 'user': widget.user, 'receiver': receiver});

      _socket.on('message', (data) {
        print('Received message data: $data');
        setState(() {
          _messages = data['chats'];
          _isLoading = false;
        });
        _scrollToBottom();
      });
    });

    _socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('User: ${widget.user}');
    print('ID: ${widget.id}');
    List<String> roomId = [widget.user, widget.id];
    roomId.sort();
    String chatRoomId = roomId.join("_");

    Future<void> sendMessage() async {
      if (_messageController.text.isNotEmpty && widget.user != null) {
        _socket.emit('sendMessage', {
          'roomId': chatRoomId,
          'outgoing_id': widget.user,
          'incoming_id': widget.id,
          'message': _messageController.text,
        });
        _messageController.clear();
      }
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        shadowColor: theme.colorScheme.onPrimary,
        title: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.home,
                size: 30,
                color: accentColor,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                print('Message $index: $message');
                return ChatBubble(
                  sender: message['sender'],
                  receiver: message['recipient'],
                  time: message['timestamp'],
                  text: message['message'],
                  me: widget.user,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    cursorColor: theme.colorScheme.onPrimary,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      focusColor: Colors.grey[600],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          width: 2,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socket.dispose(); // Dispose the socket connection
    super.dispose();
  }
}
