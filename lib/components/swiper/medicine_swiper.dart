import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/db/medicine_intakes_db_worker.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/ui_medicines_texts.dart';
import 'package:provider/provider.dart';

class MedicineSwipe extends StatelessWidget {

  MedicineSwipe() {
    medicineIntakesModel.loadData(MedicineIntakesDBWorker());
  }

  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    return ChangeNotifierProvider.value(
      value: medicineIntakesModel,
      child: Consumer<MedicineIntakesModel>(
        builder: (context, medIntakeModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "Medicinali",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Builder(
                builder: (context) {
                  if (medIntakeModel.loading) {
                    return CircularProgressIndicator();
                  }

                  var intakes = medIntakeModel.getIntakes(
                      startDate: today, endDate: today,
                      onlyNotDone: true);

                  if (intakes.length == 0) {
                    return Container(
                      color: Colors.white54,
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: Text(
                          "Nessun medicinale rimasto per oggi!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    );
                  }

                  return SwipeCarusel(
                    intakes.map((i) =>
                        MedicineSwipeCard(medicineIntake: i)).toList(),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

}

class MedicineSwipeCard extends StatelessWidget {

  late MedicineIntake medicineIntake;
  MedicineSwipeCard({required this.medicineIntake});

  @override
  Widget build(BuildContext context) {

    var medicine = medicineIntake.medicine;

    return SwipableCard(
      color: Colors.greenAccent,
      onTap: () {

      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // medicine name
          Text(
            medicine.name,
            style: Theme.of(context).textTheme.headline5,
          ),

          // medicine frequence and period
          Text(
            getIntervalText(medicine),
            style: Theme.of(context).textTheme.subtitle2,
          ),

          SizedBox(height: 5,),

          // notes preview
          Text(
            medicine.notes != null ? medicine.notes! : "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          SizedBox(height: 15,),

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
    );
  }
}