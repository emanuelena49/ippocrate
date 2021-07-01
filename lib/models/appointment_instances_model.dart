import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:ippocrate/services/datetime.dart';


/// It is the single, concrete instance of [Appointment]. It is the concrete
/// appointment and it is characterized by a specific [dateTime].
class AppointmentInstance implements HasId {
  @override
  int? id;
  DateTime? dateTime;
  Appointment appointment;

  AppointmentInstance({this.id, required this.appointment, this.dateTime});
}

/// The collection of incoming [AppointmentInstance]
class IncomingAppointmentsModel extends ChangeNotifier {

  List<AppointmentInstance> incomingAppointments = [];
  AppointmentInstance? currentAppointment;
  bool loading = false;
  bool isNew = false;
  bool isEditing = false;

  loadData(AppointmentInstancesDBWorker appointmentsIntancesDb, {notify: true}) async {

    loading = true;

    incomingAppointments = await appointmentsIntancesDb.getNextAppointments(
        startDay: getTodayDate());

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

  notify() {
    notifyListeners();
  }
}

IncomingAppointmentsModel incomingAppointmentsModel =
  IncomingAppointmentsModel();

/// All the [AppointmentInstance] (past, present and future).
/// They can be filtered in various way
class AllAppointmentsModel extends ChangeNotifier {

  List<AppointmentInstance> allAppointments = [];
  bool loading = false;
  Appointment? type;
  bool sortDecr = false;

  loadData(AppointmentInstancesDBWorker appointmentsIntancesDb, {bool notify: true}) async {

    loading = true;
    allAppointments = await appointmentsIntancesDb.getAll();
    loading = false;
    if (notify) {
      notifyListeners();
    }
  }

  notify() {
    notifyListeners();
  }
}

AllAppointmentsModel allAppointmentsModel = AllAppointmentsModel();
