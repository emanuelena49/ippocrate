import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';


/// A list of all the [MedicineIntake]s which should be done today.
class MedicineIntakesList extends StatelessWidget {

  late MedicineIntakesDBWorker intakesDb;

  MedicineIntakesList() {
    // load all the medicines
    intakesDb = MedicineIntakesDBWorker();
    medicineIntakesModel.loadData(intakesDb);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: medicineIntakesModel,
      child: Consumer<MedicineIntakesModel>(
        builder: (context, intakesModel, child){

          // if model is still loading, I display a loading icon
          if (intakesModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          // if list is empty, I display a proper message as list item
          if (intakesModel.intakes.length == 0) {
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                      "Nessun medicinale da assumere oggi!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5,
                  ),
                )
              ],
            );
          }

          // regular list
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                itemCount: intakesModel.intakes.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _MedicinesIntakesListItem(
                    intake: intakesModel.intakes[index],
                    intakesDb: intakesDb,
                  );
                }
            ),
          );
        },
      ),
    );
  }
}

/// A single item of a list of medicines
class _MedicinesIntakesListItem extends StatelessWidget {

  MedicineIntake intake;
  MedicineIntakesDBWorker intakesDb;

  _MedicinesIntakesListItem({required this.intake, required this.intakesDb});

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 8,
      color: intake.getMissingIntakes()>0 ?
        Colors.greenAccent :
        Colors.white54,

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Medicine name
            Text(
              intake.medicine.name,
              style: Theme.of(context).textTheme.headline5,
              overflow: TextOverflow.ellipsis,
            ),

            // medicine time range
            Text(
              getIntervalText(intake.medicine),
              style: Theme.of(context).textTheme.subtitle2,
            ),

            SizedBox(height: 10,),

            // notes preview
            Text(
              intake.medicine.notes != null ? intake.medicine.notes! : "",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),

            SizedBox(height: 15,),

            // intakes done + do intake now button
            Row(
              children: [
                Expanded(
                  child: Text(
                    getRemainingMedicineIntakes(intake),
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ),
                Expanded(
                  child: intake.getMissingIntakes()>0 ?

                    ElevatedButton(
                      onPressed: () async {
                        if (intake.getMissingIntakes()>0) {

                          // perform one intake and save it
                          intake.doOneIntake();
                          await intakesDb.update(intake);
                          medicineIntakesModel.loadData(intakesDb);
                        }
                      },
                      child: Text("PRENDI ADESSO"),
                      style: ElevatedButton.styleFrom(primary: Colors.black54,)
                    ) :

                  Text("Assunzioni completate", textAlign: TextAlign.center,)
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

