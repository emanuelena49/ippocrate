import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/generate_intakes_from_medicine.dart';

import 'intake_frequency_input.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

/// The button to submit the insertion/the edit of a [Medicine]. It handles
/// all the save/update stuff. Place it inside a [Consumer]<[MedicinesModel]>.
class MedicineFormSubmitButton extends StatelessWidget {

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

        // add intake frequency
        medicine.intakeFrequency =
        intakeFrequencyInputModel.currentValue!;

        // insert the new element
        MedicinesDBWorker dbMedicines = MedicinesDBWorker();
        var ok = await dbMedicines.create(medicine);

        // generate the intakes
        List<MedicineIntake> intakes = generateIntakesFromMedicine(
            medicine,
            endDate: medicine.endDate!=null ?
              medicine.endDate :
              DateTime.now().add(Duration(days: 100))
        );

        // save them
        MedicineIntakesDBWorker dbIntakes = MedicineIntakesDBWorker();
        for (var i in intakes) {
          await dbIntakes.create(i);
        }

        // var x = await dbIntakes.getAll();
        // debugPrint(x.toString());
        
        // update models
        medicinesModel.loadData(dbMedicines);
        medicineIntakesModel.loadData(dbIntakes);

        Navigator.pop(context);
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
          ListTile(
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
                      initialDate: medicine.startDate,
                      firstDate: DateTime.now(),
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
                        DateTime newStart = DateTime.parse(val);
                        if (medicine.endDate != null &&
                            medicine.endDate!.isBefore(newStart)) {
                          return "La data d'inizio non può venire dopo quella di fine";
                        }

                        return null;
                      },
                      onSaved: (val) {

                        if (val != null) {
                          medicine.startDate = DateTime.parse(val);
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
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      decoration: const InputDecoration(
                          errorMaxLines: 3),
                      onChanged: (val) {
                        medicine.endDate = (val != null && val != "") ?
                        DateTime.parse(val) : null;
                      },
                      validator: (val) {

                        if (val != null && val != "") {
                          // check it is after the end date
                          DateTime newEnd = DateTime.parse(val);
                          if (medicine.startDate.isAfter(newEnd)) {
                            return "La data di fine non può venire prima di quella d'inizio";
                          }
                        }

                        return null;
                      },
                      onSaved: (val) {
                        medicine.endDate = val!=null ? DateTime.parse(val) : null;
                      },
                    ),
                  ),
                ],

              ),
            ),
          ),

          // intake frequency input
          IntakeFrequencyInput(),

          // notes input
          ListTile(
            title: (medicine.notes == null) ?
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black54,
              ),
              child: Text("Aggiungi Nota"),
              onPressed: () {
                medicine.notes = "";
                medicinesModel.notify();
              },
            ) :
            TextFormField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                alignLabelWithHint: true,
                labelText: "Scrivi nota",
                hintText: "ex. Da prendere solo dopo i pasti",
              ),
              maxLines: 4,
              initialValue: medicine.notes!,
              validator: (inValue) {
                return null;
              },
              onChanged: (inValue) {
                medicine.notes = inValue;
              },
              onSaved: (inValue) {
                if (inValue=="") {
                  medicine.notes = null;
                  medicinesModel.notify();
                }
              },
            ),
          ),

          ListTile(title: Text("...todo notifications...")),
        ],
      ),
    );
  }
}