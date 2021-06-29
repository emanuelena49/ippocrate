import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
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
class MedicineIntakesModel extends ChangeNotifier {

  List<MedicineIntake> intakes = [];
  bool loading = false;

  DateTime? day;
  Medicine? medicine;
  bool onlyNotDone = false;

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
  }

  /// Sort the current list by [MedicineIntake.getMissingIntakes]
  /// (decreasing order)
  sortByRemainingIntakes({notify: true}) {

    intakes.sort((MedicineIntake a, MedicineIntake b)
      // (decreasing order)
      => b.getMissingIntakes().compareTo(a.getMissingIntakes()));

    if (notify) notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}


MedicineIntakesModel medicineIntakesModel = new MedicineIntakesModel();

// (I use this one only for one medicinal queries)
MedicineIntakesModel medicineIntakesModel2 = new MedicineIntakesModel();