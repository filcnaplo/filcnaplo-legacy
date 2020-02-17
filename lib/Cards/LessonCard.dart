//Contributed by RedyAu

import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/generated/i18n.dart';

import 'dart:async';

class LessonCard extends StatefulWidget {
  List<Lesson> lessons;
  bool isLessonsTomorrow;
  BuildContext context;

  LessonCard(
      List<Lesson> lessons, bool isLessonsTomorrow, BuildContext context) {
    this.lessons = lessons;
    this.isLessonsTomorrow = isLessonsTomorrow;
    this.context = context;
  }

  @override
  _LessonCardState createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  String _now;
  DateTime now;
  Timer _updater;

  Lesson previousLesson;
  Lesson thisLesson;
  Lesson nextLesson;

  int prevBreakLength;
  int thisBreakLength;
  int minutesUntilNext;
  int minutesLeftOfThis;

  int lessonCardState;

  @override
  void initState() {
    super.initState();

    _now = DateTime.now().second.toString();

    _updater = Timer.periodic(Duration(seconds: 10), (Timer t) {
      setState(() {
        _now = DateTime.now().second.toString();
      });
    });
  }

  void _lessonCardBackend(
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
      lessonCardState = 0;
    else if (thisLesson != null)
      lessonCardState = 1;
    /*else if (isLessonsTomorrow)
      lessonCardState = 3;*/
    else if (previousLesson.end.isBefore(now) && nextLesson.start.isAfter(now))
      lessonCardState = 2;

    //print("FilcNow State: " + lessonCardState.toString());

    if (lessonCardState == 1) {
      //During a lesson, calculate previous and next break length
      prevBreakLength =
          thisLesson.start.difference(previousLesson.end).inMinutes;
      thisBreakLength = nextLesson.start.difference(thisLesson.end).inMinutes;
      minutesLeftOfThis = thisLesson.end.difference(now).inMinutes;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else if (lessonCardState == 2) {
      //During a break, calculate its length.
      prevBreakLength = 0;
      thisBreakLength =
          nextLesson.start.difference(previousLesson.end).inMinutes;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else {
      //If before or after the school day, don't calculate breaks.
      prevBreakLength = 0;
      thisBreakLength = 0;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    now = new DateTime.now();
    _lessonCardBackend(now, widget.lessons, widget.isLessonsTomorrow);
    return Container(
      padding: EdgeInsets.all(5),
      child: new Column(
        children: <Widget>[
          (previousLesson != null)
              ? LessonTile(
                  context,
                  false,
                  I18n.of(context).lessonCardPrevious,
                  "",
                  (previousLesson.count == -1) ? "+" : previousLesson.count.toString(),
                  previousLesson.subject,
                  previousLesson.isMissed
                      ? I18n.of(context).substitutionMissed
                      : previousLesson.teacher,
                  (previousLesson.isSubstitution
                      ? 1
                      : previousLesson.isMissed ? 2 : 0),
                  (previousLesson.homework != null) ? true : false,
                  getLessonRangeText(previousLesson),
                  previousLesson.room)
              : Container(),
          (thisLesson != null) //Only show this lesson card during a lesson
              ? LessonTile(
                  context,
                  true,
                  I18n.of(context)
                      .lessonCardNow((minutesLeftOfThis + 1).toString()),
                  (prevBreakLength.toString() +
                      " " +
                      I18n.of(context).timeMinute),
                  (thisLesson.count == -1) ? "+" : thisLesson.count.toString(),
                  thisLesson.subject,
                  thisLesson.isMissed
                      ? I18n.of(context).substitutionMissed
                      : thisLesson.teacher,
                  (thisLesson.isSubstitution ? 1 : thisLesson.isMissed ? 2 : 0),
                  (thisLesson.homework != null) ? true : false,
                  getLessonRangeText(thisLesson),
                  thisLesson.room)
              : Container(),
          (nextLesson != null)
              ? LessonTile(
                  context,
                  false,
                  I18n.of(context)
                      .lessonCardNext((minutesUntilNext + 1).toString()),
                  (lessonCardState == 0)
                      ? ""
                      : (thisBreakLength.toString() +
                          " " +
                          I18n.of(context).timeMinute),
                  (nextLesson.count == -1) ? "+" : nextLesson.count.toString(),
                  nextLesson.subject,
                  nextLesson.isMissed
                      ? I18n.of(context).substitutionMissed
                      : nextLesson.teacher,
                  (nextLesson.isSubstitution ? 1 : nextLesson.isMissed ? 2 : 0),
                  (nextLesson.homework != null) ? true : false,
                  getLessonRangeText(nextLesson),
                  nextLesson.room)
              : Container(),
        ],
      ),
    );
  }
}

Widget LessonTile(
  //Builder of a single lesson in the 3 or 2 part list
  BuildContext context,
  bool isThis,
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
        new SizedBox(height: 3),
        new Row(
          children: <Widget>[
            new Flexible(
              child: new Row(
                children: <Widget>[
                  new SizedBox(width: 20),
                  new Container(
                    child: new Text(tabText,
                        style: new TextStyle(
                            color: (isThis !=
                                    globals
                                        .isDark) //Very complicated, don't question it. Explanatory sheet at issue #46
                                ? Colors.white
                                : Colors.black)),
                    padding: EdgeInsets.fromLTRB(8, 1, 8, 0),
                    decoration: new BoxDecoration(
                        color: isThis
                            ? globals.isDark
                                ? Colors.grey[350]
                                : Colors.grey[900]
                            : globals.isDark
                                ? Colors.grey[600]
                                : Colors.grey[400],
                        boxShadow: [
                          new BoxShadow(blurRadius: 3, spreadRadius: -2)
                        ],
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4))),
                  ),
                ],
              ),
            ),
            Transform.translate(
                offset: Offset(-7, -3), child: new Text(breakLength)),
          ],
        ),
        Container(
          child: new ListTile(
            leading: new Text(lessonNumber,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            title: new Text(capitalize(lessonSubject),
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: new Text(lessonSubtitle),
            trailing: new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                hasHomework
                    ? new Container(
                        child: new Icon(Icons.home), padding: EdgeInsets.all(5))
                    : new Container(),
                new Column(
                  children: <Widget>[new Text(startTime), new Text(room)],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
                //new IconButton(icon: Icon(Icons.home), onPressed: null)
              ],
            ),
          ),
          decoration: new BoxDecoration(
              /*color: isThis
              ? Theme.of(context).
              :,*/
              color: isThis
                  ? globals.isDark ? Colors.grey[700] : Colors.grey[350]
                  : globals.isDark ? Colors.grey[800] : Colors.white,
              borderRadius: new BorderRadius.all(Radius.circular(6)),
              boxShadow: [new BoxShadow(blurRadius: 3, spreadRadius: -2)]),
        ),
        new SizedBox(height: 3),
      ],
    ),
  );
}
