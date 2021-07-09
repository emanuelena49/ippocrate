import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/medicines_intakes_list.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/medicines_list.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';
import 'package:ippocrate/services/datetime.dart';



class MedicinesScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.blueGrey,

          title: Text("Medicinali"),

          bottom: TabBar(
            tabs: [
              Tab(text: "DA PRENDERE",),
              Tab(text: "TUTTI", ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("INSERISCI"),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green
                  ),
                  onPressed: () {
                    DateTime today = getTodayDate();
                    medicinesModel.viewMedicine(
                        Medicine(
                            name: "", startDate: today,
                            endDate: today.add(Duration(days: 14))
                        ), edit: true
                    );
                    screensModel.loadScreen(context, Screen.MEDICINES_ONE);
                  }
              ),
            )
          ],
        ),

        body: TabBarView(
          children: [
            // daily intakes tab
            MedicineIntakesList(),

            // all medicines
            AllMedicinesList(),

          ],
        ),

        bottomNavigationBar: MyBottomBar(),
      ),
    );

  }
}



















