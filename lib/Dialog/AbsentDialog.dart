import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Student.dart';
import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/Utils/StringFormatter.dart';

class AbsentDialog extends StatefulWidget {
  const AbsentDialog();

  @override
  AbsentDialogState createState() => new AbsentDialogState();
}

class AbsentDialogState extends State<AbsentDialog> {
  int sumOfParentalAbsences = 0;
  int sumOfAllAbsences = 0;
  int sumOfDelayMinutes = 0;

  List<User> users;
  Map<String, List<Absence>> absents = new Map();

  void initSelectedUser() async {
    absents = globals.selectedAccount.absents;
    sumOfAllAbsences = 0;
    sumOfParentalAbsences = 0;
    sumOfDelayMinutes = 0;

    setState(() {
      absents.forEach((String day, List<Absence> absencesOnDay) {
        if (absencesOnDay[0].isParental() &&
            absencesOnDay[0].owner.isSelected()) sumOfParentalAbsences++;
        if (absencesOnDay[0].owner.isSelected())
          for (Absence absence in absencesOnDay)
            if (absence.DelayTimeMinutes == 0)
              sumOfAllAbsences++;
            else
              sumOfDelayMinutes += absence.DelayTimeMinutes;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initSelectedUser();
  }

  Widget build(BuildContext context) {
    return new SimpleDialog(
        title: new Text(capitalize(I18n.of(context).statistics)),
        titlePadding: EdgeInsets.all(16),
        contentPadding: const EdgeInsets.all(5.0),
        children: <Widget>[
          Container(
            child: new Text(
              I18n
                  .of(context)
                  .absenceParental(sumOfParentalAbsences.toString()),
              style: TextStyle(fontSize: 16.0),
            ),
            margin: EdgeInsets.all(8),
          ),
          Container(
            child: new Text(
              I18n.of(context).absenceAll(sumOfAllAbsences.toString()),
              style: TextStyle(fontSize: 16.0),
            ),
            margin: EdgeInsets.all(8),
          ),
          Container(
            child: new Text(
              I18n.of(context).delayAll(sumOfDelayMinutes.toString()),
              style: TextStyle(fontSize: 16.0),
            ),
            margin: EdgeInsets.all(8),
          ),
        ]);
  }
}
