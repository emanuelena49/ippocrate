import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ippocrate/common/screens_manager.dart';
import 'package:ippocrate/components/forms/appointment_notifications_input.dart';
import 'package:ippocrate/db/appointment_instance_db_worker.dart';
import 'package:ippocrate/db/appointments_db_worker.dart';
import 'package:ippocrate/models/appointment_instances_model.dart';
import 'package:ippocrate/models/appointment_groups_model.dart';
import 'package:ippocrate/services/datetime.dart';
import 'package:ippocrate/services/notifications/notifications_logic.dart';

import 'notes_input.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class AppointmentInstanceSubmitButton extends StatelessWidget {

  // late AppointmentInstance initialValue;

  AppointmentInstanceSubmitButton() {
    // initialValue = appointmentsInstancesModel.currentAppointment!.clone();
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
        primary: Colors.green,
      ),
      child: Text("conferma"),
      onPressed: () async {
        // validate form
        if(!formKey.currentState!.validate()){
          return;
        }

        var appointmentInstance = appointmentsInstancesModel.currentAppointment!;

        // return;

        // insert or update the appointment type existent
        AppointmentGroupsDBWorker dbAppointments = AppointmentGroupsDBWorker();
        if (appointmentInstance.appointment.id == null) {
          var ok = await dbAppointments.create(appointmentInstance.appointment);
        } else {
          var ok = await dbAppointments.update(appointmentInstance.appointment);
        }

        // insert or update the appointment instance
        AppointmentInstancesDBWorker dbAppInst = AppointmentInstancesDBWorker();
        var action;
        if (appointmentInstance.id == null) {
          action = "creato";
          var ok = await dbAppInst.create(appointmentInstance);
        } else {
          action = "modificato";
          var ok = await dbAppInst.update(appointmentInstance);
        }

        // apply changes on notifications
        NotificationsOnSaveModel.instance.applyList(
          obj: appointmentInstance
        );

        // update all models
        appointmentsInstancesModel.loadData(dbAppInst);
        appointmentGroupsModel.loadData(dbAppointments);

        // go back at precedent screen
        screensManager.back(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text("Appuntamento $action correttamente!"),
          ),
        );
      }
    );
  }
}

class AppointmentInstanceForm extends StatelessWidget {

  late AppointmentInstance appointmentInstance;

  @override
  Widget build(BuildContext context) {

    appointmentInstance = appointmentsInstancesModel.currentAppointment!;

    return Form(
      key: formKey,
      child: ListView(
        children: [

          _AppointmentTypeInput(appointmentIntstance: appointmentInstance),

          _AppointmentDateTimeInput(appointmentInstance: appointmentInstance),

          // (enclose periodicy input in consumer to be
          // sure it refreshes when appointment type changes
          AppointmentPeriodicityInput(
            appointment: appointmentInstance.appointment,),
          /*Consumer<IncomingAppointmentsModel>(
            builder: (context, incAppModel, windget) {

              var appointment = incAppModel.currentAppointment!.appointment;

              return AppointmentPeriodicityInput(
                appointment: appointment,);
            },
          ),*/

          NotesInput(
              obj: appointmentInstance,
              model: appointmentsInstancesModel
          ),


          ListTile(
            title: AppointmentNotificationInput(
              appointmentInstance: appointmentInstance,
              applyOnSave: true,
            ),
          )
        ],
      )
    );
  }
}

class _AppointmentTypeInput extends StatelessWidget {

  AppointmentInstance appointmentIntstance;

  TextEditingController _controller = TextEditingController();

  static List<AppointmentGroup> options = appointmentGroupsModel.appointmentGroups;

  _AppointmentTypeInput({Key? key, required this.appointmentIntstance}) :
        super(key: key){
    _controller.text = this.appointmentIntstance.appointment.name;
  }

