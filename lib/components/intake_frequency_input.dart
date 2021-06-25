


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:provider/provider.dart';

enum IntakeFrequencyOption {
  ONCE_PER_DAY, ONCE_PER_MONTH, N_TIMES_PER_DAY, ONCE_EVERY_N_DAY
}

class IntakeFrequencyInputModel extends ChangeNotifier {

  late IntakeFrequencyOption currentOption;
  IntakeFrequency? currentValue;

  notify() {
    notifyListeners();
  }
}

IntakeFrequencyInputModel intakeFrequencyInputModel = IntakeFrequencyInputModel();

class IntakeFrequencyInput extends StatelessWidget {

  IntakeFrequencyInput() {

    var medicineFreq = medicinesModel.currentMedicine!.intakeFrequency;
    var _currentOption;

    if (medicineFreq.nIntakesPerDay == 1 &&
        medicineFreq.nDaysBetweenIntakes == 1) {

      _currentOption = IntakeFrequencyOption.ONCE_PER_DAY;
    } else if (medicineFreq.nIntakesPerDay == 1 &&
        medicineFreq.nDaysBetweenIntakes == 30) {

      _currentOption = IntakeFrequencyOption.ONCE_PER_MONTH;
    } else if (medicineFreq.nIntakesPerDay > 1) {

      _currentOption = IntakeFrequencyOption.N_TIMES_PER_DAY;
    } else {

      _currentOption = IntakeFrequencyOption.ONCE_EVERY_N_DAY;
    }

    intakeFrequencyInputModel.currentOption = _currentOption;
    intakeFrequencyInputModel.currentValue = medicineFreq;
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: ChangeNotifierProvider.value(
        value: medicinesModel,
        child: Consumer<MedicinesModel>(
          builder: (context, notesModel, child) {
            return Column(
              children: [

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("1 VOLTA AL GIORNO"),
                  value: IntakeFrequencyOption.ONCE_PER_DAY,
                  groupValue: intakeFrequencyInputModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      intakeFrequencyInputModel.currentOption = inValue;
                      intakeFrequencyInputModel.currentValue =
                          IntakeFrequency.setNIntakesPerDay(1);
                      intakeFrequencyInputModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("1 VOLTA AL MESE"),
                  value: IntakeFrequencyOption.ONCE_PER_MONTH,
                  groupValue: intakeFrequencyInputModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      intakeFrequencyInputModel.currentOption = inValue;
                      intakeFrequencyInputModel.currentValue =
                          IntakeFrequency.setNIntakesPerDay(30);
                      intakeFrequencyInputModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("N VOLTE AL GIORNO"),
                  value: IntakeFrequencyOption.N_TIMES_PER_DAY,
                  groupValue: intakeFrequencyInputModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      intakeFrequencyInputModel.currentOption = inValue;
                      // todo: instead of assigning null, try to read the form
                      intakeFrequencyInputModel.currentValue = null;
                      intakeFrequencyInputModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("1 VOLTA OGNI N GIORNI"),
                  value: IntakeFrequencyOption.ONCE_EVERY_N_DAY,
                  groupValue: intakeFrequencyInputModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      intakeFrequencyInputModel.currentOption = inValue;
                      // todo: instead of assigning null, try to read the form
                      intakeFrequencyInputModel.currentValue = null;
                      intakeFrequencyInputModel.notify();
                    }
                  },
                ),

              ],
            );
          }
        ),
      ),
    );
  }
}


