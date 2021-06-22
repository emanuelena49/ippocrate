import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/screens/one_medicine_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MedicinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Medicinali"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                medicinesModel.startNewMedicineCreation();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OneMedicineScreen()),
                );
              }
          )
        ],
      ),
      body: AllMedicineList(),
    );
  }
}

class AllMedicineList extends StatelessWidget {

  late MedicinesDBWorker medicinesDb;

  AllMedicineList() {
    medicinesDb = MedicinesDBWorker();
    medicinesModel.loadData(medicinesDb);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: medicinesModel,
        child: Consumer<MedicinesModel>(
          builder: (context, notesModel, child){

            return medicinesModel.loading ?
              CircularProgressIndicator() :
              ListView.builder(
                itemCount: medicinesModel.medicinesList.length,
                itemBuilder: (context, index) {

                  // single item of the list
                  return AllMedicinesListItem(
                      medicine: medicinesModel.medicinesList[index]
                  );
                }
            );
          },
        ),
    );
  }
}


/// A single item of a list of medicines
class AllMedicinesListItem extends StatelessWidget {

  Medicine medicine;

  AllMedicinesListItem({required this.medicine});

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 4,
      color: Colors.lightGreenAccent,

      child: Slidable(
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
                /*
                Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(getIntakesPerDayText(), style: Theme.of(context).textTheme.subtitle1,),
                    Text(getIntervalText(), style: Theme.of(context).textTheme.subtitle1)
                  ],
                ),*/

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
      ),
    );
  }
}

String getIntervalText(medicine) {

  DateTime from = medicine.fromDate;
  DateTime? to = medicine.toDate;

  DateFormat format = DateFormat('dd/MM');

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month
        && d1.day == d2.day;
  }

  String label;
  if (isSameDate(from, DateTime.now())) {
    label = "DA OGGI";
  } else {
    label = "DAL ${format.format(from)}";
  }

  if (to != null) {
    label += " AL ${format.format(to)}";
  }

  return label;
}

String getIntakesPerDayText(medicine) {
  if (medicine.nIntakesPerDay == 1) {
    return "1 VOLTA AL GIORNO";
  } else {
    return "${medicine.nIntakesPerDay} VOLTE AL GIORNO";
  }
}














