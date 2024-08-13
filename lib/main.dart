import 'package:casachat/services/changeNotifier.dart';
import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:casachat/screens/splashScreen.dart';
import 'package:casachat/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatNotifier(),
      child: MyApp(),
    ),
  );
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
      navigatorKey: NotificationService.navigatorKey,
    );
  }
}
