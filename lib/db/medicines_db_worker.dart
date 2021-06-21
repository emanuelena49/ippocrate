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
        [medicine.name, medicine.fromDate.toString(),
          medicine.toDate.toString(), medicine.notes]
    );
  }

  @override
  Medicine fromMap(Map<String, dynamic> map) {

    String? toDateStr = map["to_date"];

    return Medicine(
        id: map[objectIdName],
        name: map["name"],
        fromDate: DateTime.parse(map["from_date"]),
        toDate: toDateStr!=null ? DateTime.parse(toDateStr) : null,
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
      "from_date": medicine.fromDate.toString(),
      "to_date": medicine.toDate.toString(),
      "n_intakes_per_day": medicine.nIntakesPerDay
    };
  }
}