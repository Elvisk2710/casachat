import 'dart:convert';
import 'package:casachat/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:casachat/screens/landing_page.dart';
import 'package:casachat/utils/colors.dart';
import 'package:casachat/utils/images.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/custom_notifcation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isTokenValid = false;

  final landlordUrl = Uri.parse('https://casamax.co.zw/advertise/index.php');
  final studentUrl = Uri.parse('https://casamax.co.zw/signup.php');

  @override
  void initState() {
    super.initState();
    _checkJwtToken();
  }

  Future<void> _checkJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenStudent = prefs.getString('jwtStudent');
    String? tokenLandlord = prefs.getString('jwtLandlord');
    String? token;
    if (tokenStudent != null && !JwtDecoder.isExpired(tokenStudent)) {
      token = tokenStudent;
    } else if (tokenLandlord != null && !JwtDecoder.isExpired(tokenLandlord)) {
      token = tokenLandlord;
    }
    if (token != null && !JwtDecoder.isExpired(token)) {
      String? userId = getDataFromToken(token, "user_id");
      String? userType = getDataFromToken(token, "type");
      String? userName = getDataFromToken(token, "firstname");
      if (userId != null && userType != null && userName != null) {
        _isTokenValid = true;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LandingPage(
                    user: userId,
                    type: userType,
                    userName: userName,
                  )),
        );
      } else {
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
  final _usernameLandlordController = TextEditingController();
  final _passwordLandlordController = TextEditingController();
  // student login function
  void _login() async {
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();
    if (username != '' || password != '') {
      try {
        final response = await http.get(Uri.parse(
            'http://casamax.co.zw/homerunphp/loginscript.php?email=${username}&password=${password}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final token = data['token'];
            // Save token to shared preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwtStudent', token);

            // Decode token to get user data
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            showCustomNotification(context, "Logged In Successfully", false);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LandingPage(
                        user: decodedToken['user_id'],
                        type: decodedToken['type'],
                        userName: decodedToken['firstname'],
                      )),
            );
          } else {
            showCustomNotification(context, "${data['message']}", true);
          }
        } else {
          showCustomNotification(
              context, 'Error: ${response.statusCode}', true);
        }
      } catch (e) {
        showCustomNotification(context, 'Error: $e', true);
      }
    } else {
      showCustomNotification(context, 'Error: No Inputs Found', true);
    }
  }

  // landlord login
  void _landlordLogin() async {
    var username = _usernameLandlordController.text.trim();
    var password = _passwordLandlordController.text.trim();
    if (username != '' || password != '') {
      try {
        final response = await http.get(Uri.parse(
            'http://casamax.co.zw/homerunphp/homeownerloginscript.php?email=${username}&password=${password}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            final token = data['token'];
            // Save token to shared preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwtLandlord', token);

            // Decode token to get user data
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            showCustomNotification(context, "Logged In Successfully", false);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LandingPage(
                        user: decodedToken['user_id'],
                        type: decodedToken['type'],
                        userName: decodedToken['firstname'],
                      )),
            );
          } else {
            showCustomNotification(context, "${data['message']}", true);
          }
        } else {
          showCustomNotification(
              context, 'Error: ${response.statusCode}', true);
        }
      } catch (e) {
        showCustomNotification(context, 'Error: $e', true);
      }
    } else {
      showCustomNotification(context, 'Error: No Inputs Found', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  textAlign: TextAlign.end,
                  "CasaChat",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              indicatorColor: accentColor,
              labelColor: accentColor,
              tabs: [
                Tab(
                  text: "Student",
                  icon: Icon(
                    Icons.school_rounded,
                    color: accentColor,
                  ),
                ),
                Tab(
                  text: "Landlord",
                  icon: Icon(
                    Icons.home,
                    color: accentColor,
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView(
                children: <Widget>[
                  Image.asset(
                    theme.brightness == Brightness.dark
                        ? Images.lightLogo
                        : Images.darkLogo,
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Student Login',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        textAlign: TextAlign.center,
                        'Connect with Landlords Directly. Find Your Ideal Student Home.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        label: Text("Email"),
                        labelStyle:
                            TextStyle(color: theme.colorScheme.onPrimary),
                        hintText: 'Enter Your Email',
                        filled: true,
                        focusColor: Colors.grey[600],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      cursorColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _passwordController,
                      cursorColor: theme.colorScheme.onPrimary,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text("Password"),
                        labelStyle:
                            TextStyle(color: theme.colorScheme.onPrimary),
                        hintText: 'Enter your password',
                        filled: true,
                        focusColor: Colors.grey[600],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
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
                  const SizedBox(height: 60),
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
                        child: GestureDetector(
                          onTap: () async {
                            final url = studentUrl;
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
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ListView(
                children: <Widget>[
                  Image.asset(
                    theme.brightness == Brightness.dark
                        ? Images.lightLogo
                        : Images.darkLogo,
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Landlord Login',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        textAlign: TextAlign.center,
                        'Turn Your Space Into Income: Rent to Students Directly',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _usernameLandlordController,
                      decoration: InputDecoration(
                        label: Text("Email"),
                        labelStyle:
                            TextStyle(color: theme.colorScheme.onPrimary),
                        hintText: 'Enter Your Email',
                        filled: true,
                        focusColor: Colors.grey[600],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      cursorColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      controller: _passwordLandlordController,
                      cursorColor: theme.colorScheme.onPrimary,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text("Password"),
                        labelStyle:
                            TextStyle(color: theme.colorScheme.onPrimary),
                        hintText: 'Enter your password',
                        filled: true,
                        focusColor: Colors.grey[600],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: GestureDetector(
                        onTap: _landlordLogin,
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
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Advertise Your Boarding House!",
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
                        child: GestureDetector(
                          onTap: () async {
                            final url = landlordUrl;
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
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
