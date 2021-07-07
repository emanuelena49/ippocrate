import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/common/model.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:intl/intl.dart';
import 'package:ippocrate/services/datetime.dart';

/// A daily intake for [Medicine]. It is the "concrete" representation,
/// so the single set of intakes for one day.
/// The user can perform the intakes until he reach the limit
/// set in [Medicine.intakeFrequency].
class MedicineIntake extends HasId {
  int? id;
  final Medicine medicine;
  final DateTime day;
  int nIntakesDone;

  MedicineIntake({
    this.id, required this.medicine,
    required this.day, this.nIntakesDone: 0
  });

  int getTotalIntakes() {
    return medicine.intakeFrequency.nIntakesPerDay;
  }

  int getMissingIntakes() {
    return getTotalIntakes() - nIntakesDone;
  }

  doOneIntake() {
    if (getMissingIntakes() > 0) {
      nIntakesDone++;
    } else {
      throw Exception("You can't perform an intake if zero are missing");
    }
  }
}

/// A model with a list of [MedicineIntake]s. It permits you
/// to load data according to several parameters
class MedicineIntakesModel extends Model {

  List<MedicineIntake> intakes = [];
  bool loading = false;

  /// Load all [MedicineIntake]s from the db
  loadData(MedicineIntakesDBWorker inDatabaseWorker, {bool notify: true}) async {

    loading = true;

    // get all intakes
    intakes = await inDatabaseWorker.getAll();

    // sort
    sortByRemainingIntakes(notify: false);

    loading = false;
    if (notify) notifyListeners();
  }

  /// get the intakes according to some criteria. You can set
  /// - a time interval from [startDate] (included) to [endDate] (included)
  /// - a certain [medicine]
  /// - the possibility to exclude the already done (setting true [onlyNotDone])
  List<MedicineIntake> getIntakes({DateTime? startDate, DateTime? endDate,
    Medicine? medicine, bool onlyNotDone: false,}) {

    return intakes.where((i) {

      if (startDate!=null && i.day.isBefore(startDate)) {
        return false;
      }

      if (endDate!=null && i.day.isAfter(endDate)) {
        return false;
      }

      if (medicine!=null && i.medicine.id!=medicine.id) {
        return false;
      }

      if (onlyNotDone && i.getMissingIntakes()<1) {
        return false;
      }

      return true;
    }).toList();
  }

  /*
  /// load the data from a db. You can specify a [day] (today is default),
  /// a [medicine] and a bool param [onlyNotDone] to filter only elements
  /// which [MedicineIntake.getMissingIntakes] is > 0.
  loadData(MedicineIntakesDBWorker inDatabaseWorker, {DateTime? day,
    Medicine? medicine, bool onlyNotDone: false, bool notify: true}) async {

    loading = true;

    // save settings
    this.day = day;
    this.medicine = medicine;
    this.onlyNotDone = onlyNotDone;

    // get intakes from db according to settings
    intakes = await inDatabaseWorker.getDailyIntakes(
        day: day, medicine: medicine, onlyNotDone: onlyNotDone);

    // sort
    sortByRemainingIntakes(notify: false);

    loading = false;

    if (notify) notifyListeners();
  }

  loadAllMedicineData(MedicineIntakesDBWorker inDatabaseWorker,
      Medicine medicine, {bool notify: true}) async {

    loading = true;
    this.day = null;
    this.medicine = medicine;
    this.onlyNotDone = false;

    // get intakes from db
    intakes = await inDatabaseWorker.getAllMedicineIntakes(medicine);

    loading = false;

    if (notify) notifyListeners();
  }*/

  /// Sort the current list by [MedicineIntake.getMissingIntakes]
  /// (decreasing order)
  sortByRemainingIntakes({notify: true}) {

    intakes.sort((MedicineIntake a, MedicineIntake b)
      // (decreasing order)
      => b.getMissingIntakes().compareTo(a.getMissingIntakes()));

    if (notify) notifyListeners();
  }
}


MedicineIntakesModel medicineIntakesModel = new MedicineIntakesModel();

// (I use this one only for one medicinal queries)
// MedicineIntakesModel medicineIntakesModel2 = new MedicineIntakesModel();

// TODO: implement a more elegant solution