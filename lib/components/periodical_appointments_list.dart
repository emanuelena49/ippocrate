import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';

/// The list with all [AppointmentInstance]s.
class PeriodicalAppointmentsList extends StatelessWidget {

  late AppointmentsDBWorker appointmentsDBWorker;

  PeriodicalAppointmentsList() {
    // load all the medicines
    appointmentsDBWorker = AppointmentsDBWorker();
    appointmentsModel.loadData(appointmentsDBWorker);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: appointmentsModel,
      child: ChangeNotifierProvider.value(
        value: incomingAppointmentsModel,
        child: Consumer2<AppointmentsModel, IncomingAppointmentsModel>(
          builder: (context, appModel, incAppModel, child){

            // if model is still loading, I display a loading icon
            if (appModel.loading || incAppModel.loading) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator()
                ],
              );
            }

            List periodicals = appModel.getPeriodical();

            // if list is empty, I display a proper message as list item
            if (periodicals.length == 0) {
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(50),
                    child: Text(
                      "Nessun appuntamento periodico trovato",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  )
                ],
              );
            }

            // distinguish already ok (it exists an incoming) and
            // not booked

            List<Map> bookedAppointments = [];
            List<Map> notBookedAppointments = [];
            var today = getTodayDate();

            periodicals.forEach((appointment) {

              // look if have I got a next and a prev
              var next = getNextAppointmentInstance(appointment, today);
              var prev = getPrevAppointmentInstance(appointment,
                    today.subtract(Duration(days: 1)));

              // insert it in one or the other list (booked or not)
              if (next==null) {
                notBookedAppointments.add({
                  "appointment": appointment,
                  "nextInstance": null,
                  "precInstance": prev,
                });
              } else {
                bookedAppointments.add({
                  "appointment": appointment,
                  "nextInstance": next,
                  "prevInstance": prev,
                });
              }
            });

            List outputList = notBookedAppointments + bookedAppointments;

            // regular list
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                  itemCount: outputList.length,
                  itemBuilder: (context, index) {

                    // single item of the list
                    return _PeriodicalAppointmentsListItem(
                      appointment: outputList[index]["appointment"],
                      nextInstance: outputList[index]["nextInstance"],
                      prevInstance: outputList[index]["prevInstance"]
                    );
                  }
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PeriodicalAppointmentsListItem extends StatelessWidget {

  late Appointment appointment;
  AppointmentInstance? nextInstance, prevInstance;

  _PeriodicalAppointmentsListItem({
    required this.appointment, this.nextInstance, this.prevInstance });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: nextInstance==null ? Colors.lightBlueAccent : Colors.white54,

      child: GestureDetector(
        onTap: () {
          // todo: create and load page
        },
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: .22,
          secondaryActions: [

            IconSlideAction(
              caption: "Gestisci",
              color: Colors.green,
              icon: Icons.list_sharp,
              onTap: (){
                // todo: create and load page
              },
            ),
            // edit & delete
            IconSlideAction(
              caption: "Modifica",
              color: Colors.yellow,
              icon: Icons.edit,
              onTap: (){
                // todo: create and load page
              },
            ),
            IconSlideAction(
              caption: "Elimina tutti",
              color: Colors.red,
              icon: Icons.delete,
              onTap: (){
                // todo: create and load popup
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.name,
                  style: Theme.of(context).textTheme.headline5,
                ),

                SizedBox(height: 25,),

                Container(
                  height: 45,
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // display frequency
                              Text(getPeriodicalAppointmentFrequency(appointment)),

                              // eventually display last time
                              prevInstance!=null ?
                                Text("(${getPastAppointmentTime(prevInstance!)})") :
                                SizedBox(height: 0,)
                            ],
                          )
                      ),
                      Expanded(
                          child: nextInstance!=null ?
                              Text(
                                  "Prossimo prenotato:\n${getWhenAppointment(nextInstance!)}"
                              ) :
                              ElevatedButton(
                                  onPressed: () {
                                    incomingAppointmentsModel.viewAppointment(
                                        AppointmentInstance(
                                            appointment: appointment,
                                            dateTime: DateTime.now()
                                        ), edit: true);
                                    screensModel.loadScreen(context,
                                        Screen.APPOINTMENTS_ONE);
                                  },
                                  child: Text("prenota ora"),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black54,)
                              )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
