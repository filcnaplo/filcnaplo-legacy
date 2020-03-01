import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

class ChangedLessonCard extends StatelessWidget {
  Lesson lesson;
  BuildContext context;

  ChangedLessonCard(Lesson lesson, BuildContext context) {
    this.lesson = lesson;
    this.context = context;
  }

  @override
  Key get key => new Key(getDate());

  String getDate() {
    return lesson.start.toIso8601String();
  }

  bool get isSubstitution => lesson.depTeacher.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.all(6.0),
        child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Wrap(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          isSubstitution
                              ? Text(lesson.depTeacher + ", ",
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.green))
                              : Container(),
                          Text(lesson.count.toString() + ". ",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: globals.CurrentTextColor)),
                          Text(I18n.of(context).lesson + ", ",
                              style: TextStyle(fontSize: 18.0)),
                          Text(lesson.subject,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: globals.CurrentTextColor)),
                        ],
                      ),
                    ].where((Widget w) => w != null).toList(),
                    alignment: WrapAlignment.start,
                  ),
                  alignment: Alignment(-1, 0),
                  color: globals.isDark
                      ? Color.fromARGB(255, 25, 25, 25)
                      : Colors.blueGrey[100],
                  padding: EdgeInsets.all(12.0),
                ),
                Container(
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
                          : Colors.white,
                    ),
                    padding: EdgeInsets.all(5.0),
                    child: Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.cancel,
                                color: globals.isDark
                                    ? Colors.white
                                    : Color.fromARGB(255, 15, 15, 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                                (isSubstitution
                                    ? I18n.of(context).substitution
                                    : I18n.of(context).substitutionMissed),
                                style: TextStyle(fontSize: 18.0)),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                  lessonToHuman(lesson) +
                                      dateToWeekDay(lesson.date, context),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  )),
                              alignment: Alignment(1.0, 0.0),
                              padding: EdgeInsets.only(right: 4.0),
                            ),
                          )
                        ],
                      ),
                    )),
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
            )),
      ),
    );
  }
}