  handleNewValue({String?  freeText, AppointmentGroup? selection}) {

    if (selection != null) {
      appointmentIntstance.appointment = selection;
      return;
    }

    if (freeText==null) {
      freeText = "";
    }

    var selected = options.where((o) => o.name==freeText);

    if (selection!=null) {

      // if user chose one of the proposed options, I assign it
      // as appointment type
      appointmentIntstance.appointment =
          selected.first;
    } else {

      // if user typed free text, I create a new
      appointmentIntstance.appointment =
          AppointmentGroup(name: freeText);
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            labelText: "Scopo appuntamento: "
          ),
          onChanged: (inValue) {
            handleNewValue(freeText: inValue);
          },
          onSubmitted: (val) {

            // notify to force refresh even of periodicity input
            appointmentsInstancesModel.notify();
          },
          controller: _controller,

        ),
        suggestionsCallback: (pattern) async {
          return options.where((option) =>
              option.name.contains(pattern));
        },
        itemBuilder: (context, AppointmentGroup suggestion) {
          return ListTile(
            title: Text(suggestion.name),
          );
        },
        onSuggestionSelected: (AppointmentGroup selection) {
          _controller.text = selection.name;
          handleNewValue(selection: selection);
          appointmentsInstancesModel.notify();
        },
        getImmediateSuggestions: true,
      ),
    );
  }
}

class _AppointmentDateTimeInput extends StatelessWidget {

  AppointmentInstance appointmentInstance;

  _AppointmentDateTimeInput({required this.appointmentInstance});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: DateTimePicker(
        type: DateTimePickerType.dateTimeSeparate,
        dateLabelText: "Giorno",
        timeLabelText: "Ora",
        initialValue: appointmentInstance.dateTime.toString(),
        initialDate: appointmentInstance.dateTime,
        initialTime: TimeOfDay(hour: 10, minute: 0),
        firstDate: getTodayDate(),
        lastDate: DateTime(2100),
        onChanged: (val) {
          if (val != null && val != "") {
            appointmentInstance.dateTime = DateTime.parse(val);
          }
        },
        validator: (val) {
          // check it is not null
          if (val == null || val == "") {
            return "La data e l'ora dell'appuntamento non possono essere nulle";
          }

          return null;
        },
        onSaved: (val) {
          if (val != null && val != "") {
            appointmentInstance.dateTime = DateTime.parse(val);
          }
        },
      ),
    );
  }
}


enum _AppointmentPeriodicityOptions {
  NON_PERIODIC, ONCE_A_YEAR, ONCE_A_MONTH,
  ONCE_EVERY_N_MONTHS, ONCE_EVERY_N_DAYS
}

class AppointmentPeriodicityInput extends StatefulWidget {

  AppointmentGroup appointment;
  AppointmentPeriodicityInput({required this.appointment});

  @override
  _AppointmentPeriodicityInputState createState() =>
      _AppointmentPeriodicityInputState();
}

class _AppointmentPeriodicityInputState extends State<AppointmentPeriodicityInput> {

  late _AppointmentPeriodicityOptions periodicity;
  late AppointmentGroup appointment;

  /*
  _AppointmentPeriodicityInputState() {
    appointment = widget.appointment;
    periodicity = _calculatePeriodicity();
  }*/

