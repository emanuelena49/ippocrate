import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:provider/provider.dart';

var _screensIndexes = {
  Screen.HOME: 0,
  Screen.APPOINTMENTS: 1,
  Screen.APPOINTMENTS_ONE: 1,
  Screen.MEDICINES: 2,
  Screen.MEDICINES_ONE: 2,
  Screen.GENERIC_ADD: 3,
};

_getScreenFromIndex(int index) {
  for (var screen in _screensIndexes.keys) {
    if (_screensIndexes[screen] == index) {
      return screen;
    }
  }

  throw Exception("Index $index is associated to no Screen");
}

class MyBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: screensModel,
        child: Consumer<ScreensModel>(
          builder: (context, screensModel, child) {

            Color color = Colors.green;
            int currentIndex = _screensIndexes[screensModel.currentScreen]!;

            return BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "HOME",
                  backgroundColor: color,
                ),

                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icons/appointment.png')),
                  label: "APPUNTAMENTI",
                  backgroundColor: color,

                ),

                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/icons/medicine.png')),
                  label: "MEDICINALI",
                  backgroundColor: color,
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "AGGIUNGI",
                  backgroundColor: color,
                ),
              ],
              currentIndex: _screensIndexes[screensModel.currentScreen]!,
              showUnselectedLabels: true,
              onTap: (index) {
                Screen screen = _getScreenFromIndex(index);
                screensModel.loadScreen(context, screen);
              },
            );
          }
        )
    );
  }
}