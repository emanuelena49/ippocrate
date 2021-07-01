import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/components/all_appointments_list.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/incoming_appointments_list.dart';
import 'package:ippocrate/components/periodical_appointments_list.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';

class AppointmentsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.blueGrey,

          title: Text("Appuntmanenti"),

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
                    // todo: start creation of new
                    screensModel.loadScreen(context, Screen.APPOINTMENTS_ONE);
                  }
              ),
            )
          ],
        ),

        body: TabBarView(
          children: [
            IncomingAppointmentsList(),
            PeriodicalAppointmentsList(),
            AllAppointmentsList(),
          ],
        ),

        bottomNavigationBar: MyBottomBar(),
      ),
    );
  }
}