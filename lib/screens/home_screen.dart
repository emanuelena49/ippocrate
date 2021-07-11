import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/swiper/appointment_swiper.dart';
import 'package:ippocrate/components/swiper/medicine_swiper.dart';
import 'package:ippocrate/components/swiper/periodical_appointment_swiper.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: GestureDetector(
        // tool to close keyboard when clicked outside
          onTap: () {
            // FocusScope.of(context).requestFocus(new FocusNode());
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: _HomeScreenBody(),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {

  _HomeScreenBody() {
    appointmentGroupsModel.loadData(AppointmentGroupsDBWorker());
    appointmentsInstancesModel.loadData(AppointmentInstancesDBWorker());
    medicineIntakesModel.loadData(MedicineIntakesDBWorker());
  }

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider.value(
      value: medicineIntakesModel,
      child: ChangeNotifierProvider.value(
        value: appointmentGroupsModel,
        child: ChangeNotifierProvider.value(
          value: appointmentsInstancesModel,
          child: ListView(
            children: [

              // incoming appointments carusel
              IncomingAppointmentsSwipe(),

              // today's medicine intakes carusel
              MedicineSwipe(),

              // incoming periodical appointments which can be booked
              PeriodicalAppointmentsSwipe(),

            ],
          ),
        ),
      ),
    );
  }

}