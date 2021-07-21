import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/dialogs/delete_appointment_instance.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';


/// A generic list of [AppointmentInstance]s, alignet to
/// [AppointmentInstancesModel]. It displays appointments according
/// to [searchOptions], sorted according to [sortingOptions].
class GenericAppointmentsList extends StatelessWidget {

  late AppointmentInstancesDBWorker appointmentInstancesDb;

  AppointmentsSearchOptions? searchOptions;
  AppointmentsSortingOptions? sortingOptions;

  GenericAppointmentsList({this.searchOptions, this.sortingOptions}) {
    // load all the medicines
    appointmentInstancesDb = AppointmentInstancesDBWorker();
    appointmentsInstancesModel.loadData(appointmentInstancesDb);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: appointmentsInstancesModel,
      child: Consumer<AppointmentInstancesModel>(
        builder: (context, appInstModel, child) {

          // if model is still loading, I display a loading icon
          if (appInstModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          var appointmentInstances = searchAppointmentInstances(
            searchOptions: searchOptions,
              sortingOptions: sortingOptions
          );

          // if list is empty, I display a proper message as list item
          if (appointmentInstances.length == 0) {
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
                itemCount: appointmentInstances.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return AppointmentsListItem(
                      appointmentInstance:
                      appointmentInstances[index]
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
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: isDone ? Colors.white54 :
      isMaybeMissed ? Colors.red : Colors.lightBlueAccent,

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
                appointmentsInstancesModel.loadData(appointmentsIntancesDb);
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
              appointmentsInstancesModel.loadData(appointmentsIntancesDb);
            },
          ),


          // edit & delete
          IconSlideAction(
            caption: "Modifica",
            color: Colors.yellow,
            icon: Icons.edit,
            onTap: (){
              appointmentsInstancesModel
                  .viewAppointment(appointmentInstance, edit: true);
              screensManager.loadScreen(context, Screen.APPOINTMENTS_ONE);
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
          behavior: HitTestBehavior.translucent,
          onTap: () {
            appointmentsInstancesModel.viewAppointment(
                appointmentInstance, edit: false);
            screensManager.loadScreen(context, Screen.APPOINTMENTS_ONE);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointmentInstance.appointment.name,
                      style: Theme.of(context).textTheme.headline5,
                      overflow: TextOverflow.ellipsis,
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
                Icon(
                  Icons.swipe,
                  color: Colors.black54,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
