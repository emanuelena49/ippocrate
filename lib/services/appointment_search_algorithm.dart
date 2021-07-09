import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';

enum AppointmentState {
  DONE, INCOMING, MAYBE_MISSED
}

AppointmentState _getAppointmentState(AppointmentInstance appointmentInstance) {
  if (appointmentInstance.done) {
    return AppointmentState.DONE;
  } else if (appointmentInstance.isMaybeMissed) {
    return AppointmentState.MAYBE_MISSED;
  } else {
    return AppointmentState.INCOMING;
  }
}

List<AppointmentInstance> _sortByPriority(List<AppointmentInstance> res) {

  // sort from the oldest to the newest)
  res..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  // extract missing, incoming and done
  List<AppointmentInstance> missing=[], incoming=[], done=[];

  res.forEach((a) {

    AppointmentState state = _getAppointmentState(a);

    switch(state) {
      case AppointmentState.MAYBE_MISSED:
        missing.add(a);
        break;
      case AppointmentState.INCOMING:
        incoming.add(a);
        break;
      case AppointmentState.DONE:
        done.add(a);
        break;
    }
  });

  // concatenate the lists (I expect them to be already sorted)
  return missing + incoming + done;
}

class AppointmentsSearchOptions {
  List<AppointmentGroup>? types;
  List<AppointmentState>? acceptedStates;
  DateTime? startDate;
  DateTime? endDate;

  AppointmentsSearchOptions({
    this.types, this.acceptedStates,
    this.startDate, this.endDate
  });
}

enum AppointmentsSortingOptions {
  DATE_INCREASE, DATE_DECREASE, PRIORITY
}

/// Retrieve a list of appointments according to certain [searchOptions],
/// appropriately sorted according to some [sortingOptions]
List<AppointmentInstance> searchAppointmentInstances({
  AppointmentsSearchOptions? searchOptions,
  AppointmentsSortingOptions? sortingOptions, }) {

  searchOptions = searchOptions ?? AppointmentsSearchOptions();
  sortingOptions = sortingOptions ?? AppointmentsSortingOptions.DATE_INCREASE;

  // -------------------------------------------------
  // retrieve phase

  // get all as Iterable
  Iterable<AppointmentInstance> res =
    appointmentsInstancesModel.allAppointments.where((a) {

      searchOptions!; sortingOptions!;

      // filter by start date
      if (searchOptions.startDate != null &&
          a.dateTime.isBefore(searchOptions.startDate!)) return false;

      // filter by end date
      if (searchOptions.endDate != null &&
          a.dateTime.isAfter(searchOptions.endDate!)) return false;

      // filter by type
      if (searchOptions.types != null) {

        bool ok = false;

        // check if t belongs to one of passed types
        for (AppointmentGroup t in searchOptions.types!) {
          if (t.id == a.appointment.id) {
            ok = true;
          }
        }

        if (!ok) return false;
      }

      // filter by state
      if (searchOptions.acceptedStates != null) {
        if (!searchOptions.acceptedStates!.contains(_getAppointmentState(a)))
          return false;
      }

      return true;
    });

  // -------------------------------------------------
  // sorting phase

  if (sortingOptions == AppointmentsSortingOptions.DATE_INCREASE) {
    return res.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  } else if (sortingOptions == AppointmentsSortingOptions.DATE_DECREASE) {
    return res.toList()..sort((a, b) => -a.dateTime.compareTo(b.dateTime));
  } else {

    // apply priority algorithm
    return _sortByPriority(res.toList());
  }
}

/// Given a [date] and a [type], it retrieves the first [AppointmentInstance]
/// before that [DateTime]
AppointmentInstance? getPrevAppointmentInstance(AppointmentGroup type, DateTime date) {
  var res = searchAppointmentInstances(
    searchOptions: AppointmentsSearchOptions(types: [type], endDate: date)
  );

  return res.isNotEmpty ? res.last : null;
}

/// Given a [date] and a [type], it retrieves the first [AppointmentInstance]
/// after that date [DateTime]
AppointmentInstance? getNextAppointmentInstance(AppointmentGroup type, DateTime date) {
  var res = searchAppointmentInstances(
      searchOptions: AppointmentsSearchOptions(types: [type], startDate: date)
  );

  return res.isNotEmpty ? res.first : null;
}



