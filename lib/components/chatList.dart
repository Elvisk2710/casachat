import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casachat/components/chatTile.dart';
import 'package:lottie/lottie.dart';
import '../services/changeNotifier.dart';
import '../services/socket_service.dart';
import '../utils/animations.dart';

class ChatList extends StatefulWidget {
  final String user;
  final String type;

  const ChatList({super.key, required this.user, required this.type});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with WidgetsBindingObserver {
  Timer? _pingTimer;
  late SocketService _socketService;
  late ChatNotifier _chatNotifier;

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
      _socketService.socket
          .emit('join', {'user': widget.user, 'type': widget.type});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _socketService.socket.connect();
      _socketService.socket.emit(
          'join', json.encode({'user': widget.user, 'type': widget.type}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pingTimer?.cancel();
    _socketService.socket.off('newChatList', _handleChatListUpdate);
    _socketService.socket.off('updateChatList', _handleChatListUpdate);
    _socketService.socket.dispose();
    super.dispose();
  }

  void _startPingPong() {
    const pingInterval = Duration(seconds: 20);
    _pingTimer = Timer.periodic(pingInterval, (_) {
      _socketService.socket.connect();
      _socketService.socket.emit('ping');
      print('Ping sent to server');
    });

    _socketService.socket.on('pong', (_) => print('Pong received from server'));
  }

  void _handleChatListUpdate(dynamic data) {
    final notifier = Provider.of<ChatNotifier>(context, listen: false);
    notifier.updateChatList(data);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatNotifier>(
      builder: (context, notifier, child) {
        final theme = Theme.of(context);
        final chats =
            notifier.data['chats'] ?? []; // Ensure chats is never null
        return Column(
          children: [
            Expanded(
              child: notifier.isLoading
                  ? Center(
                      child: Lottie.asset(Animations.start_chat, width: 200))
                  : chats.isEmpty && widget.type == 'landlord'
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Center(
                                child: Text(
                                  "Hello Landlord",
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Center(
                                  child: Lottie.asset(Animations.new_chat,
                                      width: 350)),
                              Center(
                                child: Text(
                                  "Please Sit Tight \n Whilst Students Find You",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            final chatId = chat['id'];
                            final isRead = chat['isRead'] ?? '0';
                            return GestureDetector(
                              child: ChatTile(
                                name:
                                    '${chat['firstname']} ${chat['lastname']}',
                                time: chat['message'] != ''
                                    ? chat['timestamp']
                                    : '',
                                lastMessage: chat['message'],
                                chatId: chatId,
                                sender: chat['sender'],
                                isRead: isRead.toString(),
                                user: widget.user,
                                type: widget.type,
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
