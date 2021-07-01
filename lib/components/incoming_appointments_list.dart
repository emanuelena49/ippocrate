import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:provider/provider.dart';


/// The list with all [AppointmentInstance]s.
class IncomingAppointmentsList extends StatelessWidget {

  late AppointmentInstancesDBWorker appointmentInstancesDb;

  AllMedicinesList() {
    // load all the medicines
    appointmentInstancesDb = AppointmentInstancesDBWorker();
    incomingAppointmentsModel.loadData(appointmentInstancesDb);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: incomingAppointmentsModel,
      child: Consumer<IncomingAppointmentsModel>(
        builder: (context, incAppModel, child){

          // if model is still loading, I display a loading icon
          if (incAppModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          // if list is empty, I display a proper message as list item
          if (incAppModel.incomingAppointments.length == 0) {
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    "Nessun appuntamento imminente",
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
                itemCount: incAppModel.incomingAppointments.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _IncomingAppointmentsListItem(
                      appointmentInstance:
                        incAppModel.incomingAppointments[index]
                  );
                }
            ),
          );
        },
      ),
    );
  }
}

class _IncomingAppointmentsListItem extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  _IncomingAppointmentsListItem({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {
    return Text(appointmentInstance.appointment.name ?? "nessun nome");
  }
}
