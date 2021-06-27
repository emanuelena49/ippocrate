import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:sqflite/sqflite.dart';

import 'medicines_db_worker.dart';

class MedicineIntakesDBWorker extends AdvancedDBWorker<MedicineIntake> {

  Future<List<MedicineIntake>> getDailyIntakes({DateTime? day,
    Medicine? medicine, bool onlyNotDone: false}) async {

    String query = "SELECT * FROM $tableName NATURAL JOIN medicines ";

    // manage date
    if (day == null) {
      day = getTodayDate();
    } else {
      day = getPureDate(day);
    }
    query += "WHERE intake_date='${day.toString()}' ";

    // include eventual medicine limitation
    if (medicine != null) {
      query += "AND medicine_id=${medicine.id}";
    }

    // get all intakes according to query
    List<MedicineIntake> intakes = await getAll(customQuery: query);

    // (eventually) filter only the not completed ones
    if (onlyNotDone) {
      intakes.forEach((i) {
        if (i.getMissingIntakes() < 1) {
          intakes.remove(i);
        }
      });
    }

    return intakes;
  }

  @override
  String get objectName => "medicine_intake";

  @override
  Future create(HasId medicineIntake) async {

    var map = toMap(medicineIntake);
    Database db = await getDB();

    var ok = await db.rawInsert(
        "INSERT INTO $tableName "
            "(medicine_id, intake_date, n_intakes_done) "
            "VALUES (?, ?, ?)",
        [map["medicine_id"], map["intake_date"], map["n_intakes_done"],]
    );

    // get last row id and save it as medicineIntake id
    medicineIntake.id = await getLastId();

    return ok;
  }

  @override
  Future<MedicineIntake> get(int objectId, {String? customQuery}) async {

    if (customQuery == null) {
      // build a custom query which uses join to get also medicine data
      customQuery = "SELECT * FROM $tableName NATURAL JOIN medicines "
          "WHERE medicine_intake_id=$objectId";
    }

    // use the custom query to get all the data (which will be automatically
    // parsed by fromMap)
    return super.get(objectId, customQuery: customQuery);
  }

  @override
  Future<List<MedicineIntake>> getAll({String? customQuery}) async {

    if (customQuery == null) {
      // build a custom query which uses join to get also medicine data
      customQuery = "SELECT * FROM $tableName NATURAL JOIN medicines";
    }

    // use the custom query to get all the data (which will be automatically
    // parsed by fromMap)
    return super.getAll(customQuery: customQuery);
  }

  @override
  MedicineIntake fromMap(Map<String, dynamic> map, {Medicine? medicine}) {

    if (medicine==null) {
      // I expect in my map to find also medicine's fields
      medicine = MedicinesDBWorker().fromMap(map);
    }

    return MedicineIntake(
        id: map["medicine_intake_id"],
        medicine: medicine,
        day: DateTime.parse(map["intake_date"]),
        nIntakesDone: map["n_intakes_done"],
    );
  }

  @override
  Map<String, dynamic> toMap(HasId medicineIntake) {

    medicineIntake as MedicineIntake;

    if (medicineIntake.medicine.id == null) {
      throw Exception("Passed medicine is not already stored in the db. "
          "Store it first, else we can't have a valid medicine_id");
    }

    return {
      objectIdName: medicineIntake.id,
      "medicine_id": medicineIntake.medicine.id,
      "intake_date": medicineIntake.day.toString(),
      "n_intakes_done": medicineIntake.nIntakesDone,
    };
  }

}