import 'package:badges/badges.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ippocrate/components/dialogs/appointment_search_filters_dialog.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/appointment_search_algorithm.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:provider/provider.dart';

class AppointmentSearchFilterModel extends ChangeNotifier {
  AppointmentSearchFilterModel._();
  static final AppointmentSearchFilterModel instance =
      AppointmentSearchFilterModel._();

  AppointmentsSearchOptions searchOptions = AppointmentsSearchOptions();
  AppointmentsSortingOptions sortingOptions =
      AppointmentsSortingOptions.DATE_INCREASE;

  AppointmentsSearchOptions _precSearch = AppointmentsSearchOptions();
  AppointmentsSortingOptions _precSorting =
      AppointmentsSortingOptions.DATE_INCREASE;

  int get nFiltersApplied {

    int count=0;

    if (searchOptions.startDate!=null) count++;
    if (searchOptions.endDate!=null) count++;
    if (searchOptions.acceptedStates!=null &&
        searchOptions.acceptedStates!.length!=3) count++;

    if (sortingOptions!=AppointmentsSortingOptions.DATE_INCREASE) count++;

    return count;
  }

  apply() {
    notifyListeners();
  }

  saveState() {
    _precSearch = searchOptions.clone();
    _precSorting = sortingOptions;
  }

  restoreSavedState() {
    searchOptions = _precSearch;
    sortingOptions = _precSorting;
    notifyListeners();
  }
}

AppointmentSearchFilterModel appointmentSearchFilterModel =
    AppointmentSearchFilterModel.instance;

class SearchAndFilterAppointmentInput extends StatefulWidget {
  @override
  _SearchAndFilterAppointmentInputState createState() =>
      _SearchAndFilterAppointmentInputState();
}

class _SearchAndFilterAppointmentInputState
    extends State<SearchAndFilterAppointmentInput> {
  TextEditingController _controller = TextEditingController();
  bool filterBoxOpen = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentGroupsModel, AppointmentSearchFilterModel>(
        builder: (context, appModel, searchFilterModel, widget) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Row(
          children: [

            _FilterIcon(),
            // search bar
            Expanded(
              child: TypeAheadField<AppointmentGroup>(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    labelText: "Cerca",
                    prefix: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _controller.text = "";
                        handleNewValue(freeText: "");
                        searchFilterModel.apply();

                        // FocusScope.of(context).requestFocus(new FocusNode());
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    suffix: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchFilterModel.apply();
                      },
                    ),
                  ),
                  onChanged: (inValue) {
                    handleNewValue(freeText: inValue);
                  },
                  onSubmitted: (inValue) {
                    // notify to force refresh even of periodicity input
                    appointmentSearchFilterModel.apply();
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
                  searchFilterModel.apply();
                },
                getImmediateSuggestions: true,
              ),
            )
          ],
        ),
      );
    });
  }

  handleNewValue({AppointmentGroup? selection, String? freeText}) {
    if (selection != null) {
      // search selection
      appointmentSearchFilterModel.searchOptions.types = [selection];
    } else {
      // search all AppointmentGroups which match freeText
      appointmentSearchFilterModel.searchOptions.types = appointmentGroupsModel
          .appointmentGroups
          .where((option) => option.name.contains(freeText ?? ""))
          .toList();
    }

    return;
  }
}

class _FilterIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    int nFiltersApplied = appointmentSearchFilterModel.nFiltersApplied;
    var icon = Icon(Icons.filter_list,);

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          appointmentsSearchFilterDialog(context);
        },
        child: nFiltersApplied<1 ? icon : Badge(
          child: icon,
          badgeContent: Text(nFiltersApplied.toString()),
        ),
      ),
    );
  }

}