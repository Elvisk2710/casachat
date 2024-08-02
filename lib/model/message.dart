class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;

  Message({
    required this.message,
    required this.receiverId,
    required this.senderEmail,
    required this.senderId,
  });

//   convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
    };
  }
}
