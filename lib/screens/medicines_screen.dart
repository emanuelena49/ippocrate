import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MedicinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Ippocrate"),
      ),
      body: MedicineDisplayer(),
    );
  }
}

class MedicineDisplayer extends StatelessWidget {

  MedicineDisplayer() {

  }

  @override
  Widget build(BuildContext context) {
    return Text("prova");
  }
}