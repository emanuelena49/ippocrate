import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/appointment_instance_input.dart';
import 'package:ippocrate/components/appointment_read_only.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:provider/provider.dart';

class OneAppointmentTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: incomingAppointmentsModel,
      child: Consumer<IncomingAppointmentsModel>(
        builder: (context, appModel, child) {
          return  Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: Text(
                appModel.isNew ? "Nuovo Appuntamento" :
                    appModel.isEditing ? "Modifica Appuntamento" :
                        "Appuntamento"
              ),

              actions: [
                appModel.isEditing ?
                // form confirm button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: AppointmentInstanceSubmitButton(),
                ) :

                // normal screen actions
                AppointmentMenuButton(
                    appointmentInstance: appModel.currentAppointment!
                )
              ],
            ),


            body: appModel.isEditing ?
                AppointmentInstanceForm() :
                AppointmentReadOnly(),

            bottomNavigationBar: MyBottomBar(),
          );
        }
      ),
    );
  }
}