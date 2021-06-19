import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:sqflite/sqflite.dart';

class MedicinesDBWorker extends AdvancedDBWorker<Medicine> {

  @override
  String get objectName => "medicine";

  @override
  Future create(medicine) async {
    Database db = await getDB();

    medicine as Medicine;

    return await db.rawInsert(
        "INSERT INTO $tableName "
            "(name, from_date, to_date, n_intakes_per_day, notes) "
            "VALUES (?, ?, ?, ?, ?)",
        [medicine.name, medicine.interval.start.toString(),
          medicine.interval.end.toString(), medicine.notes]
    );
  }

  @override
  Medicine fromMap(Map<String, dynamic> map) {

    DateTimeRange interval = DateTimeRange(
        start: DateTime.parse(map["from_date"]),
        end: DateTime.parse(map["to_date"]),
    );

    return Medicine(
        id: map[objectIdName],
        name: map["name"],
        interval: interval,
        notes: map["notes"],
        nIntakesPerDay: map["n_intakes_per_day"]
    );
  }


  @override
  Map<String, dynamic> toMap(medicine) {
    medicine as Medicine;
    return {
      objectIdName: medicine.id,
      "name": medicine.name,
      "notes": medicine.notes,
      "from_date": medicine.interval.start.toString(),
      "to_date": medicine.interval.end.toString(),
      "n_intakes_per_day": medicine.nIntakesPerDay
    };
  }
}