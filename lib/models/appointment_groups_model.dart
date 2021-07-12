import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/common/model.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/services/datetime.dart';

/// An single appointment (type). It is the abstract representation of
/// a series of appointments, it has a [name] (ex. "controllo medico di base"),
/// + some other information (ex. the periodicity of the appointment, represented
/// by [periodicityDaysInterval] and [isPeriodic].
class AppointmentGroup implements HasId {
  @override
  int? id;
  String name;

  /// In case of periodicity, the (approximate) days between each appointment
  int? periodicityDaysInterval;

  AppointmentGroup({this.id, required this.name, this.periodicityDaysInterval});

  /// If this appointment should be repeated periodically, in detail every
  /// [periodicityDaysInterval] days
  bool isPeriodic() {
    return periodicityDaysInterval==null ? false : true;
  }
}

class AppointmentGroupsModel extends Model {

  AppointmentGroupsModel._();
  static final AppointmentGroupsModel instance = AppointmentGroupsModel._();

  List<AppointmentGroup> appointmentGroups = [];
  bool loading = false;

  AppointmentGroup? currentAppointmentGroup;
  bool isEditing = false;

  loadData(AppointmentGroupsDBWorker appointmentsDBWorker, {bool notify: true}) async {
    loading = true;
    appointmentGroups = await appointmentsDBWorker.getAll();
    loading = false;

    if (notify) notifyListeners();
  }

  viewAppointmentGroup(AppointmentGroup appointmentGroup, {edit: false}) {
    currentAppointmentGroup = appointmentGroup;
    isEditing = edit;
  }

  /// After called [loadData], get only the periodical appointments
  List<AppointmentGroup> getPeriodical() {
    List<AppointmentGroup> periodicalAppointments = [];
    appointmentGroups.forEach((appointment) {

      if (appointment.isPeriodic()) {
        periodicalAppointments.add(appointment);
      }
    });

    return periodicalAppointments;
  }
}

AppointmentGroupsModel appointmentGroupsModel = AppointmentGroupsModel.instance;