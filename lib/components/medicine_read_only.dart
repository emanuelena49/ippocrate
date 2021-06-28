import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:provider/provider.dart';


// TODO: build wireframe and make
class MedicineReadOnly extends StatelessWidget {

  late Medicine medicine;

  @override
  Widget build(BuildContext context) {

    medicine = medicinesModel.currentMedicine!;

    return ListView(
      children: [

        _MedicineHeading(medicine: medicine,),

        SizedBox(height: 25,),
      ],
    );
  }
}

class _MedicineHeading extends StatelessWidget {

  late Medicine medicine;

  _MedicineHeading({required this.medicine});
  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Card(
        elevation: 4,
        color: Colors.greenAccent,
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

              _IntakesRow(medicine: medicine,),
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

  _IntakesRow({required this.medicine}) {
    intakesDb = MedicineIntakesDBWorker();
    medicineIntakesModel.loadAllMedicineData(intakesDb, medicine);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: medicineIntakesModel,
        child: Consumer<MedicineIntakesModel>(
        builder: (context, intakesModel, child) {

          if (intakesModel.loading) {
            return SizedBox(height: 10,);
          }

          DateTime today = getTodayDate();

          for (var i in intakesModel.intakes) {
            if (i.day.isAtSameMomentAs(today)) {
              // found today's intake
              eventualIntake = i;
              break;
            }

            if (i.day.isAfter(today)) {
              // no intakes for today
              break;
            }
          }

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
                            medicineIntakesModel.loadData(intakesDb);
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
                children: getNoIntakeText(medicine, intakesModel.intakes)
                      .map((t) => Text(t)).toList(),
              );
        }
      )
    );
  }
}
