import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:provider/provider.dart';

/// The list with all [AppointmentInstance]s.
class PeriodicalAppointmentsList extends StatelessWidget {

  late AppointmentsDBWorker appointmentsDBWorker;

  AllMedicinesList() {
    // load all the medicines
    appointmentsDBWorker = AppointmentsDBWorker();
    appointmentsModel.loadData(appointmentsDBWorker);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: appointmentsModel,
      child: Consumer<AppointmentsModel>(
        builder: (context, appModel, child){

          // if model is still loading, I display a loading icon
          if (appModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          // if list is empty, I display a proper message as list item
          if (appModel.appointments.length == 0) {
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

          // regular list
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                itemCount: appModel.appointments.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _PeriodicalAppointmentsListItem(
                      appointment:
                        appModel.appointments[index]
                  );
                }
            ),
          );
        },
      ),
    );
  }
}

class _PeriodicalAppointmentsListItem extends StatelessWidget {

  late Appointment appointment;

  _PeriodicalAppointmentsListItem({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Text(appointment.name ?? "nessun nome");
  }
}
