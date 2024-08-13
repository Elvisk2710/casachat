import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../components/chat_bubble.dart';
import '../services/changeNotifier.dart';
import '../services/socket_service.dart';
import '../utils/animations.dart';
import '../utils/colors.dart';

class ChatDetails extends StatefulWidget {
  final String name;
  final String id;
  final String user;
  final String type;

  const ChatDetails({
    super.key,
    required this.name,
    required this.user,
    required this.type,
    required this.id,
  });

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> with WidgetsBindingObserver {
  late ChatNotifier _chatNotifier;
  late SocketService _socketService;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Access ChatNotifier from Provider
    _chatNotifier = Provider.of<ChatNotifier>(context, listen: false);

    // Initialize SocketService with ChatNotifier
    _socketService = SocketService(_chatNotifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketService.socket.connect();
      String chatRoomId = _getChatRoomId(widget.user, widget.id);
      _socketService.socket.emit('joinRoom', {
        'roomId': chatRoomId,
        'user': widget.user,
        'receiver': widget.id,
        'type': widget.type,
      });
    });
    _updateIsRead();
    _chatNotifier.addListener(_onChatUpdate);
  }

  void _onChatUpdate() {
    setState(() {}); // Trigger a rebuild when ChatNotifier updates
    _scrollToBottom();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateIsRead();
      _socketService.socket.connect();
      String chatRoomId = _getChatRoomId(widget.user, widget.id);
      _socketService.socket.emit(
        'joinRoom',
        json.encode({
          'roomId': chatRoomId,
          'user': widget.user,
          'receiver': widget.id,
          'type': widget.type,
        }),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _chatNotifier.removeListener(_onChatUpdate);
    super.dispose();
  }

  Future<void> _updateIsRead() async {
    _socketService.sendMessage('updateIsRead', {
      'sender': widget.user,
      'receiver': widget.id,
      'user': widget.user,
      'type': widget.type,
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getChatRoomId(String user1, String user2) {
    List<String> roomId = [user1, user2]..sort();
    return roomId.join("_");
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      print("message sent");
      String chatRoomId = _getChatRoomId(widget.user, widget.id);
      _socketService.sendMessage('sendMessage', {
        'roomId': chatRoomId,
        'outgoing_id': widget.user,
        'incoming_id': widget.id,
        'message': _messageController.text,
        'type': widget.type,
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewHomeUrl = Uri.parse(
        'https://casamax.co.zw/listingdetails.php?clicked_id=${widget.id}');
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
          if (widget.type == 'student')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.home,
                  size: 30,
                  color: accentColor,
                ),
                onPressed: () => _launchURL(context, viewHomeUrl),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_chatNotifier.isLoading) {
      return Center(
        child: Lottie.asset(Animations.start_chat,
            width: 200, frameRate: FrameRate(60)),
      );
    } else if (_chatNotifier.messages.isEmpty && !_chatNotifier.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(Animations.new_chat,
                width: 300, frameRate: FrameRate(60)),
            Text(
              'Start A New Conversation',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: _chatNotifier.messages.length,
        itemBuilder: (context, index) {
          final message = _chatNotifier.messages[index] as Map;
          return ChatBubble(
            sender: message['sender'] ?? '',
            receiver: message['recipient'] ?? '',
            time: message['timestamp'] ?? '',
            text: message['message'] ?? '',
            me: widget.user,
          );
        },
      );
    }
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: !_chatNotifier.isLoading
          ? Row(
        children: [
          Expanded(
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'))
              ],
              controller: _messageController,
              cursorColor: theme.colorScheme.onPrimary,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: theme.colorScheme.primary,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                      width: 2, color: theme.colorScheme.secondary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, color: accentColor),
          ),
        ],
      )
          : Container(),
    );
  }

  Future<void> _launchURL(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the URL')),
      );
    }
  }
}
