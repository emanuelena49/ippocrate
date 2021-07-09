import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';

Future deleteAppointmentGroup(BuildContext context,
    AppointmentGroup appointmentGroup, ) async {

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){

        String text = "Sei sicuro di voler eliminare tutti gli appuntamenti "
            "di nome \"${appointmentGroup.name}\"?";

        return AlertDialog(
          title: Text("Rimuovi gruppo appuntamenti"),
          content: Text(text),
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
                var appDb = AppointmentGroupsDBWorker();
                await appDb.delete(appointmentGroup.id!);

                // close the poupup
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Gruppo appuntamenti eliminato"),
                  ),
                );

                // (reload everything)
                appointmentsInstancesModel.loadData(AppointmentInstancesDBWorker());
                appointmentGroupsModel.loadData(appDb);
              },
              child: Text("Si, Elimina"),
            ),
          ],
        );
      }
  );
}