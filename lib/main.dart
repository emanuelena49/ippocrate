
import 'dart:io';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    // if (true) return MedicinesScreen();
    return MaterialApp(
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}