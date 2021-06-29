import 'dart:html';

import 'package:flutter/cupertino.dart';
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

/// The collection of incoming [AppointmentInstance]
class IncomingAppointmentsModel extends ChangeNotifier {

  List<AppointmentInstance> incomingAppointments = [];
  AppointmentInstance? currentAppointment;
  bool loading = false;
  bool isNew = false;
  bool isEdit = false;

  loadData(appointmentsIntancesDb) async {

    loading = true;
    //todo: do request and fill incomingAppointments
    loading = false;
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

  loadData(appointmentsIntancesDb, {Appointment? type, bool sortDecr: false}) async {

    loading = true;
    //todo: do request and fill incomingAppointments
    loading = false;
  }
}

AllAppointmentsModel allAppointmentsModel = AllAppointmentsModel();
