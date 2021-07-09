import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/clonable.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/common/has_notes.dart';
import 'package:ippocrate/common/model.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/services/datetime.dart';


/// It is the single, concrete instance of [AppointmentGroup]. It is the concrete
/// appointment and it is characterized by a specific [dateTime].
class AppointmentInstance implements HasId, Clonable, HasNotes {

  @override
  int? id;

  DateTime dateTime;
  AppointmentGroup appointment;

  @override
  String? notes;

  bool done;

  bool get isMaybeMissed => dateTime.isBefore(getTodayDate()) && !done;

  AppointmentInstance({this.id, required this.appointment,
    required this.dateTime, this.notes, this.done = false});

  @override
  AppointmentInstance clone() {
    return AppointmentInstance(
        appointment: appointment,
        dateTime: dateTime,
        notes: notes,
        done: done,
    );
  }
}

/// The collection of incoming [AppointmentInstance]
class AppointmentInstancesModel extends Model {

  AppointmentInstancesModel._();
  static final AppointmentInstancesModel instance = AppointmentInstancesModel._();

  List<AppointmentInstance> allAppointments = [];
  AppointmentInstance? currentAppointment;
  bool loading = false;
  bool isNew = false;
  bool isEditing = false;

  loadData(AppointmentInstancesDBWorker appointmentsIntancesDb, {notify: true}) async {

    loading = true;

    allAppointments = await appointmentsIntancesDb.getAll();

    if (notify) notifyListeners();
    loading = false;
  }

  viewAppointment(AppointmentInstance appointmentInstance, {edit: false}) {
    currentAppointment = appointmentInstance;
    if (appointmentInstance.id == null) {
      isNew = true;
    } else {
      isNew = false;
    }
    isEditing = edit;
  }
}

AppointmentInstancesModel appointmentsInstancesModel =
  AppointmentInstancesModel.instance;
