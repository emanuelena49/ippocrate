


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

  int? lastNDaysInserted = 1;
  int? lastNPerDaysInserted = 1;

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
            return Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Ogni quanto devi assumerlo?"),
                  ),

                  RadioListTile<IntakeFrequencyOption> (
                    title: Text("1 VOLTA AL GIORNO"),
                    // dense: true,
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

                  RadioListTile<IntakeFrequencyOption> (
                    title: Text("1 VOLTA AL MESE"),
                    // dense: true,
                    value: IntakeFrequencyOption.ONCE_PER_MONTH,
                    groupValue: freqModel.currentOption,
                    onChanged: (inValue) {
                      if (inValue!=null) {
                        freqModel.currentOption = inValue;
                        freqModel.currentValue =
                            IntakeFrequency.setNDaysBetweenIntakes(30);
                        freqModel.notify();
                      }
                    },
                  ),

                  RadioListTile<IntakeFrequencyOption> (
                    // dense: true,
                    title: LimitedBox(
                      maxHeight: 64.0,
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
                              initialValue: freqModel.currentValue!=null ?
                                freqModel.currentValue!.nIntakesPerDay.toString() :
                                "",
                              validator: (inValue) {
                                if (inValue == null && freqModel.currentOption==IntakeFrequencyOption.ONCE_EVERY_N_DAY) {
                                  return "Questo campo non può essere lasciato vuoto";
                                }

                                int? valAsNum = int.tryParse(inValue!);
                                if (valAsNum == null) {
                                  return "Inserisci un numero intero";
                                }

                                if (valAsNum<1) {
                                  return "Inserisciun numero maggiore o uguale a 1";
                                }

                                return null;
                              },
                              onChanged: (inValue) {
                                try {
                                  int valAsNum = int.parse(inValue);
                                  freqModel.currentValue =
                                      IntakeFrequency.setNIntakesPerDay(valAsNum);
                                  freqModel.lastNPerDaysInserted = valAsNum;
                                  freqModel.currentOption =
                                      IntakeFrequencyOption.N_TIMES_PER_DAY;
                                  freqModel.notify();
                                } catch (e) {
                                  debugPrint("ERROR, input is not a num: $inValue");
                                  debugPrint(e.toString());
                                }
                              },
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

                        if (freqModel.lastNPerDaysInserted != null) {
                          freqModel.currentValue =
                              IntakeFrequency.setNIntakesPerDay(
                                  freqModel.lastNPerDaysInserted);
                        }

                        freqModel.notify();
                      }
                    },
                  ),

                  RadioListTile<IntakeFrequencyOption> (
                    // dense: true,
                    title: LimitedBox(
                      maxHeight: 64.0,
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
                                initialValue: freqModel.currentValue!=null ?
                                  freqModel.currentValue!.nDaysBetweenIntakes.toString() :
                                  "",
                                validator: (inValue) {
                                  if (inValue == null && freqModel.currentOption==IntakeFrequencyOption.ONCE_EVERY_N_DAY) {
                                    return "Questo campo non può essere lasciato vuoto";
                                  }

                                  int? valAsNum = int.tryParse(inValue!);
                                  if (valAsNum == null) {
                                    return "Inserisci un numero intero";
                                  }

                                  if (valAsNum<1) {
                                    return "Inserisci un numero maggiore o uguale a 1";
                                  }

                                  return null;
                                },
                                onChanged: (inValue) {
                                  try {
                                    int valAsNum = int.parse(inValue);

                                    freqModel.currentValue =
                                        IntakeFrequency.setNDaysBetweenIntakes(valAsNum);
                                    freqModel.lastNDaysInserted = valAsNum;
                                    freqModel.currentOption =
                                        IntakeFrequencyOption.ONCE_EVERY_N_DAY;
                                    freqModel.notify();

                                  } catch (e) {
                                    debugPrint("ERROR, input is not a num: $inValue");
                                    debugPrint(e.toString());
                                  }
                                },
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

                        if (freqModel.lastNDaysInserted != null) {
                          freqModel.currentValue =
                              IntakeFrequency.setNDaysBetweenIntakes(
                                  freqModel.lastNDaysInserted);
                        }

                        freqModel.notify();
                      }
                    },
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}


