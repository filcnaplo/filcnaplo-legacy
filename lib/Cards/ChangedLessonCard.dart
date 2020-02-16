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
      child: new Card(
        margin: EdgeInsets.all(6.0),
        child: new Container(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: Wrap(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          isSubstitution
                              ? new Text(lesson.depTeacher + ", ",
                                  style: new TextStyle(
                                      fontSize: 18.0, color: Colors.green))
                              : new Container(),
                          new Text(lesson.count.toString() + ". ",
                              style: new TextStyle(
                                  fontSize: 18.0,
                                  color: globals.CurrentTextColor)),
                          new Text(I18n.of(context).lesson + ", ",
                              style: new TextStyle(fontSize: 18.0)),
                          new Text(lesson.subject,
                              style: new TextStyle(
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
                new Container(
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
                    child: new Padding(
                      padding: new EdgeInsets.all(0.0),
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.cancel,
                                color: globals.isDark
                                    ? Colors.white
                                    : Color.fromARGB(255, 15, 15, 15)),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: new Text(
                                (isSubstitution
                                    ? I18n.of(context).substitution
                                    : I18n.of(context).substitutionMissed),
                                style: new TextStyle(fontSize: 18.0)),
                          ),
                          new Expanded(
                            child: new Container(
                              child: new Text(
                                  lessonToHuman(lesson) +
                                      dateToWeekDay(lesson.date, context),
                                  style: new TextStyle(
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
            decoration: new BoxDecoration(
              border: Border.all(
                  color: globals.isDark
                      ? Color.fromARGB(255, 25, 25, 25)
                      : Colors.blueGrey[100],
                  width: 2.5),
              borderRadius: new BorderRadius.all(Radius.circular(5)),
              color: globals.isDark
                  ? Color.fromARGB(255, 25, 25, 25)
                  : Colors.blueGrey[100],
            )),
      ),
    );
  }
}
