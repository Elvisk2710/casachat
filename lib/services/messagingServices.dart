import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'package:casachat/model/message.dart';

class ChatService extends ChangeNotifier {
  Future<void> sendMessage(String receiverId, String message) async {
    String? _me = await checkJwtToken();

    if (_me != null) {
      Message newMessage = Message(
        message: message,
        receiverId: receiverId,
        senderEmail: 'kadeyaelvis@gmail.com',
        senderId: _me,
      );

      List<String> ids = [_me, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      final response = await http.post(
        Uri.parse('http://192.168.1.13:81/casamax/chat/server/insert_chat.php'),
        body: {
          'outgoing_id': _me,
          'incoming_id': receiverId,
          'message': message,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print('Message sent successfully');
        } else {
          print('Error: ${responseData['error']}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    }
  }

  Future<List?> getMessages(String userId, String otherId) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.13:81/casamax/chat/server/get_chat_msg.php?outgoing_id=$userId&incoming_id=$otherId'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['messages'];
      } else {
        print('Error: ${responseData['error']}');
        return null;
      }
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
