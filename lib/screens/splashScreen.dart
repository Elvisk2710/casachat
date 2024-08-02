import 'package:casachat/components/onLoading/onboarding_screens.dart';
import 'package:casachat/screens/login.dart';
import 'package:casachat/utils/colors.dart';
import 'package:casachat/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../components/onLoading/intro_page1.dart';
import '../components/onLoading/intro_page2.dart';
import '../components/onLoading/intro_page3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.dart';
import 'landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Color _backgroundColor = primaryColor;
  Duration _animationDuration = Duration(seconds: 3);
  List<Color> _colors = [primaryColor, secondaryColor, accentColor];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _startAnimation();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(
        Duration(seconds: 2)); // Simulate a delay for the splash screen

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    String? token = prefs.getString('jwt');

    if (hasSeenIntro) {
      if (token != null && !JwtDecoder.isExpired(token)) {
        // Valid token
        String? userId = getUserIdFromToken(token, "user_id");
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LandingPage(user: userId)),
          );
          return;
        }
      }
      // Intro seen but invalid or no token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Intro not seen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OnBoardingPage(
                  introPage1: IntroPage1(),
                  introPage2: IntroPage2(),
                  introPage3: IntroPage3(),
                )),
      );
    }
  }

  void _startAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      _changeBackgroundColor();
    });
  }

  void _changeBackgroundColor() {
    if (mounted) {
      setState(() {
        _backgroundColor = _colors[_colorIndex];
      });
      _colorIndex = (_colorIndex + 1) % _colors.length;
      Future.delayed(_animationDuration, _changeBackgroundColor);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary,
              theme.colorScheme.primary,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Images.lightLogo,
              width: 140,
            ),
          ],
        ),
      ),
    );
  }
}
