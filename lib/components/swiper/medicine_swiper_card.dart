import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/models/medicines_model.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';

class MedicineSwipeCard extends SwipableCard {

  late MedicineIntake medicineIntake;
  MedicineSwipeCard({required this.medicineIntake});

  @override
  Widget build(BuildContext context) {

    var medicine = medicineIntake.medicine;

    return Card(
      elevation: 8,
      color: Colors.greenAccent,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: GestureDetector(
        onTap: () {
          // todo: open medicine
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              // medicine name
              Text(
                medicine.name,
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

              SizedBox(height: 10,),

              Container(
                  height: 35,
                  padding: EdgeInsets.only(bottom: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        medicine.notes != null ? medicine.notes! : "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  )
              ),

              // perform intake row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getRemainingMedicineIntakes(medicineIntake),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (medicineIntake.getMissingIntakes()>0) {

                          // perform one intake and save it
                          medicineIntake.doOneIntake();
                          await MedicineIntakesDBWorker().update(medicineIntake);

                          // no need of reloading everything, just notify
                          medicineIntakesModel.notify();
                        }
                      },
                      child: Text("PRENDI ADESSO"),
                      style: ElevatedButton.styleFrom(primary: Colors.black54,)
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}