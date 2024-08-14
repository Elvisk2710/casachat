import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casachat/components/chatTile.dart';
import 'package:lottie/lottie.dart';
import '../services/changeNotifier.dart';
import '../services/conectivity.dart';
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
  late bool hasInternet = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Introduce a delay of 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      // Update state to make the widget visible
      setState(() {
        _isVisible = true;
      });
    });
    WidgetsBinding.instance.addObserver(this);
    updateInternetConnection();

    // Access ChatNotifier from Provider
    _chatNotifier = Provider.of<ChatNotifier>(context, listen: false);

    // Initialize SocketService with ChatNotifier
    _socketService = SocketService(_chatNotifier);
    _startPingPong();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketService.socket.connect();
      _socketService.socket
          .emit('join', {'user': widget.user, 'type': widget.type});
      updateInternetConnection();
    });
  }

  // check for internet connectivity
  void updateInternetConnection() async {
    final connectionStatus = await checkInternetConnection();
    setState(() {
      hasInternet = connectionStatus;
    });
  }

  // updates on app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _socketService.socket.connect();
      _socketService.socket.emit(
          'join', json.encode({'user': widget.user, 'type': widget.type}));
      updateInternetConnection();
    }
  }

  // disposes the app and its controllers
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pingTimer?.cancel();
    _socketService.socket.off('newChatList', _handleChatListUpdate);
    _socketService.socket.off('updateChatList', _handleChatListUpdate);
    _socketService.socket.dispose();
    super.dispose();
  }

  // start pinging the server
  void _startPingPong() {
    const pingInterval = Duration(seconds: 20);
    _pingTimer = Timer.periodic(pingInterval, (_) {
      _socketService.socket.connect();
      _socketService.socket.emit('ping');
      print('Ping sent to server');
    });

    _socketService.socket.on('pong', (_) => print('Pong received from server'));
  }

  // update the chat list
  void _handleChatListUpdate(dynamic data) {
    final notifier = Provider.of<ChatNotifier>(context, listen: false);
    notifier.updateChatList(data);
    updateInternetConnection();

  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? Consumer<ChatNotifier>(
            builder: (context, notifier, child) {
              final theme = Theme.of(context);
              final chats =
                  notifier.data['chats'] ?? []; // Ensure chats is never null
              return Column(
                children: [
                  Expanded(
                    child: notifier.isLoading
                        ? Center(
                            child:
                                Lottie.asset(Animations.start_chat, width: 200))
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
          )
        : _isVisible
            ? Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(Animations.no_internet,
                          width: 300, frameRate: FrameRate(60)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Failed To Connect To Server",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Center(
                child: Container(
                  child: Lottie.asset(Animations.start_chat,
                      width: 200, frameRate: FrameRate(60)),
                ),
              );
  }
}
