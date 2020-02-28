//Contributed by RedyAu

import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import '../Utils/StringFormatter.dart';
import '../Datas/Lesson.dart';
import '../Helpers/TimetableHelper.dart';
import '../Dialog/NewHomeworkDialog.dart';

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
  String _subject = "...";

  Widget build(BuildContext context) {
    if (subjects.isEmpty) _getLessons();

    return new SimpleDialog(
      title: new Text(capitalize(I18n.of(context).homeworkAdd) + "..."),
      children: <Widget>[
        subjects.isEmpty
            ? Column(
                children: <Widget>[
                  Container(
                      width: 45,
                      height: 45,
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator()),
                  Text("Órák betöltése..."),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            value: subject, child: Text(capitalize(subject)));
                      }).toList(),
                      onChanged: (String selectedSubject) {
                        setState(() {
                          _subject = selectedSubject;
                        });
                      },
                    ),
                  ),
                  new Text(
                    "órához",
                    style: new TextStyle(fontSize: 15),
                  ),
                  Container(
                    child: new FlatButton(
                      child: new Text("MEGNYITÁS",
                          style: new TextStyle(
                              color: (_subject == "...")
                                  ? Colors.grey
                                  : Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold)),
                      onPressed:
                          (_subject == "...") ? null : _openHomeworkDialog,
                    ),
                    margin: new EdgeInsets.only(top: 10),
                  )
                ],
              ),
      ],
    );
  }

  void _openHomeworkDialog() async {
    print(_subject);
    if (_searchFor == SearchFor.next) {
      print(lessons
          .firstWhere((Lesson lesson) => (lesson.subject == _subject))
          .date);
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new NewHomeworkDialog(lessons
                .firstWhere((Lesson lesson) => (lesson.subject == _subject)));
          });
    } else {
      lessons.clear();
      lessons = await getLessons(
          now.subtract(Duration(days: 7)), now, globals.selectedUser, false);
      print(lessons
          .lastWhere((Lesson lesson) => (lesson.subject == _subject))
          .date);
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new NewHomeworkDialog(lessons
                .lastWhere((Lesson lesson) => (lesson.subject == _subject)));
          });
    }
  }

  void _getLessons() async {
    lessons = await getLessons(
        now, now.add(Duration(days: 7)), globals.selectedUser, false);
    for (Lesson lesson in lessons) {
      if (!subjects.contains(lesson.subject)) subjects.add(lesson.subject);
    }
    subjects.sort((a, b) => a.compareTo(b));
    subjects.insert(0, "...");
    setState(() {});
    //for (String s in subjects) print(s + "\n");
  }

  @override
  void initState() {
    super.initState();
  }
}
