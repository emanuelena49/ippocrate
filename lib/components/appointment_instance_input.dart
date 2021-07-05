import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/datetime.dart';

import 'notes_input.dart';

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

          _AppointmentTypeInput(appointmentIntstance: appointmentInstance),

          _AppointmentDateTimeInput(appointmentInstance: appointmentInstance),

          NotesInput(
              obj: appointmentInstance,
              model: incomingAppointmentsModel
          ),
        ],
      )
    );
  }
}

class _AppointmentTypeInput extends StatelessWidget {

  AppointmentInstance appointmentIntstance;

  TextEditingController _controller = TextEditingController();

  static List<Appointment> options = appointmentsModel.appointments;

  _AppointmentTypeInput({Key? key, required this.appointmentIntstance}) :
        super(key: key){
    _controller.text = this.appointmentIntstance.appointment.name;
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            labelText: "Scopo appuntamento: "
          ),
          onChanged: (inValue) {

            var selected = options.where((o) => o.name==inValue);

            if (selected.isNotEmpty) {

              // if user chose one of the proposed options, I assign it
              // as appointment type
              appointmentIntstance.appointment =
                  selected.first;
            } else {

              // if user typed free text, I create a new
              appointmentIntstance.appointment =
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

class _AppointmentDateTimeInput extends StatelessWidget {

  AppointmentInstance appointmentInstance;

  _AppointmentDateTimeInput({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: DateTimePicker(
        type: DateTimePickerType.dateTimeSeparate,
        dateLabelText: "Giorno",
        timeLabelText: "Ora",
        initialValue: appointmentInstance.dateTime.toString(),
        initialDate: appointmentInstance.dateTime,
        initialTime: TimeOfDay(hour: 10, minute: 0),
        firstDate: getTodayDate(),
        lastDate: DateTime(2100),
        onChanged: (val) {
          if (val != null && val != "") {
            appointmentInstance.dateTime = DateTime.parse(val);
          }
        },
        validator: (val) {
          // check it is not null
          if (val == null || val == "") {
            return "La data e l'ora dell'appuntamento non possono essere nulle";
          }

          return null;
        },
        onSaved: (val) {
          if (val != null && val != "") {
            appointmentInstance.dateTime = DateTime.parse(val);
          }
        },
      ),
    );
  }
}



















