import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/forms/medicine_input.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/single_screens/medicine_read_only.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:provider/provider.dart';

class OneMedicineScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: medicinesModel,
        child: ChangeNotifierProvider.value(
          value: medicineIntakesModel,
          child: Consumer2<MedicinesModel, MedicineIntakesModel>(
            builder: (context, medModel, intakesModel, child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black54,
                  title: Text(
                      medModel.isNew ?
                      "Nuovo Medicinale" :
                      medModel.isEditing ?
                          "Modifica Medicinale" :
                          "Medicinale"
                  ),
                  actions: [
                    medModel.isEditing ?
                        // form confirm button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          child: MedicineFormSubmitButton(),
                        ) :

                        // normal screen actions
                        MedicineMenuButton(medicine: medModel.currentMedicine!)
                  ],
                ),


                body: medModel.isEditing ?
                  MedicineForm() :
                  MedicineReadOnly(),

                bottomNavigationBar: MyBottomBar(),
              );
            }
          ),
        )
    );
  }
}



