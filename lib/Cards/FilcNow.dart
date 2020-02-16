//Contributed by RedyAu

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:filcnaplo/globals.dart' as globals;
import '../Datas/Lesson.dart';
import '../Utils/StringFormatter.dart';
import '../Utils/StringFormatter.dart';
import '../Utils/StringFormatter.dart';

class FilcNowCard extends StatefulWidget {
  List<Lesson> lessons;
  bool isLessonsTomorrow;
  BuildContext context;

  FilcNowCard(
      List<Lesson> lessons, bool isLessonsTomorrow, BuildContext context) {
    this.lessons = lessons;
    this.isLessonsTomorrow = isLessonsTomorrow;
    this.context = context;
  }

  @override
  _FilcNowCardState createState() => _FilcNowCardState();
}

class _FilcNowCardState extends State<FilcNowCard> {
  DateTime now;

  Lesson previousLesson;
  Lesson thisLesson;
  Lesson nextLesson;

  int prevBreakLength;
  int thisBreakLength;
  int minutesUntilNext;
  int minutesLeftOfThis;

  int filcNowState;

  void _filcNowBackend(
      DateTime now, List<Lesson> lessons, bool isLessonsTomorrow) {
    previousLesson = lessons.lastWhere(
        (Lesson lesson) => (lesson.end.isBefore(now)),
        orElse: () => null);
    thisLesson = lessons.lastWhere(
        (Lesson lesson) =>
            (lesson.start.isBefore(now) && lesson.end.isAfter(now)),
        orElse: () => null);
    nextLesson = lessons.firstWhere(
        (Lesson lesson) => (lesson.start.isAfter(now)),
        orElse: () => null);

    //States: Before first / During lesson / During break / After last
    //              0             1               2             3
    if (lessons.first.start.isAfter(now))
      filcNowState = 0;
    else if (thisLesson != null)
      filcNowState = 1;
    else if (isLessonsTomorrow)
      filcNowState = 3;
    else if (previousLesson.end.isBefore(now) && nextLesson.start.isAfter(now))
      filcNowState = 2;

    if (filcNowState == 1) {
      //During a lesson, calculate previous and next break length
      prevBreakLength =
          thisLesson.start.difference(previousLesson.end).inMinutes;
      thisBreakLength = nextLesson.start.difference(thisLesson.end).inMinutes;
      minutesLeftOfThis = thisLesson.end.difference(now).inMinutes;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else if (filcNowState == 2) {
      //During a break, calculate its length.
      prevBreakLength = 0;
      thisBreakLength =
          nextLesson.start.difference(previousLesson.end).inMinutes;
    } else {
      //If before or after the school day, don't calculate breaks.
      prevBreakLength = 0;
      thisBreakLength = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    now = new DateTime.now();
    _filcNowBackend(now, widget.lessons, widget.isLessonsTomorrow);
    return new Column(
      children: <Widget>[
        LessonTile(
            "Volt",
            "", //(prevBreakLength.toString() + "perc"),
            previousLesson.count.toString(),
            previousLesson.subject,
            previousLesson.isMissed ? "Elmarad" : previousLesson.teacher,
            (previousLesson.isSubstitution
                ? 1
                : previousLesson.isMissed ? 2 : 0),
            (previousLesson.homework != null) ? true : false,
            getLessonStartText(previousLesson),
            previousLesson.room),
        LessonTile(
            "Épp - " + (minutesLeftOfThis + 1).toString() + " perc van hátra",
            (prevBreakLength.toString() + " perc"),
            thisLesson.count.toString(),
            thisLesson.subject,
            thisLesson.isMissed ? "Elmarad" : thisLesson.teacher,
            (thisLesson.isSubstitution ? 1 : thisLesson.isMissed ? 2 : 0),
            (thisLesson.homework != null) ? true : false,
            getLessonStartText(thisLesson),
            thisLesson.room),
        LessonTile(
            "Lesz - " + (minutesUntilNext + 1).toString() + " perc múlva",
            (thisBreakLength.toString() + " perc"),
            nextLesson.count.toString(),
            nextLesson.subject,
            nextLesson.isMissed ? "Elmarad" : nextLesson.teacher,
            (nextLesson.isSubstitution ? 1 : nextLesson.isMissed ? 2 : 0),
            (nextLesson.homework != null) ? true : false,
            getLessonStartText(nextLesson),
            nextLesson.room),
      ],
    );
  }
}

Widget LessonTile(
  //Builder of a single lesson in the 3 or 2 part list
  String tabText,
  String breakLength,
  String lessonNumber,
  String lessonSubject,
  String lessonSubtitle,
  int lessonState, //0: normally held, 1: substituted, 2: not held
  bool hasHomework,
  String startTime,
  String room,
) {
  return Container(
    child: new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Flexible(
              child: new Row(
                children: <Widget>[
                  new SizedBox(width: 20),
                  new Container(
                    child: new Text(tabText),
                    decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(4))),
                  )
                ],
              ),
            ),
            new Text(breakLength),
          ],
        ),
        new ListTile(
          leading: new Text(lessonNumber),
          title: new Text(lessonSubject),
          subtitle: new Text(lessonSubtitle),
          trailing: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Icon(Icons.home),
              new Column(
                children: <Widget>[new Text(startTime), new Text(room)],
              ),
              new IconButton(icon: Icon(Icons.home), onPressed: null)
            ],
          ),
        ),
      ],
    ),
  );
}
