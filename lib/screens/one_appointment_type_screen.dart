import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/single_screens/appointment_group_read_only.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/forms/appointment_group_edit_input.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/lists/generic_appointments_list.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';

import 'package:provider/provider.dart';

class OneAppointmentTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appointmentGroupsModel,
      child: Consumer<AppointmentGroupsModel>(
          builder: (context, appGroupModel, child) {
            return  Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black54,
                title: Text(
                    appGroupModel.isEditing ? "Modifica Appuntamento (Gruppo)" :
                    "Appuntamento (Gruppo)"
                ),

                actions: [
                  appGroupModel.isEditing ?
                    // form confirm button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: AppointmentGroupSubmitButton(),
                    ) :

                    // normal screen actions
                    AppointmentGroupMenuItem(
                        appointmentGroup: appGroupModel.currentAppointmentGroup!
                    ),
                ],
              ),


              body: appGroupModel.isEditing ?
                AppointmentGroupForm():
                AppointmentGroupReadOnly(appGroupModel.currentAppointmentGroup!),

              bottomNavigationBar: MyBottomBar(),
            );
          }
      ),
    );
  }
}

