import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/dialogs/delete_appointment_instance.dart';
import 'package:ippocrate/components/forms/appointment_notifications_input.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';


class AppointmentMenuButton extends StatelessWidget {
  AppointmentInstance appointmentInstance;

  AppointmentMenuButton({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {

    bool isDone = appointmentInstance.done;
    bool isMaybeMissed = appointmentInstance.isMaybeMissed;

    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      iconSize: 32,
      onSelected: (selection) async {
        switch(selection) {
          case "mark-as-done":
            appointmentInstance.done = true;
            var appointmentsIntancesDb = AppointmentInstancesDBWorker();
            await appointmentsIntancesDb.update(appointmentInstance);
            appointmentsInstancesModel.loadData(appointmentsIntancesDb);
            break;
          case "mark-as-undone":
            appointmentInstance.done = false;
            var appointmentsIntancesDb = AppointmentInstancesDBWorker();
            await appointmentsIntancesDb.update(appointmentInstance);
            appointmentsInstancesModel.loadData(appointmentsIntancesDb);
            break;
          case "edit":
            appointmentsInstancesModel.viewAppointment(
                appointmentInstance, edit: true);
            appointmentsInstancesModel.notify();
            break;
          case "delete":
            await deleteAppointment(context, appointmentInstance);
            screensManager.back(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem> [

        // mark as done/undone
        isDone ?
          PopupMenuItem(
            value: "mark-as-undone",
            child: Text("Segna come da fare"),
          ) :
          PopupMenuItem(
            value: "mark-as-done",
            child: Text("Segna come fatto"),
          ),

        PopupMenuItem(
          value: "edit",
          child: Text("Modifica"),
        ),
        PopupMenuItem(
          value: "delete",
          child: Text("Elimina"),
        ),
      ],
    );
  }
}

class AppointmentReadOnly extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  @override
  Widget build(BuildContext context) {

    appointmentInstance = appointmentsInstancesModel.currentAppointment!;

    return ListView(
      children: [
        // Appointment heading
        _AppointmentHeading(appointmentInstance: appointmentInstance),
        SizedBox(height: 25,),

        // Appointment notes
        _AppointmentNotes(appointmentInstance: appointmentInstance),
        SizedBox(height: 25,),

        // todo: Appointment notifications
        SizedBox(height: 25,),
        ListTile(
          title: AppointmentNotificationInput(
            appointmentInstance: appointmentInstance
          ),
        )
      ],
    );
  }
}

class _AppointmentHeading extends StatelessWidget {

  AppointmentInstance appointmentInstance;

  _AppointmentHeading({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {

    bool isDone = appointmentInstance.done;
    bool isMaybeMissed = appointmentInstance.isMaybeMissed;

    return Card(
      elevation: 4,
      color: isDone ? Colors.white54 :
        isMaybeMissed ? Colors.red : Colors.lightBlueAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            // appointment type/purpose/name
            Text(
              this.appointmentInstance.appointment.name,
              style: Theme.of(context).textTheme.headline5,
            ),

            // appointment date and time
            Text(
              getWhenAppointment(appointmentInstance),
              style: Theme.of(context).textTheme.subtitle2,
            ),

            isDone ? Text("(gi?? fatto)") : isMaybeMissed ?
              Text("FORSE MANCATO!") : SizedBox(height: 0,),

            SizedBox(height: 25,),

            Text(
              !appointmentInstance.appointment.isPeriodic() ?
              "NON PERIODICO" :
              "PERIODICO (${getPeriodicalAppointmentFrequency(
                  appointmentInstance.appointment)})",
              style: Theme.of(context).textTheme.subtitle1,
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // eventually display a "view all" button for periodical
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text("VEDI GRUPPO"),
                    onPressed: () {
                      appointmentGroupsModel.viewAppointmentGroup(
                          appointmentInstance.appointment);
                      screensManager.loadScreen(context,
                          Screen.APPOINTMENTS_GROUP_ONE);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black54,)
                  ),
                ),
                // quick button to create a new appointment of the same type
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text("PRENOTA UN ALTRO"),
                    onPressed: () {
                      appointmentsInstancesModel.viewAppointment(
                          appointmentInstance, edit: true);
                      appointmentsInstancesModel.notify();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black54,)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentNotes extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  _AppointmentNotes({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: appointmentInstance.notes != null ?
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Note: ", style: Theme.of(context).textTheme.headline6,),
            Text(
                appointmentInstance.notes!,
                style: Theme.of(context).textTheme.bodyText2
            ),
          ]
      ) :
      Column(
        children: [
          Text("Nessuna nota intserita"),
          ElevatedButton(
            onPressed: () {
              appointmentsInstancesModel.viewAppointment(
                  appointmentInstance, edit: true);
              appointmentsInstancesModel.notify();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black54
            ),
            child: Text("aggiungi nota"),
          )
        ],
      ),
    );
  }
}

