import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/forms/appointment_instance_input.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class AppointmentGroupSubmitButton extends StatelessWidget {

  // late AppointmentGroup initialValue;

  /*
  AppointmentInstanceSubmitButton() {
    initialValue = appointmentsInstancesModel.currentAppointment!.clone();
  }*/

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Text("conferma"),
        onPressed: () async {
          // validate form
          if(!formKey.currentState!.validate()){
            return;
          }

          var appointmentGroup = appointmentGroupsModel.currentAppointmentGroup!;

          // return;

          // insert or update the appointment type existent
          AppointmentGroupsDBWorker dbAppointments = AppointmentGroupsDBWorker();
          var ok = await dbAppointments.update(appointmentGroup);

          // update all models
          appointmentGroupsModel.loadData(dbAppointments);

          // go back at precedent screen
          screensManager.back(context);
        }
    );
  }
}

class AppointmentGroupForm extends StatelessWidget {
  late AppointmentGroup appointmentGroup;

  @override
  Widget build(BuildContext context) {

    appointmentGroup = appointmentGroupsModel.currentAppointmentGroup!;

    return Form(
      key: formKey,
      child: ListView(
        children: [

          // a.g. name
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(
                  labelText: "Nome del gruppo",
                  hintText: "ex. Visita medico di base",
                ),
              initialValue: appointmentGroup.name,
              validator: (inValue) {

                if (inValue == null || inValue=="") {
                  return "Il nome non può essere lasciato vuoto";
                }
                return null;
              },
              onChanged: (inValue) {
                appointmentGroup.name = inValue;
              },
            ),
          ),

          // periodicity input
          AppointmentPeriodicityInput(appointment: appointmentGroup),
        ],
      ),
    );
  }
}