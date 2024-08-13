import 'dart:async';
import '../model/message.dart';
class MessageService {
  final _newMessageController = StreamController<Message>.broadcast();

  void addNewMessage(Message message) {
    _newMessageController.sink.add(message);
  }

  Stream<Message> get newMessageStream => _newMessageController.stream;

  void dispose() {
    _newMessageController.close();
  }
}

class MessageQueue {
  final List<Map<String, dynamic>> _queue = [];

  void addMessage(Map<String, dynamic> message) {
    _queue.add(message);
  }

  Map<String, dynamic>? getNextMessage() {
    return _queue.isNotEmpty ? _queue.removeAt(0) : null;
  }

  bool get isEmpty => _queue.isEmpty;
}
