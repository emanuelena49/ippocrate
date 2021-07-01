import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:provider/provider.dart';


/// The list with all [AppointmentInstance]s.
class AllAppointmentsList extends StatelessWidget {

  late AppointmentInstancesDBWorker appointmentInstancesDb;

  AllAppointmentsList() {
    // load all the medicines
    appointmentInstancesDb = AppointmentInstancesDBWorker();
    allAppointmentsModel.loadData(appointmentInstancesDb);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: allAppointmentsModel,
      child: Consumer<AllAppointmentsModel>(
        builder: (context, allAppModel, child){

          // if model is still loading, I display a loading icon
          if (allAppModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          // if list is empty, I display a proper message as list item
          if (allAppModel.allAppointments.length == 0) {
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    "Nessun appuntamento",
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
                itemCount: allAppModel.allAppointments.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _AllAppointmentsListItem(
                      appointmentInstance:
                      allAppModel.allAppointments[index]
                  );
                }
            ),
          );
        },
      ),
    );
  }
}

class _AllAppointmentsListItem extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  _AllAppointmentsListItem({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {
    return Text(appointmentInstance.appointment.name ?? "nessun nome");
  }
}
