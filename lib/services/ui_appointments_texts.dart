import 'package:intl/intl.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/datetime.dart';

String getWhenAppointment(AppointmentInstance appointmentInstance) {

  String txt;

  DateTime today = getTodayDate();
  DateTime dateOnly = getPureDate(appointmentInstance.dateTime!);

  if (dateOnly.isAtSameMomentAs(today)) {
    txt = "OGGI";
  } else if (dateOnly.isAtSameMomentAs(today.add(Duration(days: 1)))) {
    txt = "DOMANI";
  } else {
    DateFormat dateFormat = DateFormat("dd/MM");
    txt = dateFormat.format(appointmentInstance.dateTime!);
  }

  DateFormat hourFormat = DateFormat("hh:mm");
  txt += " ALLE " + hourFormat.format(appointmentInstance.dateTime!);

  return txt;
}