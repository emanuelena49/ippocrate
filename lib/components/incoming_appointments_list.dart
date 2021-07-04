import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';


/// The list with all [AppointmentInstance]s.
class IncomingAppointmentsList extends StatelessWidget {

  late AppointmentInstancesDBWorker appointmentInstancesDb;

  IncomingAppointmentsList() {
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

          List<AppointmentInstance> incoming =
            incAppModel.getIncomingAppointments();

          // if list is empty, I display a proper message as list item
          if (incoming.length == 0) {
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
                itemCount: incoming.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _IncomingAppointmentsListItem(
                      appointmentInstance: incoming[index]
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: Colors.blue,
      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: .25,
        secondaryActions: [
          IconSlideAction(
            caption: "Modifica",
            color: Colors.yellow,
            icon: Icons.edit,
            onTap: (){

            },
          ),
          IconSlideAction(
            caption: "Elimina",
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){

            },
          ),
        ],
        child: GestureDetector(
          onTap: () {

          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointmentInstance.appointment.name!,
                  style: Theme.of(context).textTheme.headline5,
                ),

                SizedBox(height: 5,),

                Text(
                  getWhenAppointment(appointmentInstance),
                  style: Theme.of(context).textTheme.subtitle2,
                ),

                Container(
                    height: 35,
                    padding: EdgeInsets.only(bottom: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          appointmentInstance.notes != null ?
                            appointmentInstance.notes! : "",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
