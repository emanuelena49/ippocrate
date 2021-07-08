import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/components/notes_input.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/generate_intakes_from_medicine.dart';


final GlobalKey<FormState> formKey = GlobalKey<FormState>();

/// The button to submit the insertion/the edit of a [Medicine]. It handles
/// all the save/update stuff. Place it inside a [Consumer]<[MedicinesModel]>.
class MedicineFormSubmitButton extends StatelessWidget {

  late Medicine initialValue;

  MedicineFormSubmitButton() {
    initialValue = medicinesModel.currentMedicine!.clone();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
      ),
      child: Text("conferma"),
      onPressed: () async {

        // var x = medicinesModel.currentMedicine!;
        // var y = intakeFrequencyInputModel;

        // validate form
        if(!formKey.currentState!.validate()){
          return;
        }

        var medicine = medicinesModel.currentMedicine!;

        /*
        // add intake frequency
        medicine.intakeFrequency =
          intakeFrequencyInputModel.currentValue!;*/

        // insert the new element or update existent
        MedicinesDBWorker dbMedicines = MedicinesDBWorker();
        if (medicinesModel.isNew) {
          var ok = await dbMedicines.create(medicine);
        } else {
          var ok = await dbMedicines.update(medicine);
        }


        MedicineIntakesDBWorker dbIntakes = MedicineIntakesDBWorker();
        bool generateNewIntakes = false;

        // check if I should re-generate intakes
        bool regenerateIntakes =
          shouldIntakesBeRegenerated(initialValue, medicine);

        if (!medicinesModel.isNew && regenerateIntakes) {

          // if a medicine is not new and [...],
          // I remove all related intakes (to rebuild them from sketch then)

          List<MedicineIntake> intakes =
            await dbIntakes.getAllMedicineIntakes(medicine);

          for (var i in intakes) {
            await dbIntakes.delete(i.id!);
          }

          // ok, I even have to generate new intakes
          generateNewIntakes = true;

        } else if (medicinesModel.isNew) {

          // I have to generate new intakes because the item is new
          generateNewIntakes = true;
        }

        // (eventually) generate the new intakes  and save them
        if (generateNewIntakes) {

          List<MedicineIntake> intakes = generateIntakesFromMedicine(
              medicine,
              endDate: medicine.endDate!=null ?
                medicine.endDate :
                DateTime.now().add(Duration(days: 100))
          );

          for (var i in intakes) {
            await dbIntakes.create(i);
          }
        }

        // var x = await dbIntakes.getAll();
        // debugPrint(x.toString());
        
        // update models
        medicinesModel.loadData(dbMedicines);
        medicineIntakesModel.loadData(dbIntakes);

        // Navigator.pop(context);
        screensModel.back(context);
      },
    );
  }
}


/// The button to manage the insertion/the edit of a [Medicine].
/// Place it inside a [Consumer]<[MedicinesModel]>.
class MedicineForm extends StatelessWidget {

  late Medicine medicine;

  @override
  Widget build(BuildContext context) {

    medicine = medicinesModel.currentMedicine!;

    return Form(
      key: formKey,
      child: ListView(
        children: [

          // name input
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(
                labelText: "Nome Medicinale",
                hintText: "ex. Integratori Alimentari",
              ),
              initialValue: medicine.name,
              validator: (inValue) {
                if (inValue == "") {
                  return "Aggiungi un nome al medicinale";
                }
                return null;
              },
              onChanged: (inValue) {
                medicine.name = inValue;
              },
            ),
          ),

          // intake interval
          _IntakeIntervalInput(medicine: medicine),

          // intake frequency input
          _MedicineIntakeFrequencyInput(medicine: medicine,),

          NotesInput(obj: medicine, model: medicinesModel),

          ListTile(title: Text("...todo notifications...")),
        ],
      ),
    );
  }
}

/// An input for a [DateTime] iterval to get [Medicine.startDate] and
/// [Medicine.endDate].
class _IntakeIntervalInput extends StatelessWidget {

  Medicine medicine;
  _IntakeIntervalInput({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: LimitedBox(
        maxHeight: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 150,
              child: DateTimePicker(
                type: DateTimePickerType.date,
                dateLabelText: 'Da ',
                initialValue: medicine.startDate.toString(),
                initialDate: medicine.startDate,
                firstDate: medicine.startDate.isBefore(getTodayDate()) ?
                medicine.startDate : getTodayDate(),
                lastDate: DateTime(2100),
                decoration: const InputDecoration(
                    errorMaxLines: 3),

                onChanged: (val) {
                  if (val != null && val != "") {
                    medicine.startDate = DateTime.parse(val);
                  }
                },

                validator: (val) {

                  // check it is not null
                  if (val == null || val == "") {
                    return "La data d'inizio non può essere nulla";
                  }

                  // check it is after the end date
                  DateTime newStart = getPureDate(DateTime.parse(val));
                  if (medicine.endDate != null &&
                      newStart.isAfter(medicine.endDate!)) {
                    return "La data d'inizio non può venire dopo quella di fine";
                  }

                  return null;
                },
                onSaved: (val) {

                  if (val != null) {
                    medicine.startDate = getPureDate(DateTime.parse(val));
                  }
                },
              ),
            ),

            Container(
              width: 150,
              // margin: EdgeInsets.only(right: 20),
              child: DateTimePicker(
                type: DateTimePickerType.date,
                dateLabelText: "a ",
                initialValue: medicine.endDate != null ?
                medicine.endDate!.toString() : "",
                firstDate: medicine.startDate.isBefore(getTodayDate()) ?
                medicine.startDate : getTodayDate(),
                lastDate: DateTime(2100),
                decoration: const InputDecoration(
                    errorMaxLines: 3),
                onChanged: (val) {
                  medicine.endDate = (val != null && val != "") ?
                  DateTime.parse(val) : null;
                },
                validator: (val) {

                  // todo: find a more elegant solution for the intakes generation problem

                  // check it is not null
                  if (val == null || val == "") {
                    return "La data di fine non può essere nulla";
                  }

                  //if (val != null && val != "") {
                  // check it is after the end date
                  DateTime newEnd = getPureDate(DateTime.parse(val));
                  if (newEnd.isBefore(medicine.startDate)) {
                    debugPrint(newEnd.toString());
                    debugPrint(medicine.startDate.toString());
                    return "La data di fine non può venire prima di quella d'inizio";
                  }
                  //}

                  return null;
                },
                onSaved: (val) {
                  medicine.endDate = val!=null ? getPureDate(DateTime.parse(val)) : null;
                },
              ),
            ),
          ],

        ),
      ),
    );
  }
}

