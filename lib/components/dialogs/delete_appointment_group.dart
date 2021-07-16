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
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/notifications/notifications.dart';
import 'package:ippocrate/services/notifications/notifications_logic.dart';
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

                // get all the instances (i need them to remove notifications later)
                List<AppointmentInstance> appInstances = searchAppointmentInstances(
                  searchOptions: AppointmentsSearchOptions(
                      types: [appointmentGroup]
                  )
                );

                // delete the appointment group (and ON CASCADE the instances)
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

                // remove all notifications of every appointment instance
                appInstances.forEach((i) {
                  NotificationsModel.instance.removeAllNotifications(
                      NotificationSubject.fromObj(i));
                });

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