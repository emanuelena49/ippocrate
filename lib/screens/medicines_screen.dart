import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/medicines_list.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';



class MedicinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Medicinali"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                medicinesModel.startNewMedicineCreation();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OneMedicineScreen()),
                );
              }
          )
        ],
      ),
      body: AllMedicineList(),
    );
  }
}
