/// The different types of [IntakeFrequency]
enum _IntakeFrequencyOption {
  ONCE_PER_DAY, ONCE_PER_MONTH, N_TIMES_PER_DAY, ONCE_EVERY_N_DAY
}

/// The form to get the [Medicine.intakeFrequency]. It offers to the user
/// some configurable options [_IntakeFrequencyOption] from which he can
/// choose
class _MedicineIntakeFrequencyInput extends StatefulWidget {
  Medicine medicine;
  _MedicineIntakeFrequencyInput({required this.medicine});

  @override
  State<StatefulWidget> createState() => _MedicineIntakeFrequencyInputState();
}

class _MedicineIntakeFrequencyInputState extends State<_MedicineIntakeFrequencyInput> {

  late Medicine medicine;
  late _IntakeFrequencyOption option;

  @override
  Widget build(BuildContext context) {

    medicine = widget.medicine;
    option = _calculateCurrentOption();

    return ListTile(
        title: Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              RadioListTile<_IntakeFrequencyOption> (
                title: Text("1 VOLTA AL GIORNO"),
                // dense: true,
                value: _IntakeFrequencyOption.ONCE_PER_DAY,
                groupValue: option,
                onChanged: (inValue) {
                  if (inValue!=null) setState(() {
                    medicine.intakeFrequency =
                        IntakeFrequency.setNIntakesPerDay(1);
                  });
                },
              ),

              RadioListTile<_IntakeFrequencyOption> (
                title: Text("1 VOLTA AL MESE"),
                value: _IntakeFrequencyOption.ONCE_PER_MONTH,
                groupValue: option,
                onChanged: (inValue) {
                  if (inValue!=null) setState(() {
                    medicine.intakeFrequency =
                        IntakeFrequency.setNDaysBetweenIntakes(30);
                  });
                },
              ),


              RadioListTile<_IntakeFrequencyOption> (
                value: _IntakeFrequencyOption.N_TIMES_PER_DAY,
                groupValue: option,
                onChanged: (inValue) {
                  if (inValue!=null) setState(() {
                    medicine.intakeFrequency =
                        IntakeFrequency.setNIntakesPerDay(3);
                  });
                },
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
                          initialValue:
                            option==_IntakeFrequencyOption.N_TIMES_PER_DAY ?
                            medicine.intakeFrequency.nIntakesPerDay.toString() :
                            "",
                          validator: (inValue) {

                            if (option!=_IntakeFrequencyOption.N_TIMES_PER_DAY) {
                              return null;
                            }

                            if (inValue == null) {
                              return "Questo campo non può essere lasciato vuoto";
                            }

                            int? valAsNum = int.tryParse(inValue);
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
                              setState(() {
                                medicine.intakeFrequency =
                                    IntakeFrequency.setNIntakesPerDay(valAsNum);
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                        ),
                      ),
                      Text(" VOLTE AL GIORNO"),
                    ],
                  ),
                ),
              ),


              RadioListTile<_IntakeFrequencyOption> (
                value: _IntakeFrequencyOption.ONCE_EVERY_N_DAY,
                groupValue: option,
                onChanged: (inValue) {
                  if (inValue!=null) {
                    setState(() {
                      medicine.intakeFrequency =
                          IntakeFrequency.setNDaysBetweenIntakes(7);
                    });
                  }
                },
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
                          initialValue:
                            option==_IntakeFrequencyOption.ONCE_EVERY_N_DAY ?
                            medicine.intakeFrequency.nDaysBetweenIntakes.toString() :
                            "",
                          validator: (inValue) {

                            if (option!=_IntakeFrequencyOption.ONCE_EVERY_N_DAY) {
                              return null;
                            }

                            if (inValue == null) {
                              return "Questo campo non può essere lasciato vuoto";
                            }

                            int? valAsNum = int.tryParse(inValue);
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

                              setState(() {
                                medicine.intakeFrequency =
                                    IntakeFrequency.setNDaysBetweenIntakes(valAsNum);
                              });

                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                        ),
                      ),
                      Text(" GIORNI"),
                    ],
                  ),
                ),
              ),


            ],
          )
        )
    );
  }

  _IntakeFrequencyOption _calculateCurrentOption() {

    var medicineFreq = medicine.intakeFrequency;

    if (medicineFreq.nIntakesPerDay == 1 &&
        medicineFreq.nDaysBetweenIntakes == 1) {

      return _IntakeFrequencyOption.ONCE_PER_DAY;
    } else if (medicineFreq.nIntakesPerDay == 1 &&
        medicineFreq.nDaysBetweenIntakes == 30) {

      return _IntakeFrequencyOption.ONCE_PER_MONTH;
    } else if (medicineFreq.nIntakesPerDay > 1) {

      return _IntakeFrequencyOption.N_TIMES_PER_DAY;
    } else {

      return _IntakeFrequencyOption.ONCE_EVERY_N_DAY;
    }
  }

}

