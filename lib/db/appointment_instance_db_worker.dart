import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:sqflite/sqflite.dart';

import 'appointments_db_worker.dart';

class AppointmentInstancesDBWorker extends AdvancedDBWorker<AppointmentInstance> {

  Future<List<AppointmentInstance>> getNextAppointments({required DateTime startDay}) async {
    String query = "SELECT * FROM $tableName NATURAL JOIN appointments "
        "WHERE appointment_datetime>='${startDay.toString()}' "
        "ORDER BY appointment_datetime";

    return getAll(customQuery: query);
  }

  @override
  String get objectName => "appointment_instance";

  @override
  Future create(appointmentInstance) async {

    var map = toMap(appointmentInstance);

    Database db = await getDB();
    var ok = await db.rawInsert(
        "INSERT INTO $tableName "
            "(medicine_id, appointment_datetime)"
            "VALUES (?, ?)",
        [ map["medicine_id"], map["appointment_datetime"], ]
    );

    // get last row id and save it as medicine id
    appointmentInstance.id = await getLastId();

    return ok;
  }

  @override
  Future<AppointmentInstance> get(int objectId, {String? customQuery}) {

    if (customQuery == null) {
      customQuery = "SELECT * FROM $tableName NATURAL JOIN appointments "
          "WHERE $objectIdName=$objectId";
    }

    return super.get(objectId, customQuery: customQuery);
  }

  @override
  Future<List<AppointmentInstance>> getAll({String? customQuery}) {

    if (customQuery == null) {
      customQuery = "SELECT * FROM $tableName NATURAL JOIN appointments "
          "ORDER BY appointment_datetime";
    }

    return super.getAll(customQuery: customQuery);
  }

  @override
  AppointmentInstance fromMap(Map<String, dynamic> map, {Appointment? appointment}) {

    if (appointment==null) {
      // I expect in my map to find also medicine's fields
      appointment = AppointmentsDBWorker().fromMap(map);
    }

    return AppointmentInstance(
      id: map[objectIdName],
      appointment: appointment,
      dateTime: DateTime.parse(map["appointment_datetime"])
    );
  }

  @override
  Map<String, dynamic> toMap(appointmentInstance) {
    appointmentInstance as AppointmentInstance;
    return {
      objectIdName: appointmentInstance.id,
      "medicine_id": appointmentInstance.appointment.id,
      "appointment_datetime": appointmentInstance.dateTime.toString(),
    };
  }
}