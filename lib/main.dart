import 'package:casachat/components/onLoading/onboarding_screens.dart';
import 'package:casachat/screens/splashScreen.dart';
import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';
import 'components/onLoading/intro_page1.dart';
import 'components/onLoading/intro_page2.dart';
import 'components/onLoading/intro_page3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CasaChat',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}



