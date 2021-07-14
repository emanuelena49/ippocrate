import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/notifications/notifications.dart';
import 'package:ippocrate/services/notifications/notifications_logic.dart';
import 'package:provider/provider.dart';

class AppointmentNotificationInput extends StatelessWidget {

  AppointmentInstance appointmentInstance;
  late NotificationSubject subject;
  AppointmentNotificationInput({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: NotificationsModel.instance,
      child: Consumer<NotificationsModel>(
        builder: (context, notificationsModel, widget) {
          
          // get this notification subject
          subject = NotificationSubject.fromObj(appointmentInstance);
          
          List<NotificationItem> notificationItems =
              notificationsModel.getSubjectNotifications(subject)
                  .map((n) => NotificationItem(
                    notification: n,
                    onClickedRemove: clickedRemove
              )).toList();

          return Column(
            children: [
              Text(
                "Notifiche",
                style: Theme.of(context).textTheme.headline6,
              ),
              ...notificationItems,
              NotificationAddButton(onClick: clickedAdd),
            ],
          );
        }
      ),
    );
  }

  clickedRemove(MyNotification n) async {
    debugPrint("todo: remove notication ${n.id!.toString()}");
  }

  clickedAdd(context) async {
    // debugPrint("todo: add notication");

    // ------------------------------------------------------
    // get datetime

    // ask date
    var today = getTodayDate();
    DateTime? notificationDate = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: today,
        lastDate: getPureDate(appointmentInstance.dateTime)
    );
    // debugPrint(notificationDate.toString());

    // if null, just undo
    if (notificationDate == null) return;
    
    // ask time
    TimeOfDay? notificationTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(appointmentInstance.dateTime)
    );
    // debugPrint(notificationTime.toString());

    // if null, just undo
    if (notificationTime == null) return;

    // ------------------------------------------------------
    // build and add notification
    
    var notification = MyNotification(
      subject: subject,
      dateTime: notificationDate.add(Duration(
        hours: notificationTime.hour, minutes: notificationTime.minute
      )),
    );

    NotificationsModel.instance.addNotification(
        notification, subjectAsObj: appointmentInstance);
  }
}

class NotificationItem extends StatelessWidget {

  MyNotification notification;
  Function onClickedRemove;

  NotificationItem({required this.notification, required this.onClickedRemove});

  @override
  Widget build(BuildContext context) {

    String txt;

    DateTime today = getTodayDate();
    DateTime dateOnly = getPureDate(notification.dateTime);

    if (dateOnly.isAtSameMomentAs(today)) {
      txt = "OGGI";
    } else if (dateOnly.isAtSameMomentAs(today.add(Duration(days: 1)))) {
      txt = "DOMANI";
    } else {
      DateFormat dateFormat = DateFormat("dd/MM");
      txt = dateFormat.format(notification.dateTime);
    }

    DateFormat hourFormat = DateFormat("hh:mm");
    txt += " ALLE " + hourFormat.format(notification.dateTime);

    return Card(
      color: Colors.blue.shade800,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Icon(Icons.notifications_active, size: 38,),

            Text(txt, style: Theme.of(context).textTheme.subtitle1, ),

            GestureDetector(
                onTap: () {
                  onClickedRemove(notification);
                },
                child: Icon(Icons.clear, size: 38,)
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationAddButton extends StatelessWidget {

  Function onClick;
  NotificationAddButton({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DottedBorder(
        color: Colors.black,
        strokeWidth: 1,
        dashPattern: const [5, 5],
        child: GestureDetector(
          onTap: () {
            onClick(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Icon(Icons.add, size: 38,),
                Text("Aggiungi Notifica",
                  style: Theme.of(context).textTheme.subtitle1,),
                SizedBox(width: 38,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}