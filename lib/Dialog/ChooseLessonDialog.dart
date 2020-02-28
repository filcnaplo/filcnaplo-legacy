//contributed by RedyAu

import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import '../Utils/StringFormatter.dart';
import '../Datas/Lesson.dart';
import '../Helpers/TimetableHelper.dart';

class ChooseLessonDialog extends StatefulWidget {
  @override
  ChooseLessonDialogState createState() => new ChooseLessonDialogState();
}

enum SearchFor { next, previous }

class ChooseLessonDialogState extends State<ChooseLessonDialog> {
  SearchFor _searchFor = SearchFor.next;
  List<String> subjects = [];
  List<Lesson> lessons = [];
  DateTime now = new DateTime.now();
  String _subject;
  

  Widget build(BuildContext context) {
    if (subjects.isEmpty) _getLessons();

    return new SimpleDialog(
      title: new Text(capitalize(I18n.of(context).homeworkAdd) + "..."),
      children: <Widget>[
        subjects.isEmpty
            ? Column(
              children: <Widget>[
                Container(width: 45, height: 45, padding: EdgeInsets.all(10), child: CircularProgressIndicator()),
                Text("Órák betöltése..."),
              ],
            )
            : Column(
                children: <Widget>[
                  new ListTile(
                      leading: new Radio(
                        value: SearchFor.next,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: new Text("a következő")),
                  new ListTile(
                      leading: new Radio(
                        value: SearchFor.previous,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: new Text("a legutóbbi")),
                  new Container(
                    child: new DropdownButton<String>(
                      value: _subject,
                      items: subjects.map((String subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(capitalize(subject))
                          );
                      }).toList(),
                    onChanged: (String selectedSubject) {
                      setState(() {
                        _subject = selectedSubject;
                      });
                    },
                    ),
                  )
                ],
              ),
      ],
    );
  }

  void _getLessons() async {
    lessons = await getLessons(
        now, now.add(Duration(days: 7)), globals.selectedUser, false);
    for (Lesson lesson in lessons) {
      if (!subjects.contains(lesson.subject)) subjects.add(lesson.subject);
    }
    setState(() {});
    //for (String s in subjects) print(s + "\n");
  }

  @override
  void initState() {
    super.initState();
  }
}
