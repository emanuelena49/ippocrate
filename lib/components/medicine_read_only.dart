import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/screens_model.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:provider/provider.dart';

import 'delete_medicine.dart';

class MedicineMenuButton extends StatelessWidget {

  Medicine medicine;
  MedicineMenuButton({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      iconSize: 32,
      onSelected: (selection) async {
        switch(selection) {
          case "view":
          // viewMedicine(context, medicine);
            break;
          case "edit":
            medicinesModel.viewMedicine(medicine, editing: true);
            medicinesModel.notify();
            break;
          case "delete":
            await deleteMedicine(context, medicine);
            // close the page
            screensModel.back(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem> [
        /* PopupMenuItem(
          value: "view",
          child: Text("Visualizza"),
        ), */
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


class MedicineReadOnly extends StatelessWidget {

  late Medicine medicine;
  @override
  Widget build(BuildContext context) {

    // get medicine
    medicine = medicinesModel.currentMedicine!;

    return ListView(
      children: [

        _MedicineHeading(medicine: medicine,),
        SizedBox(height: 25,),

        _MedicineNotes(medicine: medicine,),
        SizedBox(height: 25,),

        // todo: Medicine notifications
        SizedBox(height: 25,),
      ],
    );
  }
}

class _MedicineHeading extends StatelessWidget {

  late Medicine medicine;
  MedicineIntake? eventualIntake;

  _MedicineHeading({required this.medicine});
  @override
  Widget build(BuildContext context) {

    if (!medicineIntakesModel.loading) {
      // get (eventual) today's intake for this medicine
      DateTime today = getTodayDate();
      var res = medicineIntakesModel.getIntakes(
          medicine: medicine, startDate: today, endDate: today);
      eventualIntake = res.isNotEmpty ? res.first : null;
    }

    return ListTile(
      title: Card(
        elevation: 4,
        color: (medicineIntakesModel.loading ||
            (eventualIntake!=null && eventualIntake!.getMissingIntakes()>0)) ?
            Colors.greenAccent : Colors.white54,

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              // medicine name
              Text(
                this.medicine.name,
                style: Theme.of(context).textTheme.headline5,
              ),

              SizedBox(height: 5,),

              // medicine frequence and period
              Text(
                getIntervalText(medicine),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                getIntakesPerDayText(medicine),
                style: Theme.of(context).textTheme.subtitle2,
              ),

              SizedBox(height: 25,),

              _IntakesRow(medicine: medicine, eventualIntake: eventualIntake),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntakesRow extends StatelessWidget {

  late Medicine medicine;
  MedicineIntake? eventualIntake;
  late MedicineIntakesDBWorker intakesDb;

  _IntakesRow({required this.medicine, this.eventualIntake}) {
    intakesDb = MedicineIntakesDBWorker();
    // i can suppose there is no need of calling an update on model
  }

  @override
  Widget build(BuildContext context) {

      if (medicineIntakesModel.loading) {
        return SizedBox(height: 10,);
      }

      // build ui according to eventual intake
      return eventualIntake != null ?
        Row(
          children: [
            Expanded(
                child: Text(
                  getRemainingMedicineIntakes(eventualIntake!),
                  style: Theme.of(context).textTheme.subtitle1,
                )
            ),
            Expanded(
                child: eventualIntake!.getMissingIntakes()>0 ?

                ElevatedButton(
                    onPressed: () async {
                      if (eventualIntake!.getMissingIntakes()>0) {

                        // perform one intake and save it
                        eventualIntake!.doOneIntake();
                        await intakesDb.update(eventualIntake!);

                        // no need of reloading everything, just notify
                        medicineIntakesModel.notify();
                      }
                    },
                    child: Text("PRENDI ADESSO"),
                    style: ElevatedButton.styleFrom(primary: Colors.black54,)
                ) :

                Text("Assunzioni completate", textAlign: TextAlign.center,)
            ),
          ],
        ) :

        Column(
          children: getNoIntakeText(medicine).map((t) => Text(t)).toList(),
        );
  }
}

class _MedicineNotes extends StatelessWidget {

  late Medicine medicine;

  _MedicineNotes({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text("Note: ", style: Theme.of(context).textTheme.headline6,),
      children: [
        medicine.notes != null ?
            Column(
              children: [
                Text(medicine.notes!, style: Theme.of(context).textTheme.bodyText2),
                ElevatedButton(
                    onPressed: () {
                      medicinesModel.viewMedicine(medicine, editing: true);
                      medicinesModel.notify();
                    },
                    child: Text("modifica")
                )
              ]
            ) :
            Column(
              children: [
                Text("Nessuna nota intserita"),
                ElevatedButton(
                    onPressed: () {
                      medicinesModel.viewMedicine(medicine, editing: true);
                      medicinesModel.notify();
                    },
                    child: Text("aggiungi nota")
                )
              ],
            )
      ],
    );
  }
}





