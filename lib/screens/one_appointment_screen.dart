import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/forms/appointment_instance_input.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/single_screens/appointment_read_only.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:provider/provider.dart';

class OneAppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appointmentsInstancesModel,
      child: ChangeNotifierProvider.value(
        value: appointmentGroupsModel,
        child: Consumer2<AppointmentInstancesModel, AppointmentGroupsModel>(
          builder: (context, appModel, appGroupModel, child) {
            return  Scaffold(
              appBar: AppBar(
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


              body: GestureDetector(
                // tool to close keyboard when clicked outside
                onTap: () {
                  // FocusScope.of(context).requestFocus(new FocusNode());
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: appModel.isEditing ?
                  AppointmentInstanceForm() :
                  AppointmentReadOnly(),
              ),

              bottomNavigationBar: MyBottomBar(),
            );
          }
        ),
      ),
    );
  }
}