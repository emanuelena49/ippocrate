import 'package:flutter/cupertino.dart';
import 'package:ippocrate/common/db_worker.dart';
import 'package:ippocrate/common/model.dart';

class MyNotification implements HasId {

  int? id;
  DateTime dateTime;

  NotificationSubject? subject;

  MyNotification({this.id, this.subject, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      "id": id, "subject": subject!.toMap(),
      "datetime": dateTime.toString(),
    };
  }

  factory MyNotification.fromMap(Map<String, dynamic> map) {
    return MyNotification(
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
  
  bool compare(NotificationSubject s) {
    return s.id==id && s.type==type;
  }
}

/// A logic [Model] for handling a list of [MyNotification]s
abstract class NotificationModelLogic extends Model {
  
  List<MyNotification> notifications = [];
  
  /// Init here the list of [notifications] collecting them 
  /// from pending notifications
  init();
  
  /// Get all the [MyNotification]s about a certain [NotificationSubject]
  List<MyNotification> getSubjectNotifications(NotificationSubject subject) {
    return notifications.where((n) => 
        n.subject!=null && n.subject!.compare(subject)).toList();
  }

  /// Get the first id available, the smallest one not used
  /// Precondition: [notifications] is sorted by id
  /// Postcondition: [notifications] is still sorted by id and the
  ///   new [notification] has an id and it is in
  ///
  ///  Call this in your override BEFORE you shedule the notification
  ///  (so you have an id)
  ///  Remember to handle the [notify] stuff
  @mustCallSuper
  Future addNotification(MyNotification notification, {bool notify: true}) async {

    if (notification.id==null) {

      // ------------------------------------------------
      // assign an id to notifications and insert it
      // in the most proper position

      int newId = 1;
      /// Invariants:
      /// - id > i
      /// - all ids of notifications[0..i-1]<id
      for(int i=0; i<notifications.length; i++) {
        var n = notifications[i];
        if (n.id! > newId) {

          // ok, I found a free id
          notification.id = newId;

          // insert notification in the list just before n
          notifications.insert(i, notification);

          // we can finish here
          return;

        } else {
          newId++;
        }
      }

      // If i am here, i simply assign the last
      notification.id = newId;
      notifications.add(notification);
    } else {

      // ------------------------------------------------
      // just insert it in the most proper position

      for(int i=0; i<notifications.length; i++) {
        var n = notifications[i];
        if (n.id! > notification.id!) {

          // insert notification in the list just before n
          notifications.insert(i, notification);

          // we can finish here
          return;
        }
      }

      // If i am here, i simply insert it in the last position
      notifications.add(notification);
    }
  }

  /// Postcondition: [notifications] is still sorted by id
  ///   and [notification] is not in
  ///
  /// Call this before or after your override (it's up to you)
  /// Remember to handle the [notify] stuff
  @mustCallSuper
  Future removeNotification(MyNotification notification, {bool notify: true}) async {

    notifications.removeWhere((n) => n.id==notification.id);
  }

  /// Remove all [Notification]s associated to a certain
  Future removeAllNotifications(NotificationSubject subject,
      {bool notify: true}) async {

    var notificationsToRemove = notifications.where((n) =>
        n.subject!.compare(subject));

    for (var n in notificationsToRemove) {
      await removeNotification(n, notify: false);
    }

    if (notify) notifyListeners();
  }
}