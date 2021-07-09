import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';

Future deleteMedicine(BuildContext context, Medicine medicine, ) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){
        return AlertDialog(
          title: Text("Rimuovi medicinale"),
          content: Text("Sei sicuro di voler eliminare il medicinale ${medicine.name}?"),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(inAlertContext).pop();
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {

                // delete all intakes
                // (no need, i set ON DELETE CASCADE in SQL)

                // delete the medicine
                var medicineDb = MedicinesDBWorker();
                await medicineDb.delete(medicine.id!);

                // close the poupup
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Medicinale eliminato"),
                  ),
                );
                medicinesModel.loadData(medicineDb);

                // (reload even intakes)
                medicineIntakesModel.loadData(MedicineIntakesDBWorker());
              },
              child: Text("Si, Elimina"),
            ),
          ],
        );
      }
  );
}