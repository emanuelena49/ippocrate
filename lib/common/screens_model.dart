import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/screens/appointments_screen.dart';
import 'package:ippocrate/screens/generic_add_screen.dart';
import 'package:ippocrate/screens/home_screen.dart';
import 'package:ippocrate/screens/medicines_screen.dart';
import 'package:ippocrate/screens/one_appointment_screen.dart';
import 'package:ippocrate/screens/one_appointment_type_screen.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';
import 'package:path/path.dart';


enum Screen {
  HOME, GENERIC_ADD,
  APPOINTMENTS, APPOINTMENTS_ONE, APPOINTMENTS_GROUP_ONE,
  MEDICINES, MEDICINES_ONE
}

extension ScreenExtention on Screen {
  String get route {
    switch(this) {
      case Screen.HOME:
        return "/";
      case Screen.APPOINTMENTS:
        return "/appointments";
      case Screen.APPOINTMENTS_ONE:
        return "/appointments/group/one";
      case Screen.APPOINTMENTS_GROUP_ONE:
        return "/appointments/group";
      case Screen.MEDICINES:
        return "/medicines";
      case Screen.MEDICINES_ONE:
        return "/medicines/one";
      case Screen.GENERIC_ADD:
        return "/generic_add";
    }
  }

  int get level {
    var pieces =  this.route.split("/");

    var pieces2 = [];
    pieces.forEach((element) {
      if (element!="") pieces2.add(element);
    });

    return pieces2.length;
  }

  Screen getFirstCommonParent(Screen s) {
    List thisPath = this.route.split("/");
    List sPath = this.route.split("/");

    int i=0;
    bool ok=true;
    String commonRoute = "";
    while (i<thisPath.length && i<sPath.length && ok) {
      if (thisPath[i] == sPath[i]) {
        i++;
        commonRoute += "/" + thisPath[i];
      } else {
        ok=false;
      }
    }

    if (i==0) {
      return screenFromRoute("/");
    } else {
      return screenFromRoute(commonRoute);
    }
  }
}

Screen screenFromRoute(String route) {
  for (var v in Screen.values) {
    if (v.route == route) {
      return v;
    }
  }

  throw Exception("The screen with route $route doesn't exist");
}

var routes = {

  Screen.HOME.route: (Buildcontext) => HomeScreen(),

  Screen.APPOINTMENTS.route: (context) => AppointmentsScreen(),
  Screen.APPOINTMENTS_GROUP_ONE.route: (context) => OneAppointmentTypeScreen(),
  Screen.APPOINTMENTS_ONE.route: (context) => OneAppointmentScreen(),

  Screen.MEDICINES.route: (context) => MedicinesScreen(),
  Screen.MEDICINES_ONE.route: (context) => OneMedicineScreen(),

  Screen.GENERIC_ADD.route: (context) => GenericAddScreen(),
};

var initialRoute = Screen.HOME.route;

class ScreensModel extends ChangeNotifier {

  Screen currentScreen = Screen.HOME;

  /// Load a certain route
  loadScreen(BuildContext context, Screen screen) {

    Navigator.popUntil(context, (route) {
      currentScreen = screenFromRoute(route.settings.name!);
      if (currentScreen.level >= screen.level) {
        return false;
      } else {
        return true;
      }
    });

    Navigator.of(context).pushNamed(screen.route);
    currentScreen = screen;
    notifyListeners();
  }

  /// back to subpage
  back(BuildContext context) {

    if (Navigator.canPop(context)){
      Navigator.of(context).pop();
      String? oldRoute = ModalRoute.of(context)!.settings.name;
      currentScreen = screenFromRoute(oldRoute!);
      notifyListeners();
    } else {
      debugPrint("Warning, called an unmakable pop");
    }
  }
}

ScreensModel screensModel = ScreensModel();