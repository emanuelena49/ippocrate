import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/swiper/appointment_swiper.dart';
import 'package:ippocrate/components/swiper/medicine_swiper.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
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

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    return ListView(
      children: [

        // incoming appointments carusel
        IncomingAppointmentsSwipe(),

        // today's medicine intakes carusel
        MedicineSwipe(),


      ],
    );
  }

}