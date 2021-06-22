import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';

/// a single medicine
class Medicine extends HasId {
  int? id;
  String name;
  String? notes;
  DateTime fromDate;
  DateTime? toDate;
  late int nIntakesPerDay;

  Medicine({
    this.id, required this.name,
    required this.fromDate, this.toDate,
    this.notes, int? nIntakesPerDay: 1,
  }) {
    this.nIntakesPerDay = nIntakesPerDay!=null ? nIntakesPerDay : 1;
  }
}

/// A container for all [Medicine]s, it notify the UI when something change
class MedicinesModel extends ChangeNotifier {

  List<Medicine> medicinesList = [];
  bool loading = false;
  Medicine? currentMedicine;

  bool isEditing = false;
  bool isNew = false;

  loadData(dynamic inDatabaseWorker) async {
    loading = true;
    medicinesList = await inDatabaseWorker.getAll();
    loading = false;
    notifyListeners();
  }

  viewMedicine(Medicine medicine, {bool editing: false}) {
    currentMedicine = medicine;
    isEditing = editing;
    isNew = false;
    notifyListeners();
  }

  startNewMedicineCreation() {
    currentMedicine = Medicine(name: "", fromDate: DateTime.now());
    isEditing = isNew = true;
    notifyListeners();
  }

  unsetMedicine() {
    currentMedicine = null;
    isEditing = isNew = false;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}

MedicinesModel medicinesModel = MedicinesModel();