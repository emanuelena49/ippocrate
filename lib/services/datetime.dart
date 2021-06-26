
import 'package:intl/intl.dart';

/// get a "pure" date from a generic [DateTime] object
/// (It will set the hour to 00:00:00)
DateTime getPureDate(DateTime datetime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formatted = formatter.format(datetime);
  return DateTime.parse(formatted);
}

/// get the current date as "pure" [DateTime]
/// (It will set the hour to 00:00:00)
DateTime getTodayDate() {
  return getPureDate(DateTime.now());
}