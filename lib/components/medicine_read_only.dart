import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';


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
