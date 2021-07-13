
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/notifications.dart';
import 'package:ippocrate/screens/medicines_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'common/screens_manager.dart';
import 'common/utils.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory docsDir = await getApplicationDocumentsDirectory();
  utils.docsDir = docsDir;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  sampleNotify() async {
    MyNotifier notifier = MyNotifier();
    await notifier.initNotifier();
    notifier.sampleNotification();

    notifier.sampleScheduledNotification();
  }

  @override
  Widget build(BuildContext context) {
    // if (true) return MedicinesScreen();

    sampleNotify();

    return MaterialApp(
      initialRoute: initialRoute,
      routes: routes,
      theme: ThemeData(
        primaryColor: Colors.blueGrey.shade800
      )
    );
  }
}