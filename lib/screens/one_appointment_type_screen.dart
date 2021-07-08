import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/generic_appointments_list.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';

import 'package:provider/provider.dart';

class OneAppointmentTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appointmentsModel,
      child: Consumer<AppointmentGroupsModel>(
          builder: (context, appGroupModel, child) {
            return  Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black54,
                title: Text(
                    appGroupModel.isEditing ? "Modifica Appuntamento (Gruppo)" :
                    "Appuntamento (Gruppo)"
                ),

                actions: [
                  appGroupModel.isEditing ?
                    // form confirm button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Text("...todo..."),
                    ) :

                    // normal screen actions
                    Text("...todo..."),
                ],
              ),


              body: appGroupModel.isEditing ?
                Text("...todo...") :
                _AppointmentGroupReadOnly(appGroupModel.currentAppointmentGroup!),

              bottomNavigationBar: MyBottomBar(),
            );
          }
      ),
    );
  }
}

class _AppointmentGroupReadOnly extends StatelessWidget {

  AppointmentGroup appointmentGroup;

  _AppointmentGroupReadOnly(this.appointmentGroup);

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