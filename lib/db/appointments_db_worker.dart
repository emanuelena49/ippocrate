import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/appointments_model.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentsDBWorker extends AdvancedDBWorker<Appointment> {

  @override
  String get objectName => "appointment";

  @override
  Future create(appointment) async {

    var map = toMap(appointment);

    Database db = await getDB();
    var ok = await db.rawInsert(
        "INSERT INTO $tableName "
            "(name, periodicity_days_interval)"
            "VALUES (?, ?)",
        [map["name"], map["periodicity_days_interval"], ]
    );

    // get last row id and save it as medicine id
    appointment.id = await getLastId();

    return ok;
  }

  @override
  Appointment fromMap(Map<String, dynamic> map) {

    return Appointment(
      id: map[objectIdName],
      name: map["name"],
      periodicityDaysInterval: map["periodicity_days_interval"],
    );
  }

  @override
  Map<String, dynamic> toMap(appointment) {
    appointment as Appointment;
    return {
      objectIdName: appointment.id,
      "name": appointment.name,
      "periodicity_days_interval": appointment.periodicityDaysInterval,
    };
  }
}