  @override
  Widget build(BuildContext context) {

    appointment = widget.appointment;
    periodicity = _calculatePeriodicity();

    int? days = appointment.periodicityDaysInterval;
    int? months = (periodicity == _AppointmentPeriodicityOptions.ONCE_A_MONTH)
        ? 1 : (periodicity == _AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS)
        ? days!~/30 : null;

    bool isPeriodic =
        (periodicity != _AppointmentPeriodicityOptions.NON_PERIODIC);

    return ListTile(
      title: Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // is periodical checkbox
            Row(
              children: [

                Checkbox(
                  value: isPeriodic,
                  onChanged: (bool? val) {
                    if (val==null || !val) {
                      setState(() {
                        periodicity = _AppointmentPeriodicityOptions.NON_PERIODIC;
                        appointment.periodicityDaysInterval = null;
                      });
                    } else {
                      setState(() {
                        appointment.periodicityDaysInterval = 365;
                        periodicity = _AppointmentPeriodicityOptions.ONCE_A_YEAR;
                      });
                    }
                  }
                ),

                Text("Appuntamento Periodico"),
              ]
            ),

            // if is periodical, I display all the periodicity options
            if (isPeriodic) ...[

              RadioListTile<_AppointmentPeriodicityOptions>(
                title: Text("1 VOLTA ALL'ANNO"),
                value: _AppointmentPeriodicityOptions.ONCE_A_YEAR,
                groupValue: periodicity,
                onChanged: (val) {
                  if (val!=null) setState(() {
                    appointment.periodicityDaysInterval = 365;
                    periodicity = _AppointmentPeriodicityOptions.ONCE_A_YEAR;
                  });
                }
              ),

              RadioListTile<_AppointmentPeriodicityOptions>(
                  title: Text("1 VOLTA AL MESE"),
                  value: _AppointmentPeriodicityOptions.ONCE_A_MONTH,
                  groupValue: periodicity,
                  onChanged: (val) {
                    if (val!=null) setState(() {
                      appointment.periodicityDaysInterval = 30;
                      periodicity = _AppointmentPeriodicityOptions.ONCE_A_MONTH;
                    });
                  }
              ),

              RadioListTile<_AppointmentPeriodicityOptions>(
                  value: _AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS,
                  groupValue: periodicity,
                  onChanged: (val) {
                    if (val!=null) setState(() {
                      appointment.periodicityDaysInterval = 60;
                      periodicity = _AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS;
                    });
                  },
                  title: LimitedBox(
                    maxHeight: 64,
                    child: Row(
                      children: [
                        Text("1 VOLTA OGNI "),
                        Container(
                          width: 50,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly],
                            initialValue: months!=null ? months.toString() : "",
                            validator: (val) {

                              if (periodicity!=_AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS) {
                                return null;
                              }

                              if (val==null) {
                                return "Questo campo non può essere lasciato vuoto";
                              }

                              int? valAsNum = int.tryParse(val);
                              if (valAsNum == null) {
                                return "Inserisci un numero intero";
                              }

                              if (valAsNum<1) {
                                return "Inserisci un numero maggiore o uguale a 1";
                              }

                              return null;
                            },
                            onChanged: (val) {
                              try {
                                int valAsNum = int.parse(val);
                                setState(() {
                                  appointment.periodicityDaysInterval = valAsNum*30;
                                  periodicity = _AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS;
                                });
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                            },
                          ),
                        ),
                        Text(" MESI"),
                      ],
                    ),
                  ),
              ),

              RadioListTile<_AppointmentPeriodicityOptions>(
                  value: _AppointmentPeriodicityOptions.ONCE_EVERY_N_DAYS,
                  groupValue: periodicity,
                  onChanged: (val) {
                    if (val!=null) setState(() {
                      appointment.periodicityDaysInterval = 29;
                      periodicity = _AppointmentPeriodicityOptions.ONCE_EVERY_N_DAYS;
                    });
                  },
                title: LimitedBox(
                  maxHeight: 64,
                  child: Row(
                    children: [
                      Text("1 VOLTA OGNI "),
                      Container(
                        width: 50,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly],
                          initialValue: days!=null ? days.toString() : "",
                          validator: (val) {
                            if (periodicity!=_AppointmentPeriodicityOptions.ONCE_EVERY_N_DAYS) {
                              return null;
                            }

                            if (val==null) {
                              return "Questo campo non può essere lasciato vuoto";
                            }

                            int? valAsNum = int.tryParse(val);
                            if (valAsNum == null) {
                              return "Inserisci un numero intero";
                            }

                            if (valAsNum<1) {
                              return "Inserisci un numero maggiore o uguale a 1";
                            }

                            return null;
                          },
                          onChanged: (val) {
                            try {
                              int valAsNum = int.parse(val);
                              setState(() {
                                appointment.periodicityDaysInterval = valAsNum;
                                periodicity = _AppointmentPeriodicityOptions.ONCE_EVERY_N_DAYS;
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                        ),
                      ),
                      Text(" GIORNI"),
                    ],
                  ),
                ),

              ),
            ],
          ],
        ),
      ),
    );
  }

  _AppointmentPeriodicityOptions _calculatePeriodicity() {
    int? days = appointment.periodicityDaysInterval;

    if (days == null) {
      return _AppointmentPeriodicityOptions.NON_PERIODIC;
    } else if (days == 365) {
      return _AppointmentPeriodicityOptions.ONCE_A_YEAR;
    } else if (days == 30) {
      return _AppointmentPeriodicityOptions.ONCE_A_MONTH;
    } else if (days%30 == 0) {
      return _AppointmentPeriodicityOptions.ONCE_EVERY_N_MONTHS;
    } else {
      return _AppointmentPeriodicityOptions.ONCE_EVERY_N_DAYS;
    }
  }
}

















