import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/generic_appointments_list.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/forms/search_and_filter_appointment_input.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/periodical_appointments_list.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:provider/provider.dart';

class AppointmentsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(

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
                    appointmentsInstancesModel.viewAppointment(
                      AppointmentInstance(
                          appointment: AppointmentGroup(name: ""),
                          dateTime: DateTime.now()
                      ), edit: true
                    );
                    screensManager.loadScreen(context, Screen.APPOINTMENTS_ONE);
                  }
              ),
            )
          ],
        ),

        body: GestureDetector(
          // tool to close keyboard when clicked outside
          onTap: () {
            // FocusScope.of(context).requestFocus(new FocusNode());
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: TabBarView(
            children: [
              _IncomingAppointmentsTab(),
              _PeriodicalAppointmentsTab(),
              _AllAppointmentsTab(),
            ],
          ),
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

  _AllAppointmentsTab() {
    appointmentGroupsModel.loadData(AppointmentGroupsDBWorker());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appointmentSearchFilterModel,
      child: ChangeNotifierProvider.value(
        value: appointmentGroupsModel,
        child: Column(
          children: [

            SearchAndFilterAppointmentInput(),

            // list of appointment filtered and sorted
            Consumer<AppointmentSearchFilterModel>(
              builder: (context, searchFilterModel, widget) {
                return Expanded(
                  child: GenericAppointmentsList(
                    searchOptions: searchFilterModel.searchOptions,
                    sortingOptions: searchFilterModel.sortingOptions,
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

}
