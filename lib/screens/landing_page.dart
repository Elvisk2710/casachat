// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:casachat/components/chatList.dart';
import 'package:casachat/components/search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  final String user;
  const LandingPage({super.key, required this.user});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: MediaQuery.of(context).size.width,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "CasaChat",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          CustomSearchBar(),
          Expanded(
            flex: 2,
            child: ChatList(
              user: widget.user,
            ),
          ),
        ],
      ),
    );
  }
}
