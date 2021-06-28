import 'package:intl/intl.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';

/// Get the text which describes the intake interval of a [Medicine]
/// (ex. "DA ... A ...")
String getIntervalText(Medicine medicine) {

  DateTime from = medicine.startDate;
  DateTime? to = medicine.endDate;

  DateFormat format = DateFormat('dd/MM');

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month
        && d1.day == d2.day;
  }

  String label;
  if (isSameDate(from, DateTime.now())) {
    label = "DA OGGI";
  } else {
    label = "DAL ${format.format(from)}";
  }

  if (to != null) {
    label += " AL ${format.format(to)}";
  }

  return label;
}

/// Get the text which describes how many intakes per day a [Medicine] needs
/// (ex. "5 VOLTE AL GIORNO", "1 VOLTA OGNI 30 GIORNI" )
String getIntakesPerDayText(Medicine medicine) {

  int nIntakesPerDay = medicine.intakeFrequency.nIntakesPerDay;
  int nDaysBetweenIntakes = medicine.intakeFrequency.nDaysBetweenIntakes;

  String pt1="", pt2="";

  if (nIntakesPerDay == 1) {
    pt1 = "1 VOLTA";
  } else {
    pt1 = "$nIntakesPerDay VOLTE";
  }

  if (nDaysBetweenIntakes == 1) {
    pt2 = " AL GIORNO";
  } else {
    pt2 = " OGNI $nDaysBetweenIntakes GIORNI";
  }

  return pt1 + pt2;
}

/// Get the text which describes how many [MedicineIntake] should be done today
/// (ex. "RIMANENTI OGGI: 2 (su 3)")
String getRemainingMedicineIntakes(MedicineIntake intake) {

  int nIntakesPerDay = intake.medicine.intakeFrequency.nIntakesPerDay;
  int nIntakesRemaining = intake.getMissingIntakes();

  return "RIMANENTI: $nIntakesRemaining (su $nIntakesPerDay)";
}

String getNoIntakeText(Medicine medicine, List<MedicineIntake> allIntakes) {

  String txt = "Nessuna assunzione prevista per oggi";

  DateTime today = getTodayDate();
  DateTime startDate = medicine.startDate;
  DateTime? endDate = medicine.endDate;
  int nDaysBetweenIntakes = medicine.intakeFrequency.nDaysBetweenIntakes;

  // parse last and next intake
  MedicineIntake? lastIntake, nextIntake;
  for (var i in allIntakes) {

    if (i.day.isBefore(today)) {
      lastIntake = i;
    }

    if (i.day.isAfter(today)) {
      nextIntake = i;
      break;
    }
  }

  // add (eventual) last intake text
  if (lastIntake != null) {
    txt += "Ultima assunzione: ";
    int diffLastToday = today.difference(lastIntake.day).inDays;
    if (diffLastToday == 1) {
      txt += "ieri";
    } else {
      txt += "$diffLastToday giorni fa";
    }
  }

  // add (eventual) next intake text
  if (nextIntake != null) {
    txt += "Prossima assunzione: ";
    int diffTodayNext = nextIntake.day.difference(today).inDays;
    if (diffTodayNext == 1) {
      txt += "domani";
    } else {
      txt += "tra $diffTodayNext giorni";
    }
  }

  return txt;
}



















