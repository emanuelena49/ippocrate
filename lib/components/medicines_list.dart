import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:provider/provider.dart';


/// The list with all [Medicine]s.
class AllMedicinesList extends StatelessWidget {

  late MedicinesDBWorker medicinesDb;

  AllMedicinesList() {
    // load all the medicines
    medicinesDb = MedicinesDBWorker();
    medicinesModel.loadData(medicinesDb);
  }

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: medicinesModel,
      child: Consumer<MedicinesModel>(
        builder: (context, notesModel, child){

          // if model is still loading, I display a loading icon
          if (medicinesModel.loading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ],
            );
          }

          // if list is empty, I display a proper message as list item
          if (medicinesModel.medicinesList.length == 0) {
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    "Nessun medicinale",
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
                itemCount: medicinesModel.medicinesList.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return _MedicinesListItem(
                      medicine: medicinesModel.medicinesList[index]
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
class _MedicinesListItem extends StatelessWidget {

  Medicine medicine;

  _MedicinesListItem({required this.medicine});

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 8,
      color: Colors.greenAccent,

      child: Slidable(
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: .25,
        secondaryActions: [
          IconSlideAction(
            caption: "Modifica",
            color: Colors.yellow,
            icon: Icons.edit,
            onTap: (){
              editMedicine(context, medicine);
            },
          ),
          IconSlideAction(
            caption: "Elimina",
            color: Colors.red,
            icon: Icons.delete,
            onTap: (){
              deleteMedicine(context, medicine);
            },
          ),
        ],
        child: GestureDetector(
          onTap: () {
            viewMedicine(context, medicine);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name and menu icon
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(
                          medicine.name,
                          style: Theme.of(context).textTheme.headline5,
                        )
                    ),
                    // _MedicineItemMenu(medicine: medicine,),
                  ],
                ),

                SizedBox(height: 5,),

                // interval + number of intakes
                Text(
                  getIntakesPerDayText(medicine) + ", " + getIntervalText(medicine),
                  style: Theme.of(context).textTheme.subtitle2,
                ),


                Container(
                    height: 35,
                    padding: EdgeInsets.only(bottom: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
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
      ),
    );
  }
}

class _MedicineItemMenu extends StatelessWidget {

  Medicine medicine;
  _MedicineItemMenu({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz),
      iconSize: 32,
      onSelected: (selection) {
        switch(selection) {
          case "view":
            viewMedicine(context, medicine);
            break;
          case "edit":
            editMedicine(context, medicine);
            break;
          case "delete":
            deleteMedicine(context, medicine);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem> [
        PopupMenuItem(
          value: "view",
          child: Text("Visualizza"),
        ),
        PopupMenuItem(
          value: "edit",
          child: Text("Modifica"),
        ),
        PopupMenuItem(
          value: "delete",
          child: Text("Elimina"),
        ),
      ],
    );
  }
}

Future viewMedicine(BuildContext context, Medicine medicine) async {
  medicinesModel.viewMedicine(medicine, editing: false);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OneMedicineScreen()),
  );
}


Future editMedicine(BuildContext context, Medicine medicine) async {
  medicinesModel.viewMedicine(medicine, editing: true);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OneMedicineScreen()),
  );
}

Future deleteMedicine(BuildContext context, Medicine medicine) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){
        return AlertDialog(
          title: Text("Rimuovi medicinale"),
          content: Text("Sei sicuro di voler eliminare il medicinale ${medicine.name}?"),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(inAlertContext).pop();
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {

                // delete all intakes
                // (no need, i set ON DELETE CASCADE in SQL)

                // delete the medicine
                var medicineDb = MedicinesDBWorker();
                await medicineDb.delete(medicine.id!);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Medicinale eliminato"),
                  ),
                );
                medicinesModel.loadData(medicineDb);

                // (reload even intakes)
                medicineIntakesModel.loadData(MedicineIntakesDBWorker());
              },
              child: Text("Si, Elimina"),
            ),
          ],
        );
      }
  );
}