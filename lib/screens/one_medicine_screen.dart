import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ippocrate/components/intake_frequency_input.dart';
import 'package:ippocrate/components/medicine_input.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/generate_intakes_from_medicine.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:provider/provider.dart';

class OneMedicineScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: medicinesModel,
        child: Consumer<MedicinesModel>(
          builder: (context, notesModel, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black54,
                title: Text(
                  medicinesModel.isNew ?
                    "Nuovo Medicinale" :
                    medicinesModel.isEditing ?
                        "Modifica Medicinale" :
                        "Medicinale"
                ),
                actions: [
                  medicinesModel.isEditing ?
                      // form confirm button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: MedicineFormSubmitButton(),
                      ) :

                      // normal screen actions
                      IconButton(
                        icon: Icon(Icons.more),
                        onPressed: () {},
                      )
                ],
              ),
              body: MedicineForm(),
            );
          }
        )
    );
  }
}



