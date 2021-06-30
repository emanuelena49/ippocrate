import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBottomBar extends StatefulWidget {
  @override
  _MyBottomBarState createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {

  int currIndex = 0;

  @override
  Widget build(BuildContext context) {

    Color color = Colors.green;

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
      currentIndex: currIndex,
      showUnselectedLabels: true,
      onTap: (index) {
          setState(() {
            currIndex = index;
          });
      },
    );
  }
}