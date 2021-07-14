import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyNotifier {

  bool isInit = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late final NotificationDetails platformChannelSpecifics;
  int lastId=0;

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
        lastId, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
    lastId++;
  }

  sampleScheduledNotification(int s) async {

    // do NOT await, else when you close the application you stop
    // the process and the scheduled notification doesn't happen


    /*await*/ flutterLocalNotificationsPlugin.zonedSchedule(
        lastId,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(Duration(seconds: s)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled notification'
    );

    lastId++;
  }

  samplePendingNotifications() async {

    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    debugPrint(pendingNotificationRequests.map((notificationRequest) =>
        "${notificationRequest.id} ${notificationRequest.title}").toString());
  }

  sampleCancelNotification() async {
    // cancel the notification with id value of 2
    await flutterLocalNotificationsPlugin.cancel(2);
  }

  sampleCancelNotification2() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  sampleNotificationAppDetails() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    debugPrint(notificationAppLaunchDetails!=null ?
      notificationAppLaunchDetails.didNotificationLaunchApp.toString() :
      "false");
  }
}