import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class AppointmentInstanceSubmitButton extends StatelessWidget {

  late AppointmentInstance initialValue;

  AppointmentInstanceSubmitButton() {
    initialValue = incomingAppointmentsModel.currentAppointment!.clone();
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.green,
      ),
      child: Text("conferma"),
      onPressed: () async {
          // todo: insert or update, etc...
      }
    );
  }
}


class AppointmentInstanceForm extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  @override
  Widget build(BuildContext context) {

    appointmentInstance = incomingAppointmentsModel.currentAppointment!;

    return Form(
      key: formKey,
      child: ListView(
        children: [

          _AppointmentTypeInput(),
        ],
      )
    );
  }
}

class _AppointmentTypeInput extends StatelessWidget {

  TextEditingController _controller = TextEditingController();

  static List<Appointment> options = appointmentsModel.appointments;

  _AppointmentTypeInput({Key? key}) : super(key: key){
    _controller.text =
        incomingAppointmentsModel.currentAppointment!.appointment.name;
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Scopo appuntamento: "
          ),
          onChanged: (inValue) {

            var selected = options.where((o) => o.name==inValue);

            if (selected.isNotEmpty) {

              // if user chose one of the proposed options, I assign it
              // as appointment type
              incomingAppointmentsModel.currentAppointment!.appointment =
                  selected.first;
            } else {

              // if user typed free text, I create a new
              incomingAppointmentsModel.currentAppointment!.appointment =
                  Appointment(name: inValue);
            }
          },
          controller: _controller,

        ),
        suggestionsCallback: (pattern) async {
          return options.where((option) =>
              option.name.contains(pattern));
        },
        itemBuilder: (context, Appointment suggestion) {
          return ListTile(
            title: Text(suggestion.name),
          );
        },
        onSuggestionSelected: (Appointment suggestion) {
          _controller.text = suggestion.name;
        },
        getImmediateSuggestions: true,
      ),
    );
  }
}