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

Future deleteAppointment(BuildContext context,
    AppointmentInstance appointmentInstance, ) async {

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){

        String text;
        String when = getWhenAppointment(appointmentInstance);

        text = "Sei sicuro di voler eliminare l'appuntamento "
            "${appointmentInstance.appointment.name} ";

        if (when=="OGGI" || when=="DOMANI") {
          text += " di $when";
        } else {
          text += " del $when";
        }

        text += "?";

        return AlertDialog(
          title: Text("Rimuovi appuntamento"),
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

                // get list of appointments of this type (need later)
                List<AppointmentInstance> groupAppInstances = searchAppointmentInstances(
                    searchOptions: AppointmentsSearchOptions(
                        types: [appointmentInstance.appointment]
                    )
                );

                // delete the appointment
                var appInstDb = AppointmentInstancesDBWorker();
                await appInstDb.delete(appointmentInstance.id!);

                // close the poupup
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Appuntamento eliminato"),
                  ),
                );

                // delete all the appointment notifications
                NotificationsModel.instance.removeAllNotifications(
                    NotificationSubject.fromObj(appointmentInstance)
                );

                var appGroupDb = AppointmentGroupsDBWorker();

                // if appointment is the last of the group, remove also the group
                if (groupAppInstances.length<=1) {
                  await appGroupDb.delete(appointmentInstance.appointment.id!);
                }

                appointmentsInstancesModel.loadData(appInstDb);

                // (reload even appointments types)
                appointmentGroupsModel.loadData(appGroupDb);
              },
              child: Text("Si, Elimina"),
            ),
          ],
        );
      }
  );
}