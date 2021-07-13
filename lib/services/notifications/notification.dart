import 'package:ippocrate/common/db_worker.dart';

class Notification implements HasId {

  int? id;
  DateTime dateTime;

  NotificationSubject? subject;

  Notification({this.id, this.subject, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      "id": id, "subject": subject!.toMap(),
      "datetime": dateTime.toString(),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map["id"], dateTime: DateTime.parse(map["datetime"]),
      subject: NotificationSubject.fromMap(map["subject"]),
    );
  }
}

class NotificationSubject implements HasId {

  int? id;
  String type;

  NotificationSubject({this.id, required this.type});

  Map<String, dynamic> toMap() {
    return { "id": id, "type": type };
  }

  factory NotificationSubject.fromMap(Map<String, dynamic> map) {

    return _getObject(id: map["id"], type: map["type"] );
  }

  factory NotificationSubject.fromObj(HasId obj) {

    return _getObject( id: obj.id!, type: obj.runtimeType.toString() );
  }


  static List<NotificationSubject> _all = [];
  /// Get an existent instance of [NotificationSubject] with certain features
  /// or generate a new one (that helps preventing duplicates)
  static NotificationSubject _getObject({required int id, required String type}) {

    for (var s in _all) {
      if (id==s.id && type==s.type) {
        return s;
      }
    }

    // not found, generate a new one
    var n = NotificationSubject(id: id, type: type);
    _all.add(n);

    return n;
  }
}