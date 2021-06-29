import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/appointments_model.dart';


/// It is the single, concrete instance of [Appointment]. It is the concrete
/// appointment and it is characterized by a specific [dateTime].
class AppointmentInstance implements HasId {
  @override
  int? id;
  DateTime? dateTime;
  Appointment appointment;

  AppointmentInstance({this.id, required this.appointment, this.dateTime});
}