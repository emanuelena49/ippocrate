import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';


/// Given a [Medicine], generate all the [MedicineIntake]s 
/// (according to what specified in [Medicine.intakeFrequency])
List<MedicineIntake> generateIntakesFromMedicine(Medicine medicine,
    {DateTime? startDate, DateTime? endDate}) {
  
  // get start and end date
  startDate = startDate!=null ? startDate : medicine.startDate;
  endDate = endDate!=null ? endDate : medicine.endDate;
  
  if (endDate == null) {
    throw Exception("Can't generate infinite intakes");
  }
  
  // get the frequency options
  int nIntakesPerDay=medicine.intakeFrequency.nIntakesPerDay, 
      nDaysBetweenIntakes=medicine.intakeFrequency.nDaysBetweenIntakes;
  
  // ensure they are pure
  startDate = getPureDate(startDate);
  endDate = getPureDate(endDate);

  // create the list and fill it
  List<MedicineIntake> intakes = [];
  DateTime d = startDate;
  while (d.isBefore(endDate) || d.isAtSameMomentAs(endDate)) {

    intakes.add(MedicineIntake(medicine: medicine, day: d));

    // increment adding the value specified in frequency options
    d = d.add(Duration(days: nDaysBetweenIntakes));
  }

  return intakes;
}