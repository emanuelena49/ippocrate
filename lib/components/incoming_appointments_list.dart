import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/components/delete_appointment.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';


/// The list with all [AppointmentInstance]s.
class IncomingAppointmentsList extends StatelessWidget {

  late AppointmentInstancesDBWorker appointmentInstancesDb;

  IncomingAppointmentsList() {
    // load all the appointments
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
            incAppModel.getIncomingAppointments(includeMissing: true);

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
                  return AppointmentsListItem(
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

class AppointmentsListItem extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  AppointmentsListItem({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {

    bool isDone = appointmentInstance.done;
    bool isMaybeMissed = appointmentInstance.isMaybeMissed;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: isDone ? Colors.white54 :
        isMaybeMissed ? Colors.red : Colors.blue,

      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: .22,
        secondaryActions: [

          // mark as undone/done
          isDone ?
            IconSlideAction(
            caption: "Segna come\nda fare",
              color: Colors.white10,
              icon: Icons.close,
              onTap: () async {
                appointmentInstance.done = false;
                var appointmentsIntancesDb = AppointmentInstancesDBWorker();
                await appointmentsIntancesDb.update(appointmentInstance);
                incomingAppointmentsModel.loadData(appointmentsIntancesDb);
              }
            ) :
            IconSlideAction(
              caption: "Segna come\nfatto",
              color: Colors.green,
              icon: Icons.check,
              onTap: () async {
                appointmentInstance.done = true;
                var appointmentsIntancesDb = AppointmentInstancesDBWorker();
                await appointmentsIntancesDb.update(appointmentInstance);
                incomingAppointmentsModel.loadData(appointmentsIntancesDb);
              },
            ),


          // edit & delete
          IconSlideAction(
            caption: "Modifica",
            color: Colors.yellow,
            icon: Icons.edit,
            onTap: (){
              incomingAppointmentsModel
                  .viewAppointment(appointmentInstance, edit: true);
              screensModel.loadScreen(context, Screen.APPOINTMENTS_ONE);
            },
          ),
          IconSlideAction(
            caption: "Elimina",
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              deleteAppointment(context, appointmentInstance);
            },
          ),
        ],
        child: GestureDetector(
          onTap: () {

            incomingAppointmentsModel.viewAppointment(
                appointmentInstance, edit: false);
            screensModel.loadScreen(context, Screen.APPOINTMENTS_ONE);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointmentInstance.appointment.name,
                  style: Theme.of(context).textTheme.headline5,
                ),

                SizedBox(height: 5,),

                Text(
                  getWhenAppointment(appointmentInstance) +
                      (isDone ? " (già fatto)" : isMaybeMissed ?
                      " (FORSE MANCATO!)" : ""),
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
