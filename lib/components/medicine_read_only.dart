import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';


// TODO: build wireframe and make
class MedicineReadOnly extends StatelessWidget {

  late Medicine medicine;
  MedicineIntake? eventualIntake;

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

        // Intakes info + interval
        Text(
          getIntervalText(medicine),
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          getIntakesPerDayText(medicine),
          style: Theme.of(context).textTheme.headline5,
        ),

        SizedBox(height: 20,)
      ],
    );
  }
}
