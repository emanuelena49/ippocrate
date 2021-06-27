import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class AllMedicineIntakesList extends StatelessWidget {

  late MedicineIntakesDBWorker intakesDb;

  AllMedicineList() {
    // load all the medicines
    intakesDb = MedicineIntakesDBWorker();
    medicineIntakesModel.loadData(intakesDb);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: medicineIntakesModel,
      child: Consumer<MedicineIntakesModel>(
        builder: (context, notesModel, child){

          return medicineIntakesModel.loading ?

          // if model is still loading, I
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator()
            ],
          ) :

          ListView.builder(
              itemCount: medicineIntakesModel.intakes.length,
              itemBuilder: (context, index) {

                // single item of the list
                return AllMedicinesIntakesListItem(
                    intake: medicineIntakesModel.intakes[index]
                );
              }
          );
        },
      ),
    );
  }
}

/// A single item of a list of medicines
class AllMedicinesIntakesListItem extends StatelessWidget {

  MedicineIntake intake;

  AllMedicinesIntakesListItem({required this.intake});

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 4,
      color: intake.getMissingIntakes()>1 ?
        Colors.greenAccent :
        Colors.white54,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Column(
          children: [

            // Medicine name
            Text(
              intake.medicine.name,
              style: Theme.of(context).textTheme.headline4,
            ),

            // medicine time range
            Text(
              getIntervalText(intake.medicine),
              style: Theme.of(context).textTheme.subtitle1,
            ),

            SizedBox(height: 24,),

            // notes preview
            Container(
                height: 52,
                child: Text(
                  intake.medicine.notes != null ? intake.medicine.notes! : "",
                  overflow: TextOverflow.ellipsis,
                ),
            ),

            // intakes done + do intake now button
            Row(
              children: [
                Expanded(
                  child: Text(
                    getRemainingMedicineIntakes(intake),
                    style: Theme.of(context).textTheme.headline6,
                  )
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: animate prendi ora button
                    },
                    child: Text("PRENDI ADESSO"),
                    style: intake.getMissingIntakes()>1 ?
                        ElevatedButton.styleFrom(
                          primary: Colors.black54,
                        ) :
                        ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

