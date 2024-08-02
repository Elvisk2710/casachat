import 'dart:convert';
import 'package:casachat/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:casachat/screens/landing_page.dart';
import 'package:casachat/utils/colors.dart';
import 'package:casachat/utils/images.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isTokenValid = false;

  @override
  void initState() {
    super.initState();
    _checkJwtToken();
  }

  Future<void> _checkJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token != null && !JwtDecoder.isExpired(token)) {
      String? userId = getUserIdFromToken(token,"user_id");
      if (userId != null) {
        _isTokenValid = true;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LandingPage(user: userId)),
        );
      }else{
        setState(() {
          _isTokenValid = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      setState(() {
        _isTokenValid = false;
      });
    }
  }



  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // login function
  void _login() async {
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();
    if (username != '' || password != '') {
      try {
        final response = await http.get(Uri.parse(
            'http://192.168.1.13:81/casamax/homerunphp/loginscript.php?email=${username}&password=${password}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final token = data['token'];
            // Save token to shared preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt', token);

            // Decode token to get user data
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LandingPage(user: decodedToken['user_id'])),
            );
          } else {
            print('Error: ${data['message']}');
          }
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print("no inputs");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 80),
          Image.asset(
            theme.brightness == Brightness.dark
                ? Images.lightLogo
                : Images.darkLogo,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 60),
          const Center(
            child: Text(
              'Welcome to CasaChat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Chat to landlords or students for your\n off campus student housing needs',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: accentColor),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                labelText: 'Username...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: SizedBox(
              width: 180,
              child: GestureDetector(
                onTap: _login,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: theme.colorScheme.onPrimary,
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42.0,
                      vertical: 8,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 180),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't Have An Account?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the registration page
                },
                child: Text(
                  "Register Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
