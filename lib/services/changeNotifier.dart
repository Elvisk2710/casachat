import 'package:flutter/foundation.dart';

import 'notification_service.dart';

class ChatNotifier extends ChangeNotifier {
  bool isLoading = true;
  List<dynamic> _messages = [];

  List<dynamic> get messages => _messages;

  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;
  // Call this method to add new messages and update the loading state
  void addMessage(Map<String, dynamic> messageData) {
    // Check if the 'chats' key exists and is a List
    var chatList = messageData['chats'];
    if (chatList != null && chatList is List) {
      // Cast each item in the list to Map<String, dynamic>
      _messages = chatList.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          // Handle unexpected item types if necessary
          return {};
        }
      }).toList();
    } else {
      _messages = [];
    }

    // If needed, set _isLoading to false once the data is loaded
    isLoading = false;
    // Notify listeners of changes
    notifyListeners();
  }

  // Call this method to update the chat list
  void updateChatList(Map<String, dynamic> chatData) {
    List<Map<String, dynamic>> chatList =
        List<Map<String, dynamic>>.from(chatData['chats'] ?? []);

    chatList.sort((a, b) {
      final aMsgId = int.tryParse(a['lastMsgId'] ?? '0') ?? 0;
      final bMsgId = int.tryParse(b['lastMsgId'] ?? '0') ?? 0;
      return bMsgId.compareTo(aMsgId);
    });

    var firstChat = chatList.isNotEmpty ? chatList.first : null;
    if (firstChat != null) {
      var newMessage = firstChat['message'];
      var newMessageSender = firstChat['sender'];
      var newMessageId = firstChat['lastMsgId'];
      var newMessageIsRead = firstChat['isRead'];

      if (newMessageSender != null &&
          newMessage != null &&
          !isLoading &&
          newMessageIsRead != '1') {
        // Assuming NotificationService is already set up
        NotificationService().showNotification(
          int.parse(newMessageId),
          "${firstChat['firstname']} ${firstChat['lastname']}",
          newMessage.toString(),
          'Test Payload',
        );
      }
    }

    _data = {
      'chats': chatList,
      'numberOfChats': chatData['numberOfChats'],
      'format': chatData['format']
    };
    isLoading = false;
    notifyListeners();
  }

  // Call this method to set the loading state
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void printData() {
    print(_data);
  }
}
