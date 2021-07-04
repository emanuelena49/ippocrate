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
  DateTime dateTime;
  Appointment appointment;
  String? notes;
  bool done;

  AppointmentInstance({this.id, required this.appointment,
    required this.dateTime, this.notes, this.done = false});
}

/// The collection of incoming [AppointmentInstance]
class IncomingAppointmentsModel extends ChangeNotifier {

  IncomingAppointmentsModel._();
  static final IncomingAppointmentsModel instance = IncomingAppointmentsModel._();

  List<AppointmentInstance> allAppointments = [];
  AppointmentInstance? currentAppointment;
  bool loading = false;
  bool isNew = false;
  bool isEditing = false;

  /// All the [AppointmentInstance] from [startDate]
  /// (eventually filtered by [Appointment])
  List<AppointmentInstance> getIncomingAppointments({DateTime? startDate,
    Appointment? type}) {

    if (startDate==null)  startDate = getTodayDate();

    List<AppointmentInstance> output = [];

    allAppointments.forEach((appInstance) {
      if (!getPureDate(appInstance.dateTime).isBefore(startDate!) &&
          (type==null || appInstance.appointment.id==type.id)) {
        output.add(appInstance);
      }
    });

    return output;
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

  notify() {
    notifyListeners();
  }
}

IncomingAppointmentsModel incomingAppointmentsModel =
  IncomingAppointmentsModel.instance;

/// All the [AppointmentInstance] (past, present and future).
/// They can be filtered in various way
class AllAppointmentsModel extends ChangeNotifier {

  AllAppointmentsModel._();
  static final AllAppointmentsModel instance = AllAppointmentsModel._();

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

AllAppointmentsModel allAppointmentsModel = AllAppointmentsModel.instance;
