import 'package:flutter/cupertino.dart';

abstract class Model extends ChangeNotifier {

  notify() {
    notifyListeners();
  }
}