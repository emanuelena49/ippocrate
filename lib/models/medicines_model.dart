import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';

/// the intake frequency for a single medicine
class IntakeFrequency {
  final int nIntakesPerDay;
  final int nDaysBetweenIntakes;

  IntakeFrequency({this.nIntakesPerDay: 1, this.nDaysBetweenIntakes:1});

  factory IntakeFrequency.setNIntakesPerDay(nIntakes) {
    return IntakeFrequency(nIntakesPerDay: nIntakes);
  }

  factory IntakeFrequency.setNDaysBetweenIntakes(nIntakes) {
    return IntakeFrequency(nDaysBetweenIntakes: nIntakes);
  }
}

/// a single medicine
class Medicine extends HasId {
  int? id;
  String name;
  String? notes;
  DateTime fromDate;
  DateTime? toDate;
  late IntakeFrequency intakeFrequency;

  Medicine({
    this.id, required this.name,
    required this.fromDate, this.toDate,
    this.notes, IntakeFrequency? intakeFrequency,
  }) {
    this.intakeFrequency = intakeFrequency!=null ? intakeFrequency :
        IntakeFrequency.setNIntakesPerDay(1);
  }
}

/// A container for all [Medicine]s, it notify the UI when something change
class MedicinesModel extends ChangeNotifier {

  List<Medicine> medicinesList = [];
  bool loading = false;
  Medicine? currentMedicine;

  bool isEditing = false;
  bool isNew = false;

  loadData(dynamic inDatabaseWorker, {bool notify: true}) async {
    loading = true;
    medicinesList = await inDatabaseWorker.getAll();
    loading = false;
    notifyListeners();
  }

  viewMedicine(Medicine medicine, {bool editing: false}) {
    currentMedicine = medicine;
    isEditing = editing;
    isNew = false;
  }

  startNewMedicineCreation() {
    currentMedicine = Medicine(name: "", fromDate: DateTime.now());
    isEditing = isNew = true;
  }

  unsetMedicine() {
    currentMedicine = null;
    isEditing = isNew = false;
  }

  notify() {
    notifyListeners();
  }
}

MedicinesModel medicinesModel = MedicinesModel();