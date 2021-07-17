import 'package:flutter/cupertino.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/ui_appointments_texts.dart';


String getNotificationTitle(subject) {

  switch (subject.runtimeType.toString()) {
    case "AppointmentInstance":
      subject as AppointmentInstance;
      return subject.appointment.name;
    case "":
      // todo: implement...
      break;
  }

  return "";
}

String getNotificationContent(subject) {

  switch (subject.runtimeType.toString()) {
    case "AppointmentInstance":
      subject as AppointmentInstance;
      return "${getWhenAppointment(subject, onlyAbsoluteDateTimes: true)}, non dimenticare il tuo appuntamento!";
    case "":
    // todo: implement...
      break;
  }

  return "";
}