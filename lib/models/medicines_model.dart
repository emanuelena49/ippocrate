import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';

/// a single medicine
class Medicine extends HasId {
  int? id;
  String name;
  String? notes;
  DateTime fromDate;
  DateTime? toDate;
  int nIntakesPerDay;

  Medicine({
    this.id, required this.name,
    required this.fromDate, this.toDate,
    this.notes, this.nIntakesPerDay: 1
  });
}

/// A container for all [Medicine]s, it notify the UI when something change
class MedicinesModel extends ChangeNotifier {

  List<Medicine> medicinesList = [];
  bool loading = false;

  void loadData(dynamic inDatabaseWorker) async {
    loading = true;
    medicinesList = await inDatabaseWorker.getAll();
    loading = false;
    notifyListeners();
  }
}

MedicinesModel medicinesModel = MedicinesModel();