import 'dart:ui';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Student.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

class AbsenceCard extends StatelessWidget {
  List<Absence> absences;
  int numOfAbsences = 0;
  String state = "";
  Color color;
  BuildContext context;
  bool isSingle;
  String cardText;

  AbsenceCard(List<Absence> absence, bool isSingle, BuildContext context) {
    this.context = context;
    this.absences = absence;
    numOfAbsences = absence.length;

    if (absence[0].DelayTimeMinutes != 0) {
      cardText = I18n.of(context).delay;
    } else {
      cardText = I18n.of(context).absence;
    }

    this.isSingle = isSingle;

    bool unjust = false;
    bool just = false;
    bool bejust = false;

    for (Absence a in absence) {
      if (a.JustificationState == "UnJustified")
        unjust = true;
      else if (a.JustificationState == "Justified")
        just = true;
      else if (a.JustificationState == "BeJustified") bejust = true;
    }

    if (unjust && !just && !bejust) {
      state = I18n.of(context).justificationUnjustified;
      color = Colors.red;
    } else if (!unjust && just && !bejust) {
      state = I18n.of(context).justificationJustified;
      color = Colors.green;
    } else if (!unjust && !just && bejust) {
      state = I18n.of(context).justificationTojustify;
      color = Colors.grey;
    } else {
      state = I18n.of(context).justificationMixed;
      color = Colors.orange;
    }
  }

  @override
  Key get key => new Key(getDate());

  String getDate() {
    return absences[0].CreatingTime.toIso8601String();
  }

  void openDialog() {
    _absenceDialog(absences[0]);
  }

  IconData iconifyState(String state) {
    switch (state) {
      case Absence.UNJUSTIFIED:
        return Icons.clear;
        break;
      case Absence.JUSTIFIED:
        return Icons.check;
        break;
      case Absence.BE_JUSTIFIED:
        return Icons.person;
        break;
      default:
      return IconData(0xf625, fontFamily: "Material Design Icons");
        break;
    }
  }

  Color colorifyState(String state) {
    switch (state) {
      case Absence.UNJUSTIFIED:
        return Colors.red;
        break;
      case Absence.JUSTIFIED:
        return Colors.green;
        break;
      case Absence.BE_JUSTIFIED:
        return Colors.grey;
        break;
      default:
        return Colors.black;
        break;
    }
  }

  Future<Null> _absenceDialog(Absence absence) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      I18n.of(context).lessonCount(numOfAbsences.toString())),
                  Text(I18n.of(context).absenceTime + ": " +
                      dateToHuman(absence.LessonStartTime)),
                  Text(I18n.of(context).administrationTime + ": " +
                      dateToHuman(absence.CreatingTime)),
                  Text(I18n.of(context).justificationState + ": " +
                      absence.JustificationStateName),
                  Text(I18n.of(context).justificationMode + ": " +
                      absence.JustificationTypeName),
                  absence.DelayTimeMinutes != 0
                      ? Text(I18n.of(context).delayMins +
                          absence.DelayTimeMinutes.toString() +
                          " " + I18n.of(context).timeMinute)
                      : Container(),
                ].followedBy(absences.map((Absence absence) {
                  return ListTile(
                    leading: Icon(
                        absence.DelayTimeMinutes == 0
                            ? iconifyState(absence.JustificationState)
                            : (Icons.watch_later),
                        color: colorifyState(absence.JustificationState)),
                    title: Text(absence.Subject),
                    subtitle: Text(dateToHuman(absence.LessonStartTime)),
                  );
                })).toList(),
              ),
            ),
          ],
          title: Text(
            absence.ModeName,
          ),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openDialog,
      child: Card(
        margin: EdgeInsets.all(6.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Text(numOfAbsences.toString(),
                        style: TextStyle(
                            fontSize: 18.0, color: globals.CurrentTextColor)),
                    Text(" " + I18n.of(context).pcs + " ",
                        style: TextStyle(
                            fontSize: 18.0,
                            color:
                                globals.isDark ? Colors.white : Colors.black)),
                    Text("$state ",
                        style: TextStyle(fontSize: 18.0, color: color)),
                    Text(cardText,
                        style: TextStyle(
                            fontSize: 18.0,
                            color:
                                globals.isDark ? Colors.white : Colors.black)),
                  ],
                ),
                padding: EdgeInsets.all(10.0),
              ),
              !isSingle
                  ? Container(
                      child: Text(
                          dateToHuman(absences[0].LessonStartTime),
                          style: TextStyle(
                            fontSize: 16.0,
                          )),
                      alignment: Alignment(1.0, -1.0),
                      padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 2.0),
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 2),
                        child: Icon(
                          Icons.block,
                          color: globals.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Container(
                        child: Text(
                          cardText,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        padding: EdgeInsets.only(left: 8.0),
                      ),
                      isSingle
                          ? Expanded(
                              child: Container(
                              child: Text(
                                  dateToHuman(absences[0].LessonStartTime),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  )),
                              alignment: Alignment(1.0, 0.0),
                            ))
                          : Container(),
                      !isSingle
                          ? Expanded(
                              child: Container(
                              child: Text(absences[0].owner.name,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: absences[0].owner.color)),
                              alignment: Alignment(1.0, 0.0),
                            ))
                          : Container(),
                    ],
                  ),
                ),
                decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        style: BorderStyle.none,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    color: globals.isDark
                        ? Color.fromARGB(255, 15, 15, 15)
                        : Colors.white),
              )
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: globals.isDark
                    ? Color.fromARGB(255, 25, 25, 25)
                    : Colors.blueGrey[100],
                width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: globals.isDark
                ? Color.fromARGB(255, 25, 25, 25)
                : Colors.blueGrey[100],
          ),
        ),
      ),
    );
  }
}
