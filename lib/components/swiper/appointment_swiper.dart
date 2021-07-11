import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';

class IncomingAppointmentsSwipe extends StatelessWidget {

  IncomingAppointmentsSwipe() {
    appointmentsInstancesModel.loadData(AppointmentInstancesDBWorker());
  }

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    return ChangeNotifierProvider.value(
      value: appointmentsInstancesModel,
      child: Consumer<AppointmentInstancesModel>(
        builder: (context, appModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Appuntamenti Imminenti",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Builder(
                builder: (context) {
                  if (appModel.loading) {
                    return CircularProgressIndicator();
                  }

                  var appointments = searchAppointmentInstances(
                    searchOptions: AppointmentsSearchOptions(
                      endDate: today.add(Duration(days: 60)),
                      acceptedStates: [
                        AppointmentState.MAYBE_MISSED,
                        AppointmentState.INCOMING,
                      ]
                    ),
                    sortingOptions: AppointmentsSortingOptions.PRIORITY
                  );

                  if (appointments.length == 0) {
                    return Container(
                      color: Colors.white54,
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: Text(
                          "Nessun appuntamento imminente!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    );
                  }

                  return SwipeCarusel(
                    appointments.map((i) =>
                        AppointmentSwipeCard(appointmentInstance: i)).toList(),
                    height: 140,
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

}


class AppointmentSwipeCard extends StatelessWidget {

  late AppointmentInstance appointmentInstance;
  AppointmentSwipeCard({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {

    var appointmentGroup = appointmentInstance.appointment;

    return SwipableCard(
      color: appointmentInstance.isMaybeMissed ? Colors.red :
        appointmentInstance.done ? Colors.white54 : Colors.lightBlueAccent,
      onTap: () {

      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // medicine name
          Text(
            appointmentGroup.name,
            style: Theme.of(context).textTheme.headline5,
          ),

          // appo
          Text(
            getWhenAppointment(appointmentInstance),
            style: Theme.of(context).textTheme.subtitle2,
          ),

          SizedBox(height: 5,),

          // notes preview
          Container(
            height: 40,
            child: Text(
              appointmentInstance.notes != null ?
                appointmentInstance.notes! : "",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}