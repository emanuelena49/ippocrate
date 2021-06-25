


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
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

/// the object where it is stored the [IntakeFrequency] catched from
/// the [IntakeFrequencyInput]
IntakeFrequencyInputModel intakeFrequencyInputModel = IntakeFrequencyInputModel();

/// An input which permits to make the user insert a [IntakeFrequency].
/// The result, is saved in [intakeFrequencyInputModel]
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
        value: intakeFrequencyInputModel,
        child: Consumer<IntakeFrequencyInputModel>(
          builder: (context, freqModel, child) {
            return Column(
              children: [

                Text("Ogni quanto devi assumerlo?"),

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("1 VOLTA AL GIORNO"),
                  value: IntakeFrequencyOption.ONCE_PER_DAY,
                  groupValue: freqModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      freqModel.currentOption = inValue;
                      freqModel.currentValue =
                          IntakeFrequency.setNIntakesPerDay(1);
                      freqModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: Text("1 VOLTA AL MESE"),
                  value: IntakeFrequencyOption.ONCE_PER_MONTH,
                  groupValue: freqModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      freqModel.currentOption = inValue;
                      freqModel.currentValue =
                          IntakeFrequency.setNIntakesPerDay(30);
                      freqModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: LimitedBox(
                    maxHeight: 200.0,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        Text(" VOLTE AL GIORNO"),
                      ],
                    ),
                  ), 
                  value: IntakeFrequencyOption.N_TIMES_PER_DAY,
                  groupValue: freqModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      freqModel.currentOption = inValue;
                      // todo: instead of assigning null, try to read the form
                      freqModel.currentValue = null;
                      freqModel.notify();
                    }
                  },
                ),

                RadioListTile<IntakeFrequencyOption>(
                  title: LimitedBox(
                    maxHeight: 200.0,
                    child: Row(
                      children: [
                          Text("1 VOLTA OGNI "),
                          Container(
                            width: 50,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          Text(" GIORNI"),
                        ],
                    ),
                  ),
                  value: IntakeFrequencyOption.ONCE_EVERY_N_DAY,
                  groupValue: freqModel.currentOption,
                  onChanged: (inValue) {
                    if (inValue!=null) {
                      freqModel.currentOption = inValue;
                      // todo: instead of assigning null, try to read the form
                      freqModel.currentValue = null;
                      freqModel.notify();
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


