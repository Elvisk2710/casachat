import 'package:casachat/screens/chat_details.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  final String name;
  final String time;
  final String lastMessage;
  final String chatId;
  final String user;

  ChatTile(
      {super.key,
      required this.name,
      required this.time,
      required this.chatId,
      required this.user,
      required this.lastMessage});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetails(
              // Pass any necessary data to the ChatDetails screen
              name: widget.name,
              id: widget.chatId,
              user: widget.user,
            ),
          ),
        );
      },
      style: ListTileStyle.list,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondary,
        child: Text(
          widget.name[0],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      title: Text(
        widget.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        widget.lastMessage,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: theme.textTheme.subtitle1?.color,
        ),
      ),
      trailing: Text(
        widget.time,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
