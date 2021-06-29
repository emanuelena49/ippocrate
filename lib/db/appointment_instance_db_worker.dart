import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:sqflite/sqflite.dart';

import 'appointments_db_worker.dart';

class AppointmentIntancesDBWorker extends AdvancedDBWorker<AppointmentInstance> {

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
  AppointmentInstance fromMap(Map<String, dynamic> map, {Appointment? appointment}) {

    if (appointment==null) {
      // I expect in my map to find also medicine's fields
      appointment = AppointmentsDBWorker().fromMap(map);
    }

    return AppointmentInstance(
      id: map[objectIdName],
      appointment: appointment!,
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