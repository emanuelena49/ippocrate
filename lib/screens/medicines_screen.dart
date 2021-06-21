import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicines_db_worker.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MedicinesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Ippocrate"),
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

    return Container(

      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),

      child: Column(
        children: [

          // name and menu icon
          Row(
            children: [
              Text(medicine.name),
              Icon(
                Icons.more_horiz
              )
            ],
          ),

          // interval + number of intakes
          Column(
            children: [
              Text(getIntakesPerDayText()),
              Text(getIntervalText())
            ],
          ),

          // notes
          medicine.notes != null ? Text(medicine.notes!) : Text(""),

          Divider(),
        ],
      ),
    );
  }

  String getIntervalText() {

    DateTime from = medicine.fromDate;
    DateTime? to = medicine.toDate;

    DateFormat format = DateFormat('dd/mm');

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

  String getIntakesPerDayText() {
    if (medicine.nIntakesPerDay == 1) {
      return "1 VOLTA AL GIORNO";
    } else {
      return "${medicine.nIntakesPerDay} VOLTE AL GIORNO";
    }
  }
}














