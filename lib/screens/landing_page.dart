import 'package:flutter/material.dart';
import 'package:casachat/components/chatList.dart';
import 'package:casachat/components/search_bar.dart';
import 'package:casachat/screens/login.dart';
import 'package:casachat/services/auth.dart';
import 'package:casachat/utils/colors.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  final String user;
  final String type;
  final String userName;

  const LandingPage({
    super.key,
    required this.user,
    required this.type,
    required this.userName,
  });

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  final landlordUrl = Uri.parse('https://casamax.co.zw/profile.php');
  final studentUrl = Uri.parse('https://casamax.co.zw');

  @override
  Widget build(BuildContext context) {
    Future<void> logOutFunction() async {
      var loggedOut = await logOut();
      if (loggedOut == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const LoginPage()));
      }
    }

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
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: CircleAvatar(
                  radius: 92,
                  backgroundColor: theme.colorScheme.secondary,
                  child: Center(
                    child: Text(
                      widget.userName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 110,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Logged In As:",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Text(
              textAlign: TextAlign.center,
              'CasaChat',
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 34),
            ),
            const SizedBox(
              height: 40,
            ),
            ListTile(
              onTap: logOutFunction,
              leading: const Icon(
                Icons.logout,
                color: accentColor,
                size: 24,
              ),
              title: const Text("Log Out"),
              selectedColor: accentColor.withOpacity(0.4),
              textColor: theme.colorScheme.onPrimary,
              titleTextStyle:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              focusColor: accentColor.withOpacity(0.4),
            ),
            ListTile(
              onTap: () async {
                final url = widget.type == 'student' ? studentUrl : landlordUrl;
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
              },
              leading: const Icon(
                Icons.home,
                color: accentColor,
                size: 24,
              ),
              title: widget.type == 'student'
                  ? Text("View Houses")
                  : Text('View My Profile'),
              selectedColor: accentColor.withOpacity(0.4),
              textColor: theme.colorScheme.onPrimary,
              titleTextStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              focusColor: accentColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // CustomSearchBar(),
          Expanded(
            flex: 2,
            child:  ChatList(
                        user: widget.user,
                        type: widget.type,
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
