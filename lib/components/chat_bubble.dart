import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String sender;
  final String receiver;
  final String time;
  final String text;
  final String? me;

  const ChatBubble({
    required this.sender,
    required this.receiver,
    required this.time,
    required this.text,
    required this.me,
    Key? key,
  }) : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.sender == widget.me;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe
        ? Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]
        : Colors.grey[400]
        : Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[500]
        : Colors.grey[100];

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isExpanded) ...[
                      Text(
                        widget.sender,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5.0),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    if (isExpanded) ...[
                      SizedBox(height: 5.0),
                      Container(
                        alignment: alignment,
                        child: Text(
                          widget.time,
                          style: TextStyle(fontSize: 13.0, color: accentColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
