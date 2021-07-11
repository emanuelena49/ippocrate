import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/bottom_bar.dart';
import 'package:ippocrate/components/swiper/medicine_swiper_card.dart';
import 'package:ippocrate/components/swiper/swipe_carusel.dart';
import 'package:ippocrate/models/medicine_intakes_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: GestureDetector(
        // tool to close keyboard when clicked outside
          onTap: () {
            // FocusScope.of(context).requestFocus(new FocusNode());
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: _HomeScreenBody(),
      ),
      bottomNavigationBar: MyBottomBar(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var today = getTodayDate();

    return ListView(
      children: [

        Container(
            child: ChangeNotifierProvider.value(
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

                          var intakes = medIntakeModel.getIntakes(startDate: today, endDate: today,
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
            ),
          ),

        // today's medicine intakes carusel
      ],
    );
  }

}