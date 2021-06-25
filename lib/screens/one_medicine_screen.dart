import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ippocrate/components/intake_frequency_input.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/medicines_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class OneMedicineScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: medicinesModel,
        child: Consumer<MedicinesModel>(
          builder: (context, notesModel, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black54,
                title: Text(
                  medicinesModel.isNew ?
                    "Nuovo Medicinale" :
                    medicinesModel.isEditing ?
                        "Modifica Medicinale" :
                        "Medicinale"
                ),
                actions: [
                  medicinesModel.isEditing ?
                      // form confirm button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: Text("conferma"),
                          onPressed: () async {

                            if(!formKey.currentState!.validate()){
                              return;
                            }

                            MedicinesDBWorker db = MedicinesDBWorker();
                            var ok = await db.create(medicinesModel.currentMedicine!);
                            await medicinesModel.loadData(db);
                            Navigator.pop(context);
                          },
                        ),
                      ) :

                      // normal screen actions
                      IconButton(
                        icon: Icon(Icons.more),
                        onPressed: () {},
                      )
                ],
              ),
              body: MedicineForm(),
            );
          }
        )
    );
  }
}

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
                      initialDate: medicine.fromDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      onChanged: (val) {
                        if (val != null) {
                          medicine.fromDate = DateTime.parse(val);
                        }
                      },
                      validator: (val) {

                        // check it is not null
                        if (val == null) {
                          return "La data d'inizio non può essere nulla";
                        }

                        // check it is after the end date
                        DateTime newStart = DateTime.parse(val);
                        if (medicine.toDate != null &&
                            medicine.toDate!.isBefore(newStart)) {
                          return "La data d'inizio non può venire dopo quella di fine";
                        }

                        return null;
                      },
                      onSaved: (val) {

                        if (val != null) {
                          medicine.fromDate = DateTime.parse(val);
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
                        initialValue: medicine.toDate != null ?
                        medicine.toDate!.toString() : "",
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        onChanged: (val) {
                          medicine.toDate = val!=null ? DateTime.parse(val) : null;
                        },
                        validator: (val) {

                          if (val != null) {
                            // check it is after the end date
                            DateTime newEnd = DateTime.parse(val);
                            if (medicine.fromDate.isAfter(newEnd)) {
                              return "La data di fine non può venire prima di quella d'inizio";
                            }
                          }

                          return null;
                        },
                        onSaved: (val) {
                          medicine.toDate = val!=null ? DateTime.parse(val) : null;
                        },
                      ),
                  ),
                ],

              ),
            ),
          ),

          /*
          ListTile(
            title: DateTimePicker(
              type: DateTimePickerType.date,
              dateLabelText: 'Da ',
              initialDate: medicine.fromDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              onChanged: (val) {
                if (val != null) {
                  medicine.fromDate = DateTime.parse(val);
                }
              },
              validator: (val) {

                // check it is not null
                if (val == null) {
                  return "La data d'inizio non può essere nulla";
                }

                // check it is after the end date
                DateTime newStart = DateTime.parse(val);
                if (medicine.toDate != null &&
                    medicine.toDate!.isBefore(newStart)) {
                  return "La data d'inizio non può venire dopo quella di fine";
                }

                return null;
              },
              onSaved: (val) {

                if (val != null) {
                  medicine.fromDate = DateTime.parse(val);
                }
              },
            ),
          ),
          ListTile(
            title: DateTimePicker(
              type: DateTimePickerType.date,
              dateLabelText: "a ",
              initialValue: medicine.toDate != null ?
              medicine.toDate!.toString() : "",
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              onChanged: (val) {
                medicine.toDate = val!=null ? DateTime.parse(val) : null;
              },
              validator: (val) {

                if (val != null) {
                  // check it is after the end date
                  DateTime newEnd = DateTime.parse(val);
                  if (medicine.fromDate.isAfter(newEnd)) {
                    return "La data di fine non può venire prima di quella d'inizio";
                  }
                }

                return null;
              },
              onSaved: (val) {
                medicine.toDate = val!=null ? DateTime.parse(val) : null;
              },
            ),
          ),
          */


          // intake frequency input
          IntakeFrequencyInput(),

          // notes input
          ListTile(
            title: (medicine.notes == null) ?
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white24,
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


// TODO: build wireframe and make
class MedicineReadOnly extends StatelessWidget {

  late Medicine medicine;
  @override
  Widget build(BuildContext context) {

    medicine = medicinesModel.currentMedicine!;

    return ListView(
      children: [

        // Medicine Name
        Text(
          medicine.name,
          style: Theme.of(context).textTheme.headline1,
        ),

        SizedBox(height: 10,),

        Text(
          "Frequenza assunzioni e periodo",
          style: Theme.of(context).textTheme.headline3,
        ),
        // Intakes info + interval
        Text(
          getIntervalText(medicine),
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          getIntakesPerDayText(medicine),
          style: Theme.of(context).textTheme.headline4,
        ),

        SizedBox(height: 20,)
      ],
    );
  }
}

