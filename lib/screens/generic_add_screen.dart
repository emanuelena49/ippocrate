import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';

class GenericAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi"),
      ),
      body: GestureDetector(
        // tool to close keyboard when clicked outside
          onTap: () {
            // FocusScope.of(context).requestFocus(new FocusNode());
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.lightBlueAccent,
                margin: EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    appointmentsInstancesModel.viewAppointment(
                      AppointmentInstance(
                          appointment: AppointmentGroup(name: ""),
                          dateTime: getTodayDate()
                      ), edit: true
                    );
                    screensManager.loadScreen(context, Screen.APPOINTMENTS_ONE);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        ImageIcon(AssetImage('assets/icons/appointment.png'),
                          size: 55,),
                        Text("Nuovo Appuntamento",
                          style: Theme.of(context).textTheme.headline6,)
                      ],
                    ),
                  ),
                ),
              ),

              Card(
                color: Colors.greenAccent,
                margin: EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    medicinesModel.viewMedicine(
                        Medicine(
                            name: '',
                            startDate: getTodayDate()
                        ), edit: true
                    );
                    screensManager.loadScreen(context, Screen.MEDICINES_ONE);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageIcon(AssetImage('assets/icons/medicine.png'),
                          size: 55,),
                        Text("Nuovo Medicinale",
                          style: Theme.of(context).textTheme.headline6,)
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}