import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
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

            periodicals.forEach((appointment) {

              // look if have I got a next
              var incAppointment;
              var incAppointments =
                incAppModel.getIncomingAppointments(type: appointment);

              if (incAppointments.length>0) {
                incAppointment = incAppointments.first;
              }

              // look if have I got a prec (reverse order)
              var pastAppointment;
              var pastAppointments =
                incAppModel.getPastAppointments(type: appointment);

              if (pastAppointments.length>0) {
                pastAppointment = pastAppointments.last;
              }

              // insert it in one or the other list (booked or not)
              if (incAppointment==null) {
                notBookedAppointments.add({
                  "appointment": appointment,
                  "nextInstance": null,
                  "precInstance": pastAppointment,
                });
              } else {
                bookedAppointments.add({
                  "appointment": appointment,
                  "nextInstance": incAppointment,
                  "precInstance": pastAppointment,
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
                      precInstance: outputList[index]["precInstance"]
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
  AppointmentInstance? nextInstance, precInstance;

  _PeriodicalAppointmentsListItem({
    required this.appointment, this.nextInstance, this.precInstance });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: nextInstance==null ? Colors.blue : Colors.white54,

      child: GestureDetector(
        onTap: () {

        },
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
                            precInstance!=null ?
                              Text("(${getPastAppointmentTime(precInstance!)})") :
                              SizedBox(height: 0,)
                          ],
                        )
                    ),
                    Expanded(
                        child: nextInstance!=null ?
                            Text(
                                "Prossimo:\n${getWhenAppointment(nextInstance!)}"
                            ) :
                            ElevatedButton(
                                onPressed: () {

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
    );
  }
}
