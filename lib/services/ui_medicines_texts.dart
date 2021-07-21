import 'package:flutter/material.dart';
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

  return "RIMANENTI OGGI: $nIntakesRemaining (su $nIntakesPerDay)";
}

/// [allIntakes] <- all
List<String> getNoIntakeText(Medicine medicine) {

  List<String> txt = ["Nessuna assunzione prevista per oggi"];

  DateTime today = getTodayDate();

  // get eventual last intake
  var res = medicineIntakesModel.getIntakes(endDate: today, medicine: medicine)
      ..sort((a, b) => a.day.isBefore(b.day) ? -1 : 1);
  MedicineIntake? lastIntake = res.isNotEmpty ? res.last : null;

  // get eventual next intake
  var res2 = medicineIntakesModel.getIntakes(startDate: today, medicine: medicine)
    ..sort((a, b) => a.day.isBefore(b.day) ? -1 : 1);
  MedicineIntake? nextIntake = res2.isNotEmpty ? res2.first : null;

  // add (eventual) last intake text
  if (lastIntake != null) {
    String t = "Ultima assunzione: ";
    int diffLastToday = today.difference(lastIntake.day).inDays;
    if (diffLastToday == 1) {
      t += "ieri";
    } else {
      t += "$diffLastToday giorni fa";
    }

    txt.add(t);
  }

  // add (eventual) next intake text
  if (nextIntake != null) {
    String t = "\nProssima assunzione: ";
    int diffTodayNext = nextIntake.day.difference(today).inDays;
    if (diffTodayNext == 1) {
      t += "domani";
    } else {
      t += "tra $diffTodayNext giorni";
    }

    txt.add(t);
  }

  return txt;
}



















