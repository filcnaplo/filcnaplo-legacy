import 'package:filcnaplo/dialogs/lesson_dialog.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/datas/lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/utils/string_formatter.dart';

class TomorrowLessonCard extends StatelessWidget {
  List<Lesson> lessons;
  int numOfAbsences;
  BuildContext context;
  DateTime now;

  TomorrowLessonCard(List<Lesson> lessons, BuildContext context, DateTime now) {
    this.now = now;
    this.lessons = lessons;
    lessons.removeWhere(
        (Lesson l) => l.start.day != now.add(Duration(days: 1)).day);
    numOfAbsences = lessons.length;
    this.context = context;
  }

  @override
  Key get key => Key(getDate());

  String getDate() {
    return "c";
  }

  Lesson getNext() {
    for (Lesson l in lessons) {
      if (l.start.isAfter(now)) {
        return l;
      }
    }
  }

  void openDialog() {
    _lessonsDialog(lessons);
  }

  Future<Null> _lessonInfoDialog(Lesson lesson) async {
    return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return HomeworkDialog(lesson);
          },
        ) ??
        false;
  }

  Future<Null> _lessonsDialog(List<Lesson> lessons) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SingleChildScrollView(
              child: ListBody(
                  children: lessons.map((Lesson lesson) {
                return Column(children: <Widget>[
                  ListTile(
                    title: Text(
                      lesson.subject,
                      style: TextStyle(
                          color:
                              (lesson.end.isBefore(now)) ? Colors.grey : null),
                    ),
                    enabled: true,
                    onTap: () {
                      _lessonInfoDialog(lesson);
                    },
                    subtitle: Text(
                      lesson.teacher,
                      style: TextStyle(
                          color:
                              (lesson.end.isBefore(now)) ? Colors.grey : null),
                    ),
                    leading: Container(
                      child: Text(
                        lesson.count != -1 ? lesson.count.toString() : "+",
                        style: TextStyle(
                            color:
                                (lesson.end.isBefore(now)) ? Colors.grey : null,
                            fontSize: 21),
                      ),
                      alignment: Alignment(0, 1),
                      height: 40,
                      width: 20,
                    ),
                  ),
                  Row(
                    //Bottom row containing room number and a house icon if there is homework set for the lesson.
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          lesson.homework != null ? "⌂" : "",
                        ),
                      ),
                      Expanded(
                        child: Text(
                          lesson.room,
                          style: TextStyle(
                              color: (lesson.end.isBefore(now))
                                  ? Colors.grey
                                  : null),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.blueGrey,
                  ),
                ]);
              }).toList()),
            ),
          ],
          title: Text(
              "Holnapi órák"), //TODO: Use translation DB everywhere (duplicate comment btw)
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
        child: Column(
          children: <Widget>[
            Container(
              child: Wrap(
                children: <Widget>[
                  Text(
                    capitalize(I18n.of(context).lessonTomorrow),
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: Text(lessons.length.toString(),
                        style: TextStyle(
                            fontSize: 18.0, color: globals.CurrentTextColor)),
                  ),
                  Text(
                    I18n.of(context).lessonHave,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    softWrap: false,
                    maxLines: 2,
                  ),
                ],
                alignment: WrapAlignment.start,
              ),
              alignment: Alignment(-1, 0),
              padding: EdgeInsets.all(10.0),
            ),
          ],
        ),
      ),
    );
  }
}
