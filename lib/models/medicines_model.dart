import 'package:flutter/material.dart';
import 'package:ippocrate/common/clonable.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';

/// the intake frequency for a single medicine
class IntakeFrequency implements Clonable {
  final int nIntakesPerDay;
  final int nDaysBetweenIntakes;

  IntakeFrequency({this.nIntakesPerDay: 1, this.nDaysBetweenIntakes:1});

  factory IntakeFrequency.setNIntakesPerDay(nIntakes) {
    return IntakeFrequency(nIntakesPerDay: nIntakes);
  }

  factory IntakeFrequency.setNDaysBetweenIntakes(nIntakes) {
    return IntakeFrequency(nDaysBetweenIntakes: nIntakes);
  }

  /// Check if this and another [IntakeFrequency] are the same
  bool compare(IntakeFrequency frequency) {
    return (frequency.nIntakesPerDay == nIntakesPerDay &&
        frequency.nDaysBetweenIntakes == nDaysBetweenIntakes) ? true : false;
  }

  @override
  IntakeFrequency clone() {
    return IntakeFrequency(
        nIntakesPerDay: nIntakesPerDay,
        nDaysBetweenIntakes: nDaysBetweenIntakes);
  }
}

/// a single medicine
class Medicine implements HasId, Clonable {

  @override
  int? id;

  String name;
  String? notes;
  DateTime startDate;
  DateTime? endDate;
  late IntakeFrequency intakeFrequency;

  Medicine({
    this.id, required this.name,
    required this.startDate, this.endDate,
    this.notes, IntakeFrequency? intakeFrequency,
  }) {
    this.intakeFrequency = intakeFrequency!=null ? intakeFrequency :
        IntakeFrequency.setNIntakesPerDay(1);
  }

  @override
  Medicine clone({bool includeId: false}) {

    var m = Medicine(name: name, startDate: startDate, endDate: endDate,
        notes: notes, intakeFrequency: intakeFrequency.clone());

    if (includeId) {
      m.id = id;
    }

    return m;
  }
}

/// A container for all [Medicine]s, it notify the UI when something change
class MedicinesModel extends ChangeNotifier {

  List<Medicine> medicinesList = [];
  bool loading = false;
  Medicine? currentMedicine;

  bool isEditing = false;
  bool isNew = false;

  loadData(MedicinesDBWorker inDatabaseWorker, {bool notify: true}) async {
    loading = true;
    medicinesList = await inDatabaseWorker.getAll();
    loading = false;
    if (notify) notifyListeners();
  }

  viewMedicine(Medicine medicine, {bool editing: false}) {
    currentMedicine = medicine;
    isEditing = editing;
    isNew = false;
  }

  startNewMedicineCreation() {
    currentMedicine = Medicine(name: "", startDate: DateTime.now());
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