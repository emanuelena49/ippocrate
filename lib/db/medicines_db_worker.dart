import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:sqflite/sqflite.dart';

class MedicinesDBWorker extends AdvancedDBWorker<Medicine> {

  @override
  String get objectName => "medicine";

  @override
  Future create(medicine) async {

    var map = toMap(medicine);

    Database db = await getDB();
    var ok = await db.rawInsert(
        "INSERT INTO $tableName "
            "(name, from_date, to_date, n_intakes_per_day, "
            "n_days_between_intakes, notes) "
            "VALUES (?, ?, ?, ?, ?, ?)",
        [map["name"], map["from_date"], map["to_date"],
          map["n_intakes_per_day"], map["n_days_between_intakes"],
          map["notes"], ]
    );

    // get last row id and save it as medicine id
    medicine.id = await getLastId();

    return ok;
  }

  @override
  Medicine fromMap(Map<String, dynamic> map) {

    String? toDateStr = map["to_date"];

    return Medicine(
        id: map[objectIdName],
        name: map["name"],
        startDate: DateTime.parse(map["from_date"]),
        endDate: (toDateStr != null && toDateStr!="") ?
          DateTime.parse(toDateStr) :
          null,
        notes: map["notes"],
        intakeFrequency: IntakeFrequency(
            nIntakesPerDay: map["n_intakes_per_day"],
            nDaysBetweenIntakes: map["n_days_between_intakes"],
        ),
    );
  }

  @override
  Map<String, dynamic> toMap(medicine) {
    medicine as Medicine;
    return {
      objectIdName: medicine.id,
      "name": medicine.name,
      "notes": medicine.notes,
      "from_date": medicine.startDate.toString(),
      "to_date": medicine.endDate!=null ? medicine.endDate.toString() : null,
      "n_intakes_per_day": medicine.intakeFrequency.nIntakesPerDay,
      "n_days_between_intakes": medicine.intakeFrequency.nDaysBetweenIntakes,
    };
  }
}