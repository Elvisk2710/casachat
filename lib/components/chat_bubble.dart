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

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.sender == widget.me;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe
        ? Theme.of(context).brightness == Brightness.dark
            ? accentColor
            : accentColor
        : Theme.of(context).brightness == Brightness.light
            ? secondaryColor
            : Colors.grey[700];

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
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? accentColor.withOpacity(0.6)
                                    : Colors.grey[300]),
                      ),
                      SizedBox(height: 5.0),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16.5,
                          color: !isMe ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      SizedBox(height: 5.0),
                      Container(
                        alignment: alignment,
                        child: Text(
                          widget.time,
                          style: TextStyle(
                              fontSize: 13.0,
                              color: isMe ? Colors.black : accentColor),
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
