import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';

import 'delete_appointment_instance.dart';

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
            incomingAppointmentsModel.loadData(appointmentsIntancesDb);
            break;
          case "mark-as-undone":
            appointmentInstance.done = false;
            var appointmentsIntancesDb = AppointmentInstancesDBWorker();
            await appointmentsIntancesDb.update(appointmentInstance);
            incomingAppointmentsModel.loadData(appointmentsIntancesDb);
            break;
          case "edit":
            incomingAppointmentsModel.viewAppointment(
                appointmentInstance, edit: true);
            incomingAppointmentsModel.notify();
            break;
          case "delete":
            await deleteAppointment(context, appointmentInstance);
            screensModel.back(context);
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

    appointmentInstance = incomingAppointmentsModel.currentAppointment!;

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
        isMaybeMissed ? Colors.red : Colors.blue,
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

            isDone ? Text("(già fatto)") : isMaybeMissed ?
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
                    child: Text("VEDI TUTTI"),
                    onPressed: () {
                      appointmentsModel.viewAppointmentGroup(
                          appointmentInstance.appointment);
                      screensModel.loadScreen(context,
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
                      incomingAppointmentsModel.viewAppointment(
                          appointmentInstance, edit: true);
                      incomingAppointmentsModel.notify();
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
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text("Note: ", style: Theme.of(context).textTheme.headline6,),
      children: [
        appointmentInstance.notes != null ?
        Column(
            children: [

              Text(
                  appointmentInstance.notes!,
                  style: Theme.of(context).textTheme.bodyText2
              ),

              ElevatedButton(
                  onPressed: () {
                    incomingAppointmentsModel.viewAppointment(
                        appointmentInstance, edit: true);
                    incomingAppointmentsModel.notify();
                  },
                  child: Text("modifica")
              )
            ]
        ) :
        Column(
          children: [
            Text("Nessuna nota intserita"),
            ElevatedButton(
                onPressed: () {
                  incomingAppointmentsModel.viewAppointment(
                      appointmentInstance, edit: true);
                  incomingAppointmentsModel.notify();
                },
                child: Text("aggiungi nota"),
            )
          ],
        )
      ],
    );
  }
}

