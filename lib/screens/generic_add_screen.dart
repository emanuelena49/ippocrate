import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';

class GenericAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi"),
      ),
      body: Text("..."),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}