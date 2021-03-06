import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
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
            "(appointment_id, appointment_datetime, notes, done)"
            "VALUES (?, ?, ?, ?)",
        [ map["appointment_id"], map["appointment_datetime"],
          map["notes"], map["done"]]
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
  AppointmentInstance fromMap(Map<String, dynamic> map, {AppointmentGroup? appointment}) {

    if (appointment==null) {
      // I expect in my map to find also medicine's fields
      appointment = AppointmentGroupsDBWorker().fromMap(map);
    }

    return AppointmentInstance(
      id: map[objectIdName],
      appointment: appointment,
      dateTime: DateTime.parse(map["appointment_datetime"]),
      notes: map["notes"],
      done: map["done"]=="TRUE" ? true : false,
    );
  }

  @override
  Map<String, dynamic> toMap(appointmentInstance) {
    appointmentInstance as AppointmentInstance;
    return {
      objectIdName: appointmentInstance.id,
      "appointment_id": appointmentInstance.appointment.id,
      "notes": appointmentInstance.notes,
      "appointment_datetime": appointmentInstance.dateTime.toString(),
      "done": appointmentInstance.done ? "TRUE" : "FALSE",
    };
  }
}