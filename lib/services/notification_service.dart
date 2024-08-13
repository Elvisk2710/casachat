import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final List<String> _messages = [];

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tapped logic here
    if (response.payload != null) {
      debugPrint('notification payload: ${response.payload}');
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle the receipt of a notification here
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> showNotification(
      int id, String title, String body, String payload) async {
    if (!_messages.contains(body)) {
      _messages.add(body);
    }

    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      _messages,
      contentTitle: 'You have ${_messages.length} new messages',
      summaryText: 'New messages',
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'casamax_casachat_chat_app',
      'CasaChat',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: 'logoorange',
      playSound: true,
      enableVibration: true,
      styleInformation: inboxStyleInformation,
    );

    final DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      _messages.join('\n'),
      platformChannelSpecifics,
      payload: payload,
    );
  }


  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
