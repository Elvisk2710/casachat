import 'package:casachat/screens/chat_details.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

class ChatTile extends StatefulWidget {
  final String name;
  final String time;
  final String lastMessage;
  final String chatId;
  final String user;
  final String? sender;
  final String isRead;
  final String type;

  ChatTile(
      {super.key,
      required this.name,
      required this.time,
      required this.chatId,
      required this.user,
      required this.sender,
      required this.isRead,
      required this.lastMessage,
      required this.type});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _me = false;
  @override
  Widget build(BuildContext context) {
    print('sender: ${widget.sender}');
    print('receiver: ${widget.user}');
    if (widget.sender == widget.user) {
      _me = true;
    }else{
      _me = false;
    }
    print('this is the isRead ${widget.isRead}');

    final theme = Theme.of(context);

    return ListTile(
      enableFeedback: true,
      onLongPress: () {
        _showPopupMenu(context, widget.chatId);
      },
      tileColor: !_me && widget.isRead == '0' && widget.lastMessage != ''
          ? accentColor.withOpacity(0.2)
          : theme.colorScheme.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetails(
              // Pass any necessary data to the ChatDetails screen
              name: widget.name,
              id: widget.chatId,
              user: widget.user,
              type: widget.type,
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
          fontSize: 17,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            _me ? 'You: ' : '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            widget.lastMessage,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      trailing: !_me && widget.isRead == '0' && widget.lastMessage != ''
          ? CircleAvatar(
              backgroundColor: accentColor,
              radius: 6,
            )
          : Text(
              widget.time,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

void _showPopupMenu(BuildContext context, String chatId) {
  final theme = Theme.of(context);
  final RenderBox button = context.findRenderObject() as RenderBox;
  final Offset position = button.localToGlobal(Offset.zero);

  showMenu<String>(
    shadowColor: theme.colorScheme.secondary,
    color: theme.colorScheme.secondary,
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx,
      position.dy,
    ),
    items: [
      PopupMenuItem<String>(
        value: 'viewHome',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('View Home'),
        ),
      ),
    ],
  ).then((value) {
    if (value == 'viewHome') {
      final viewHomeUrl = Uri.parse(
          'https://casamax.co.zw/listingdetails.php?clicked_id=$chatId');
      _launchURL(context, viewHomeUrl);
    }
  });
}

Future<void> _launchURL(BuildContext context, Uri url) async {
  print('this is the url: $url');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    // Handle the case where the URL cannot be launched
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not launch the URL'),
      ),
    );
  }
}
