import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/components/generic_appointments_list.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/periodical_appointments_list.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';

class AppointmentsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.blueGrey,

          title: Text("Appuntamenti"),

          bottom: TabBar(
            tabs: [
              Tab(text: "IMMINENTI",),
              Tab(text: "PERIODICI", ),
              Tab(text: "TUTTI", ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("INSERISCI"),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green
                  ),
                  onPressed: () {
                    incomingAppointmentsModel.viewAppointment(
                      AppointmentInstance(
                          appointment: AppointmentGroup(name: ""),
                          dateTime: DateTime.now()
                      ), edit: true
                    );
                    screensModel.loadScreen(context, Screen.APPOINTMENTS_ONE);
                  }
              ),
            )
          ],
        ),

        body: TabBarView(
          children: [
            _IncomingAppointmentsTab(),
            _PeriodicalAppointmentsTab(),
            _AllAppointmentsTab(),
          ],
        ),

        bottomNavigationBar: MyBottomBar(),
      ),
    );
  }
}

class _IncomingAppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GenericAppointmentsList(
      searchOptions: AppointmentsSearchOptions(
        acceptedStates: [AppointmentState.INCOMING, AppointmentState.MAYBE_MISSED],
      ),
      sortingOptions: AppointmentsSortingOptions.PRIORITY,
    );
  }
}

class _PeriodicalAppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PeriodicalAppointmentsList();
  }
}

class _AllAppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // todo: add search & filter bar

        Expanded(
          child: GenericAppointmentsList(
            sortingOptions: AppointmentsSortingOptions.DATE_INCREASE,
          ),
        ),
      ],
    );
  }

}
