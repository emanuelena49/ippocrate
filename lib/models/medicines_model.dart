import 'package:flutter/material.dart';
import 'package:ippocrate/common/db_worker.dart';

/// a single medicine
class Medicine extends HasId {
  int? id;
  late String name;
  String? notes;
  late DateTimeRange interval;
  late int nIntakesPerDay;

  Medicine({this.id, required this.name, required this.interval,
    this.notes, this.nIntakesPerDay: 1});
}

