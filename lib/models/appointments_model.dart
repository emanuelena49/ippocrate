import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/services/datetime.dart';

/// An single appointment (type). It is the abstract representation of
/// a series of appointments, it has a [name] (ex. "controllo medico di base"),
/// + some other information (ex. the periodicity of the appointment, represented
/// by [periodicityDaysInterval] and [isPeriodic].
class Appointment implements HasId {
  @override
  int? id;
  String? name;

  /// In case of periodicity, the (approximate) days between each appointment
  int? periodicityDaysInterval;

  Appointment({this.id, this.name, this.periodicityDaysInterval});

  /// If this appointment should be repeated periodically, in detail every
  /// [periodicityDaysInterval] days
  bool isPeriodic() {
    return periodicityDaysInterval==null ? false : true;
  }
}

class AppointmentsModel extends ChangeNotifier {

  List<Appointment> appointments = [];
  bool loading = false;

  loadData(AppointmentsDBWorker appointmentsDBWorker) async {
    loading = true;
    appointments = await appointmentsDBWorker.getAll();
    loading = false;
  }

  /// After called [loadData], get only the periodical appointments
  List<Appointment> getPeriodical() {
    List<Appointment> periodicalAppointments = [];
    appointments.forEach((appointment) {

      if (appointment.isPeriodic()) {
        periodicalAppointments.add(appointment);
      }
    });

    return periodicalAppointments;
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();