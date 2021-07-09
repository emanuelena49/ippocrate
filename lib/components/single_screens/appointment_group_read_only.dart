import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/dialogs/delete_appointment_group.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/generic_appointments_list.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';

class AppointmentGroupMenuItem extends StatelessWidget {
  AppointmentGroup appointmentGroup;

  AppointmentGroupMenuItem({required this.appointmentGroup});

  @override
  Widget build(BuildContext context) {

    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      iconSize: 32,
      onSelected: (selection) async {
        switch(selection) {
          case "edit":
            appointmentsModel.viewAppointmentGroup(appointmentGroup, edit: true);
            appointmentsModel.notify();
            break;
          case "delete":
            await deleteAppointmentGroup(context, appointmentGroup);
            screensModel.back(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem> [
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

class AppointmentGroupReadOnly extends StatelessWidget {

  AppointmentGroup appointmentGroup;

  AppointmentGroupReadOnly(this.appointmentGroup);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AppointmentGroupHeading(appointmentGroup),

        // list of appointments instances of this type
        Expanded(
            child: GenericAppointmentsList(
              searchOptions: AppointmentsSearchOptions(
                types: [appointmentGroup],
              ),
              sortingOptions: AppointmentsSortingOptions.PRIORITY,
            )
        )
      ],
    );
  }
}

class _AppointmentGroupHeading extends StatelessWidget {

  AppointmentGroup appointmentGroup;

  _AppointmentGroupHeading(this.appointmentGroup);

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();
    var nextInstance = getNextAppointmentInstance(appointmentGroup, today);
    var prevInstance = getPrevAppointmentInstance(appointmentGroup,
        today.subtract(Duration(days: 1)));

    return Card(
      elevation: 4,
      color: Colors.lightBlueAccent,
      // color: nextInstance!=null ? Colors.white54 : Colors.lightBlueAccent,

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            // appointment type/purpose/name
            Text(
              appointmentGroup.name,
              style: Theme.of(context).textTheme.headline5,
            ),

            SizedBox(height: 25,),

            Text(
              !appointmentGroup.isPeriodic() ?
              "NON PERIODICO" :
              "PERIODICO (${getPeriodicalAppointmentFrequency(appointmentGroup)})",
              style: Theme.of(context).textTheme.subtitle1,
            ),

            if (prevInstance!=null)
              Text("Ultima volta: ${getWhenAppointment(prevInstance)}"),

            if (nextInstance!=null)
              Text("Prossimo: ${getWhenAppointment(nextInstance)}"),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // eventually display a "view all" button for periodical
                // quick button to create a new appointment of the same type
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      child: Text("PRENOTA UN ALTRO"),
                      onPressed: () {
                        incomingAppointmentsModel.viewAppointment(
                            AppointmentInstance(
                                appointment: appointmentGroup,
                                dateTime: DateTime.now(),
                            ), edit: true
                        );
                        screensModel.loadScreen(context, Screen.APPOINTMENTS_ONE);
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