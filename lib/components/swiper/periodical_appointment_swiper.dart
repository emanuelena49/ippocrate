import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';
import 'package:provider/provider.dart';

class PeriodicalAppointmentsSwipe extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    return Consumer2<AppointmentInstancesModel, AppointmentGroupsModel>(
      builder: (context, appModel, appGroupModel, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "Appuntamenti periodici da prenotare",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Builder(
              builder: (context) {
                if (appModel.loading || appGroupModel.loading) {
                  return CircularProgressIndicator();
                }

                var appointmentsToBook =
                appGroupModel.getPeriodical().where((a) {
                  var nextInstance = getNextAppointmentInstance(a, today);

                  if (nextInstance==null) {
                    return true;
                  } else {
                    return false;
                  }
                });

                if (appointmentsToBook.length == 0) {
                  return Container(
                    color: Colors.white54,
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "Nessun appuntamento imminente!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  );
                }

                return SwipeCarusel(
                  appointmentsToBook.map((i) =>
                      PeriodicalAppointmentSwipeCard(appointmentGroup: i)).toList(),
                );
              },
            )
          ],
        );
      },
    );
  }
}


class PeriodicalAppointmentSwipeCard extends StatelessWidget {

  late AppointmentGroup appointmentGroup;
  PeriodicalAppointmentSwipeCard({required this.appointmentGroup});

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    var prevInstance = getPrevAppointmentInstance(appointmentGroup,
        today.subtract(Duration(days: 1)));

    return SwipableCard(
      color: Colors.lightBlueAccent,
      onTap: () {
        appointmentGroupsModel.viewAppointmentGroup(appointmentGroup);
        screensManager.loadScreen(context, Screen.APPOINTMENTS_GROUP_ONE);
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
            getPeriodicalAppointmentFrequency(appointmentGroup),
            style: Theme.of(context).textTheme.subtitle2,
          ),

          SizedBox(height: 5,),


          if (prevInstance!=null)
            Text(
              "Ultima volta: ${getWhenAppointment(prevInstance)}",
              style: Theme.of(context).textTheme.subtitle2,
            )
          else
            Text(""),

          SizedBox(height: 15,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text("PRENOTA ORA"),
                  ),
                  onPressed: () {
                    var newInstance = AppointmentInstance(
                        appointment: appointmentGroup,
                        dateTime: DateTime.now()
                    );
                    appointmentsInstancesModel.viewAppointment(newInstance, edit: true);
                    screensManager.loadScreen(context, Screen.APPOINTMENTS_ONE);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black54,)
              )
            ],
          )
        ],
      ),
    );
  }
}