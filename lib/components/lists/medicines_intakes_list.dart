import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/dialogs/delete_medicine.dart';
import 'file:///C:/Users/Proprietario/AndroidStudioProjects/ippocrate/lib/components/dialogs/reset_today_medicine_intake.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';
import 'package:ippocrate/services/datetime.dart';
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

          DateTime today = getTodayDate();
          List<MedicineIntake> todayMedicinesIntakes =
            intakesModel.getIntakes(startDate: today, endDate: today);

          // if list is empty, I display a proper message as list item
          if (todayMedicinesIntakes.length == 0) {
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
                itemCount: todayMedicinesIntakes.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _MedicinesIntakesListItem(
                    intake: todayMedicinesIntakes[index],
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
      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: .22,
        secondaryActions: [
          IconSlideAction(
            caption: "Resetta\nassunzioni",
            color: Colors.black54,
            icon: Icons.update,
            onTap: (){
              // editMedicine(context, this.intake.medicine);
              resetTodayIntakes(context, intake);
            },
          ),
          IconSlideAction(
            caption: "Modifica",
            color: Colors.yellow,
            icon: Icons.edit,
            onTap: (){
              editMedicine(context, this.intake.medicine);
            },
          ),
          IconSlideAction(
            caption: "Elimina",
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              deleteMedicine(context, this.intake.medicine);
            },
          ),
        ],
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            medicinesModel.viewMedicine(intake.medicine, edit: false);
            screensManager.loadScreen(context, Screen.MEDICINES_ONE);
          },
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
      ),
      ),
    );
  }
}

Future viewMedicine(BuildContext context, Medicine medicine) async {
  medicinesModel.viewMedicine(medicine, edit: false);
  screensManager.loadScreen(context, Screen.MEDICINES_ONE);
}


Future editMedicine(BuildContext context, Medicine medicine) async {
  medicinesModel.viewMedicine(medicine, edit: true);
  screensManager.loadScreen(context, Screen.MEDICINES_ONE);
}

