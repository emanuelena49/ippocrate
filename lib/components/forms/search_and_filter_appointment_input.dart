import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:provider/provider.dart';

class AppointmentSearchFilterModel extends ChangeNotifier {

  AppointmentSearchFilterModel._();
  static final AppointmentSearchFilterModel instance = AppointmentSearchFilterModel._();

  AppointmentsSearchOptions searchOptions = AppointmentsSearchOptions();
  AppointmentsSortingOptions sortingOptions = AppointmentsSortingOptions.DATE_INCREASE;

  notify() {
    notifyListeners();
  }
}

AppointmentSearchFilterModel appointmentSearchFilterModel =
    AppointmentSearchFilterModel.instance;

class SearchAndFilterAppointmentInput extends StatelessWidget {

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Consumer2<AppointmentGroupsModel, AppointmentSearchFilterModel>(
        builder: (context, appModel, searchFilterModel, widget) {

          return Row(
            children: [

              // filter button
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: () {
                  // todo: show filter dialog/expand some not better defined filter area
                }
              ),

              // search bar
              Expanded(
                child: TypeAheadField<AppointmentGroup>(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      labelText: "Scopo appuntamento: ",
                      prefix: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _controller.text = "";
                          handleNewValue(freeText: "");
                          searchFilterModel.notify();

                          // FocusScope.of(context).requestFocus(new FocusNode());
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                      suffix: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchFilterModel.notify();
                        },
                      ),
                    ),
                    onChanged: (inValue) {
                      handleNewValue(freeText: inValue);
                    },
                    onSubmitted: (inValue) {
                      // notify to force refresh even of periodicity input
                      appointmentSearchFilterModel.notify();
                    },
                    controller: _controller,
                  ),
                  suggestionsCallback: (pattern) async {
                    return appointmentGroupsModel.appointmentGroups
                        .where((option) => option.name.contains(pattern));
                  },
                  itemBuilder: (context, AppointmentGroup suggestion) {
                    return ListTile(
                      title: Text(suggestion.name),
                    );
                  },
                  onSuggestionSelected: (AppointmentGroup selection) {

                    _controller.text = selection.name;
                    handleNewValue(selection: selection);
                    searchFilterModel.notify();
                  },
                  getImmediateSuggestions: true,
                ),
              )
            ],
          );
        }
      ),
    );
  }

  handleNewValue({AppointmentGroup? selection, String? freeText}) {

    if (selection != null) {

      // search selection
      appointmentSearchFilterModel.searchOptions.types = [selection];
    } else {

      // search all AppointmentGroups which match freeText
      appointmentSearchFilterModel.searchOptions.types =
          appointmentGroupsModel.appointmentGroups.where(
                  (option) => option.name.contains(freeText ?? "")
          ).toList();
    }

    return;
  }
}