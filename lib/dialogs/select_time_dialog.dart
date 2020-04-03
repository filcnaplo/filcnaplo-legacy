import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/generated/i18n.dart';

class TimeSelectDialog extends StatefulWidget {
  const TimeSelectDialog();
  @override
  TimeSelectDialogState createState() => TimeSelectDialogState();
}

class TimeSelectDialogState extends State<TimeSelectDialog> {
  int selectedTime = 1;

  void _onSelect(String sel, List<String> idok) {
    setState(() {
      selectedTime = idok.indexOf(sel);
      globals.selectedTimeForHomework = selectedTime;
      //TODO: ezt meg kéne jegyeztetni
    });
  }

  Widget build(BuildContext context) {
    List<String> timeOptionList = [
      I18n.of(context).dateDay,
      I18n.of(context).dateWeek,
      I18n.of(context).dateMonth,
      I18n.of(context).dateMonth2
    ];

    return SimpleDialog(
      title: Text(I18n.of(context).time),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        PopupMenuButton<String>(
          child: Container(
            child: Row(
              children: <Widget>[
                Text(
                  timeOptionList[globals.selectedTimeForHomework],
                  style: TextStyle(color: null, fontSize: 17.0),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: null,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 2.0),
          ),
          onSelected: (String selected) {
            _onSelect(selected, timeOptionList);
          },
          itemBuilder: (BuildContext context) {
            return timeOptionList.map((String sor) {
              return PopupMenuItem<String>(
                value: sor,
                child: Text(sor),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
