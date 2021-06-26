import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
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
      color: Colors.lightGreenAccent,

      child: Text("..."),
    );
  }
}

/* Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: .25,
        secondaryActions: [
          IconSlideAction(
            caption: "Rimuovi",
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){

            },
          ),
        ],
        child: GestureDetector(
          onTap: (){},
          onLongPress: (){},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // name and menu icon
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(medicine.name, style: Theme.of(context).textTheme.headline5, )),
                    Icon(
                        Icons.more_horiz
                    )
                  ],
                ),

                SizedBox(height: 5,),

                // interval + number of intakes
                Text(
                  getIntakesPerDayText(medicine) + ", " + getIntervalText(medicine),
                  style: Theme.of(context).textTheme.subtitle1,
                ),

                Container(
                    height: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          medicine.notes != null ? medicine.notes! : "",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ), */