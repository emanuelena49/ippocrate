import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyNotifier {

  bool isInit = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late final NotificationDetails platformChannelSpecifics;

  initNotifier() async {

    // ------------------------------------------------------------
    // init time zones
    tz.initializeTimeZones();

    // ------------------------------------------------------------
    // init notifier

    flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    /*
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings();*/

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        // iOS: initializationSettingsIOS,
        // macOS: initializationSettingsMacOS
    );
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: handleNotification);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: false);

    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    isInit = true;
  }

  Future handleNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  sampleNotification() async {

    if (!isInit) {
      throw Exception("Can't display a notification if notifier is not init");
    }

    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  sampleScheduledNotification() async {

    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 15)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled notification'
    );
  }

}