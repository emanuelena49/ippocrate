import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';

Future resetTodayIntakes(BuildContext context, MedicineIntake medicineIntake, ) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){
        return AlertDialog(
          title: Text("Resetta assunzioni di oggi"),
          content: Text(
              "Sei sicuro di voler resettare le assuzioni di oggi "
                  "per il medicinale ${medicineIntake.medicine.name}?"
          ),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(inAlertContext).pop();
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {

                // reset the intakes
                medicineIntake.resetIntakes();
                var db = MedicineIntakesDBWorker();
                await db.update(medicineIntake);

                // notify the model
                medicineIntakesModel.notify();

                // close the poupup
                Navigator.of(inAlertContext).pop();

                // show confirm snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.black54,
                    duration: Duration(seconds: 2),
                    content: Text("Assunzioni di oggi resettate"),
                  ),
                );
              },
              child: Text("Si, Procedi"),
            ),
          ],
        );
      }
  );
}