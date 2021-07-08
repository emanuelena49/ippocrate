import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/datetime.dart';

String getWhenAppointment(AppointmentInstance appointmentInstance) {

  String txt;

  DateTime today = getTodayDate();
  DateTime dateOnly = getPureDate(appointmentInstance.dateTime);

  if (dateOnly.isAtSameMomentAs(today)) {
    txt = "OGGI";
  } else if (dateOnly.isAtSameMomentAs(today.add(Duration(days: 1)))) {
    txt = "DOMANI";
  } else {
    DateFormat dateFormat = DateFormat("dd/MM");
    txt = dateFormat.format(appointmentInstance.dateTime);
  }

  DateFormat hourFormat = DateFormat("hh:mm");
  txt += " ALLE " + hourFormat.format(appointmentInstance.dateTime);

  return txt;
}

String getPeriodicalAppointmentFrequency(AppointmentGroup appointment) {

  if (!appointment.isPeriodic()) {
    throw Exception("You can't get frequency from a non-periodical appointment");
  }

  int days = appointment.periodicityDaysInterval!;
  String txt = "Cadenza: ";

  if (days==365) {
    return "$txt ANNUALE";
  } else if (days==30) {
    return "$txt MENSILE";
  } else if (days%30==0) {
    return "$txt ogni ${(days~/30).toString()} mesi";
  } else {
    return "$txt ogni ${days.toString()} giorni";
  }
}

String getPastAppointmentTime(AppointmentInstance pastAppointment) {

  DateTime appointmentDate = getPureDate(pastAppointment.dateTime);
  DateTime today = getTodayDate();

  String txt = "Ultima volta: ";
  int diffDays = today.difference(appointmentDate).inDays;

  if (appointmentDate.isAfter(today)) {
    throw Exception("pastAppointment date (${appointmentDate.toString()}) should "
        "come after today's date ${today.toString()}");
  } else if (appointmentDate.isAtSameMomentAs(today)) {
    return "$txt OGGI";
  } else if (diffDays<30) {
    return "$txt $diffDays giorni fa";
  } else if (diffDays<60) {
    return "$txt un mese fa";
  } else {
    return "$txt ${diffDays~/30} mesi fa";
  }
}