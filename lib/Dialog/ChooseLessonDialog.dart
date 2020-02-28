//contributed by RedyAu

import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import '../Utils/StringFormatter.dart';

class ChooseLessonDialog extends StatefulWidget {

  @override
  ChooseLessonDialogState createState() => new ChooseLessonDialogState();
}

enum SearchFor {next, previous}

class ChooseLessonDialogState extends State<ChooseLessonDialog> {

  SearchFor _searchFor = SearchFor.next;

  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text(capitalize(I18n.of(context).homeworkAdd) + "..."),
      children: <Widget>[
        new ListTile(
          leading: new Radio(
            value: SearchFor.next,
            groupValue: _searchFor,
            onChanged: (SearchFor value) {
              setState(() {_searchFor = value;});
            },
          ),
          title: new Text("a következő")
        ),
        new ListTile(
          leading: new Radio(
            value: SearchFor.previous,
            groupValue: _searchFor,
            onChanged: (SearchFor value) {
              setState(() {_searchFor = value;});
            },
          ),
          title: new Text("a legutóbbi")
        )
      ],);
  }
}