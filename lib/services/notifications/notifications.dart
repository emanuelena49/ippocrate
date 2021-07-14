import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ippocrate/services/notifications/notifications_logic.dart';
import 'package:ippocrate/services/notifications/notifications_texts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsModel extends NotificationModelLogic {

  NotificationsModel._();
  static NotificationsModel instance = NotificationsModel._();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late NotificationDetails _platformChannelSpecifics;
  bool _initDone = false;

  @override
  addNotification(MyNotification notification, {bool notify: true, subjectAsObj}) async {

    // insert the notification in our local list (and generate a valid id)
    super.addNotification(notification);

    // ----------------------------------------------------------------
    // now, schedule it

    Duration offsetTime= DateTime.now().timeZoneOffset;

    tz.TZDateTime zonedTime = tz.TZDateTime.local(
        notification.dateTime.year,
        notification.dateTime.month,
        notification.dateTime.day,
        notification.dateTime.hour,
        notification.dateTime.minute,
    ).subtract(offsetTime);

    _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id!,
        getNotificationTitle(subjectAsObj),
        getNotificationContent(subjectAsObj),
        zonedTime,
        _platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: json.encode(notification.toMap())
    );

    // notify listeners
    if (notify) notifyListeners();
  }

  @override
  removeNotification(MyNotification notification, {bool notify: true}) async {

    // cancel it
    await _flutterLocalNotificationsPlugin.cancel(notification.id!);

    // remove from our local list
    super.removeNotification(notification);

    // notify listeners
    if (notify) notifyListeners();
  }

  @override
  init() async {

    // ------------------------------------------------------------
    // init time zones

    tz.initializeTimeZones();

    // ------------------------------------------------------------
    // init plugin notifier

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: handleNotification);

    // ------------------------------------------------------------
    // generate plugin single notification settings

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'ippocrate', 'Ippocrate',
            'Gestione appuntamenti medici e medicinali',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: false);

    _platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ------------------------------------------------------------
    // retrieve a list of pending notifications and add all them
    // to our Notification list

    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    // convert all ...
    notifications = pendingNotificationRequests.map((e) =>
        MyNotification.fromMap(json.decode(e.payload ?? "{}"))
    ).toList();

    // ... and then sort by id
    notifications.sort((a,b) => a.id!.compareTo(b.id!));

    // ------------------------------------------------------------
    // finally done

    _initDone = true;
  }

  Future handleNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }
}
