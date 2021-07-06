import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/clonable.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/common/has_notes.dart';
import 'package:ippocrate/common/model.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/datetime.dart';


/// It is the single, concrete instance of [Appointment]. It is the concrete
/// appointment and it is characterized by a specific [dateTime].
class AppointmentInstance implements HasId, Clonable, HasNotes {

  @override
  int? id;

  DateTime dateTime;
  Appointment appointment;

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
class IncomingAppointmentsModel extends Model {

  IncomingAppointmentsModel._();
  static final IncomingAppointmentsModel instance = IncomingAppointmentsModel._();

  List<AppointmentInstance> allAppointments = [];
  AppointmentInstance? currentAppointment;
  bool loading = false;
  bool isNew = false;
  bool isEditing = false;

  /// All the [AppointmentInstance] from [startDate]
  /// (eventually filtered by [Appointment] and eventually
  /// including past missing)
  List<AppointmentInstance> getIncomingAppointments({DateTime? startDate,
    Appointment? type, bool includeMissing: false}) {

    if (startDate==null)  startDate = getTodayDate();

    List<AppointmentInstance> output = [];

    allAppointments.forEach((appInstance) {
      if (
        (!getPureDate(appInstance.dateTime).isBefore(startDate!) ||
                (appInstance.isMaybeMissed && includeMissing)) &&
            (type==null || appInstance.appointment.id==type.id)) {
        output.add(appInstance);
      }
    });

    return output..sort((a, b) {
      if (a.isMaybeMissed == b.isMaybeMissed) {
        return a.dateTime.compareTo(b.dateTime);
      } else if (b.isMaybeMissed) {
        return 1;
      } else {
        return -1;
      }
    });
  }

  /// All the [AppointmentInstance] before [startDate]
  /// (eventually filtered by [Appointment])
  List<AppointmentInstance> getPastAppointments({DateTime? startDate,
    Appointment? type}) {

    if (startDate==null)  startDate = getTodayDate();

    List<AppointmentInstance> output = [];

    allAppointments.forEach((appInstance) {
      if (getPureDate(appInstance.dateTime).isBefore(startDate!) &&
          (type==null || appInstance.appointment.id==type.id)) {
        output.add(appInstance);
      }
    });

    return output;
  }

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

IncomingAppointmentsModel incomingAppointmentsModel =
  IncomingAppointmentsModel.instance;
