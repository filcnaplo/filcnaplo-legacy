import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/screens/Screen.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Student.dart';
import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/Dialog/AbsentDialog.dart';
import 'package:filcnaplo/GlobalDrawer.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(home: AbsentsScreen()));
}

class AbsentsScreen extends StatefulWidget {
  @override
  AbsentsScreenState createState() => AbsentsScreenState();
}

class AbsentsScreenState extends State<AbsentsScreen> {
  Map<String, List<Absence>> absents = Map();

  List<User> users;
  User selectedUser;

  bool hasOfflineLoaded = false;
  bool hasLoaded = true;

  void initSelectedUser() async {
    setState(() {
      selectedUser = globals.selectedUser;
    });
  }

  @override
  void initState() {
    super.initState();
    initSelectedUser();
    setState(() {
      _getOffline();
      _onRefresh(showErrors: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return new Screen(
        new Text(capitalize(I18n.of(context).absenceTitle)),
        new Container(
            child: hasOfflineLoaded
                ? new Column(children: <Widget>[
                    !hasLoaded
                        ? Container(
                            child: new LinearProgressIndicator(
                              value: null,
                            ),
                            height: 3,
                          )
                        : Container(
                            height: 3,
                          ),
                    new Expanded(
                      child: new RefreshIndicator(
                          child: new ListView.builder(
                            itemBuilder: _itemBuilder,
                            itemCount: absents.length,
                          ),
                          onRefresh: _onRefresh),
                    ),
                  ])
                : new Center(child: new CircularProgressIndicator())),
        "/home",
        <Widget>[
          Tooltip(
            child: new IconButton(
                icon: new Icon(Icons.info),
                onPressed: () {
                  return showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return new AbsentDialog();
                        },
                      ) ??
                      false;
                }),
            message: I18n.of(context).statistics,
          ),
        ]
    );
  }

  Future<Null> _onRefresh({bool showErrors = true}) async {
    setState(() {
      hasLoaded = false;
    });

    Completer<Null> completer = Completer<Null>();

    await globals.selectedAccount.refreshStudentString(false, showErrors);
    absents = globals.selectedAccount.absents;

    if (mounted)
      setState(() {
        hasLoaded = true;
        completer.complete();
      });

    return completer.future;
  }

  Future<Null> _getOffline() async {
    setState(() {
      hasOfflineLoaded = false;
    });

    Completer<Null> completer = Completer<Null>();

    await globals.selectedAccount.refreshStudentString(true, false);
    absents = globals.selectedAccount.absents;

    if (mounted)
      setState(() {
        hasOfflineLoaded = true;
        completer.complete();
      });

    return completer.future;
  }

  Future<Null> absenceDialog(Absence absence) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // the user doesn't have to tap the button.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(absence.TypeName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(capitalize(I18n.of(context).absenceMode) +
                    ": " +
                    absence.ModeName),
                Text(capitalize(I18n.of(context).lessonSubject) +
                    ": " +
                    absence.Subject),
                Text(capitalize(I18n.of(context).lessonTeacher) +
                    ": " +
                    absence.Teacher),
                Text(capitalize(I18n.of(context).absenceTime) +
                    ": " +
                    dateToHuman(absence.LessonStartTime)),
                Text(capitalize(I18n.of(context).administrationTime) +
                    ": " +
                    dateToHuman(absence.CreatingTime)),
                Text(capitalize(I18n.of(context).justificationState) +
                    ": " +
                    absence.JustificationStateName),
                Text(capitalize(I18n.of(context).justificationMode) +
                    ": " +
                    absence.JustificationTypeName),
                absence.DelayTimeMinutes != 0
                    ? Text(I18n.of(context).delayMins +
                        absence.DelayTimeMinutes.toString() +
                        " " +
                        I18n.of(context).timeMinute)
                    : Container(),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Widget _itemBuilder(BuildContext context, int index) {
    List<Widget> children = List();
    List<Absence> thisAbsence = absents[absents.keys.toList()[index]];

    bool unjust = false;
    bool just = false;
    bool bejust = false;

    for (Absence absence in thisAbsence)
      children.add(ListTile(
        leading: Icon(
            absence.DelayTimeMinutes == 0
                ? iconifyState(absence.JustificationState)
                : (Icons.watch_later),
            color: colorifyState(absence.JustificationState)),
        title: Text(absence.Subject),
        subtitle: Text(absence.Teacher),
        trailing: Text(dateToHuman(absence.LessonStartTime)),
        onTap: () {
          absenceDialog(absence);
        },
      ));

    for (Absence absence in thisAbsence) {
      if (absence.isUnjustified())
        unjust = true;
      else if (absence.isJustified())
        just = true;
      else if (absence.isBeJustified()) bejust = true;
    }

    String state = "";
    if (unjust && !just && !bejust)
      state = Absence.UNJUSTIFIED;
    else if (!unjust && just && !bejust)
      state = Absence.JUSTIFIED;
    else if (!unjust && !just && bejust) state = Absence.BE_JUSTIFIED;

    Widget title = Container(
      child: Row(
        children: <Widget>[
          Icon(
            iconifyState(state),
            color: colorifyState(state),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(dateToHuman(thisAbsence[0].LessonStartTime) +
                dateToWeekDay(thisAbsence[0].LessonStartTime, context) +
                " (" +
                thisAbsence.length.toString() +
                " ${I18n.of(context).pcs})"),
          ),
        ],
      ),
    );

    return ExpansionTile(
      title: title,
      children: children,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
