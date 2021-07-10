import 'dart:math';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/components/forms/search_and_filter_appointment_input.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:provider/provider.dart';

Future appointmentsSearchFilterDialog(context) async {

  return showDialog(

      context: context,
      barrierDismissible: true,
      builder: (BuildContext inAlertContext) {

        // save state to permit undo
        appointmentSearchFilterModel.saveState();


        return AlertDialog(
          contentPadding: const EdgeInsets.all(12),
          insetPadding: const EdgeInsets.all(0),
          title: Text("Filtri e Ordinamento"),
          content: Builder(
            builder: (inAlertContext) {

              var width = MediaQuery.of(context).size.width;
              var height = MediaQuery.of(context).size.height;


              return Container(
                width: width-100,
                height: 500,
                child: ChangeNotifierProvider.value(
                  value: appointmentSearchFilterModel,
                  child: Consumer<AppointmentSearchFilterModel>(
                    builder: (context, asfModel, widget) {

                      return _FilterBox();
                    }
                  )
                ),
              );
            }

          ),
          actions: [
            ElevatedButton(
              child: Text("pulisci filtri"),
              onPressed: () {
                _controllerEndDate.clear();
                _controllerStartDate.clear();
                appointmentSearchFilterModel.searchOptions.acceptedStates = null;
                appointmentSearchFilterModel.searchOptions.startDate = null;
                appointmentSearchFilterModel.searchOptions.endDate = null;
                appointmentSearchFilterModel.apply();
              },
            ),
            ElevatedButton(
              child: Text("Annulla"),
              onPressed: () {
                // undo changes
                appointmentSearchFilterModel.restoreSavedState();
                // close the poupup
                Navigator.of(inAlertContext).pop();
              },
            ),
            ElevatedButton(
              child: Text("Applica"),
              onPressed: () {

                // apply changes
                appointmentSearchFilterModel.apply();
                // close the poupup
                Navigator.of(inAlertContext).pop();
              },
            ),
          ],
        );
      }
  );
}

TextEditingController _controllerStartDate = TextEditingController();
TextEditingController _controllerEndDate = TextEditingController();

class _FilterBox extends StatelessWidget {

  _FilterBox() {
    var searchOptions = appointmentSearchFilterModel.searchOptions;

    _controllerStartDate.text = searchOptions.startDate != null
        ? searchOptions.startDate.toString()
        : "";
    _controllerEndDate.text = searchOptions.endDate != null
        ? searchOptions.endDate.toString()
        : "";
  }


  @override
  Widget build(BuildContext context) {
    var today = getTodayDate();
    var searchOptions = appointmentSearchFilterModel.searchOptions;

    return Column(
      children: [

        ListTile(
            title: Text(
              "FILTRI: ",
              style: Theme.of(context).textTheme.subtitle2,
            ),
        ),

          // date range input
        ListTile(
          leading: Text("Da "),
          title: DateTimePicker(
            type: DateTimePickerType.date,
            controller: _controllerStartDate,
            initialDate: searchOptions.startDate != null
                ? searchOptions.startDate
                : today,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            decoration: const InputDecoration(errorMaxLines: 3),
            validator: (val) {
              if (val == null || val == "") {
                return null;
              }

              return null;
            },
            onChanged: (val) {
              appointmentSearchFilterModel.searchOptions.startDate = (val != null && val != "") ?
              getPureDate(DateTime.parse(val)) : null;
              appointmentSearchFilterModel.apply();
            },
          ),
        ),


        ListTile(
          leading: Text("A "),
          title: DateTimePicker(
            type: DateTimePickerType.date,
            controller: _controllerEndDate,
            initialDate: searchOptions.endDate != null
                ? searchOptions.endDate
                : today,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            decoration: const InputDecoration(errorMaxLines: 3,),
            validator: (val) {
              // check it is not null
              if (val == null || val == "") {
                return null;
              }

              return null;
            },
            onChanged: (val) {
              appointmentSearchFilterModel.searchOptions.endDate = (val != null && val != "") ?
              getPureDate(DateTime.parse(val)) : null;
              appointmentSearchFilterModel.apply();
            },
          ),
        ),

          // appointment state filters
        CheckboxListTile(
            title: Text("Imminenti"),
            value: searchOptions.acceptedStates == null ||
                searchOptions.acceptedStates!.contains(AppointmentState.INCOMING),
            onChanged: (bool? value) {
              handleStateFilterChange(AppointmentState.INCOMING, value);
            },
          ),

        CheckboxListTile(
            title: Text("Già fatti"),
            value: searchOptions.acceptedStates == null ||
                searchOptions.acceptedStates!.contains(AppointmentState.DONE),
            onChanged: (bool? value) {
              handleStateFilterChange(AppointmentState.DONE, value);
            },
          ),

        CheckboxListTile(
            title: Text("(Forse) mancati"),
            value: searchOptions.acceptedStates == null ||
                searchOptions.acceptedStates!.contains(AppointmentState.MAYBE_MISSED),
            onChanged: (bool? value) {
              handleStateFilterChange(AppointmentState.MAYBE_MISSED, value);
            },
          ),

        SizedBox(height: 25,),

        ListTile(
          title: Text(
            "ORDINA PER: ",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),

        ListTile(
          title: DropdownButton<AppointmentsSortingOptions>(
            value: appointmentSearchFilterModel.sortingOptions,
            onChanged: (AppointmentsSortingOptions? val) {
              if (val!=null) {
                appointmentSearchFilterModel.sortingOptions = val;
                appointmentSearchFilterModel.apply();
              }
            },
            items: [
              DropdownMenuItem<AppointmentsSortingOptions>(
                value: AppointmentsSortingOptions.DATE_INCREASE,
                child: Text("Data (crescente)"),
              ),
              DropdownMenuItem<AppointmentsSortingOptions>(
                value: AppointmentsSortingOptions.DATE_DECREASE,
                child: Text("Data (decrescente)"),
              ),
              DropdownMenuItem<AppointmentsSortingOptions>(
                value: AppointmentsSortingOptions.PRIORITY,
                child: Text("Per priorità"),
              ),
            ],
          ),
        )

      ],
    );
  }

  handleStateFilterChange(AppointmentState state, bool? value) {

    if (value!=null && value) {
      // if an accepted states list exists and doesn't contain
      // the checked state, add it
      if (appointmentSearchFilterModel.searchOptions.acceptedStates!=null &&
          !appointmentSearchFilterModel.searchOptions.acceptedStates!.contains(state)) {

        appointmentSearchFilterModel.searchOptions.acceptedStates!.add(state);
      }
    } else {

      // eventually create an accepted states list
      if (appointmentSearchFilterModel.searchOptions.acceptedStates==null) {
        appointmentSearchFilterModel.searchOptions.acceptedStates = [...AppointmentState.values];
      }

      // eventually remove unchecked state
      if (appointmentSearchFilterModel.searchOptions.acceptedStates!.contains(state)) {
        appointmentSearchFilterModel.searchOptions.acceptedStates!.remove(state);
      }
    }

    appointmentSearchFilterModel.apply();
  }
}
