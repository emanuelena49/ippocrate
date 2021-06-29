import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/services/datetime.dart';

/// An single appointment (type). It is the abstract representation of
/// a series of appointments, it has a [name] (ex. "controllo medico di base"),
/// + some other information (ex. the periodicity of the appointment, represented
/// by [periodicityDaysInterval] and [isPeriodic].
class Appointment implements HasId {
  @override
  int? id;
  String? name;
  String? notes;

  /// In case of periodicity, the (approximate) days between each appointment
  int? periodicityDaysInterval;

  Appointment({this.id, this.name, this.notes, this.periodicityDaysInterval});

  /// If this appointment should be repeated periodically, in detail every
  /// [periodicityDaysInterval] days
  bool isPeriodic() {
    return periodicityDaysInterval==null ? false : true;
  }
}