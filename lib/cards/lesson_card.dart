import 'package:filcnaplo/dialogs/choose_lesson_dialog.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/datas/lesson.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:filcnaplo/dialogs/lesson_dialog.dart';

import 'dart:async';

List<Widget> quickLessons = [];

class LessonCard extends StatefulWidget {
  List<Lesson> lessons;
  bool isLessonsTomorrow;
  BuildContext context;

  LessonCard(List<Lesson> lessons, BuildContext context) {
    this.lessons = lessons;
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
  bool isInit;

  String homeworkToThisSubject;

  @override
  void setState(fn) {
    isInit = false;
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    isInit = true;

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

    //States: Before first / First lesson / During lesson / During break / Last lesson / After last
    //              0             1               2             3               4            5
    if (lessons.first.start.isAfter(now))
      lessonCardState = 0;
    else if (previousLesson == null)
      lessonCardState = 1;
    else if (thisLesson == null && nextLesson == null)
      lessonCardState = 5;
    else if (nextLesson == null)
      lessonCardState = 4;
    else if (thisLesson != null)
      lessonCardState = 2;
    else if (previousLesson.end.isBefore(now) && nextLesson.start.isAfter(now))
      lessonCardState = 3;

    if (lessonCardState == 2) {
      //During a lesson, calculate previous and next break length
      prevBreakLength =
          thisLesson.start.difference(previousLesson.end).inMinutes;
      if (nextLesson != null)
        thisBreakLength = nextLesson.start.difference(thisLesson.end).inMinutes;
      minutesLeftOfThis = thisLesson.end.difference(now).inMinutes;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else if (lessonCardState == 3) {
      //During a break, calculate its length.
      prevBreakLength =
          nextLesson.start.difference(previousLesson.end).inMinutes;
      thisBreakLength = 0;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else if (lessonCardState == 4) {
      //During the last lesson
      prevBreakLength =
          thisLesson.start.difference(previousLesson.end).inMinutes;
      thisBreakLength = 0;
      minutesLeftOfThis = thisLesson.end.difference(now).inMinutes;
      minutesUntilNext = 0;
    } else if (lessonCardState == 1) {
      //During the first lesson
      prevBreakLength = 0;
      thisBreakLength = nextLesson.start.difference(thisLesson.end).inMinutes;
      minutesLeftOfThis = thisLesson.end.difference(now).inMinutes;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    } else if (lessonCardState == 5) {
      prevBreakLength = 0;
      thisBreakLength = 0;
      minutesUntilNext = 0;
    } else {
      //If before or after the school day, don't calculate breaks.
      prevBreakLength = 0;
      thisBreakLength = 0;
      minutesUntilNext = nextLesson.start.difference(now).inMinutes;
    }

    quickLessons = [];

    if (previousLesson != null) {
      quickLessons.add(LessonTile(
          context,
          previousLesson,
          I18n.of(context).lessonCardPrevious,
          (prevBreakLength == 0) ? "" : prevBreakLength.toString(),
          (previousLesson.count == -1) ? "+" : previousLesson.count.toString(),
          previousLesson.subject,
          previousLesson.isMissed
              ? I18n.of(context).substitutionMissed
              : previousLesson.teacher,
          (previousLesson.isSubstitution ? 1 : previousLesson.isMissed ? 2 : 0),
          (previousLesson.homework != null) ? true : false,
          getLessonRangeText(previousLesson),
          previousLesson.room));
    }

    if (thisLesson != null) {
      quickLessons.add(LessonTile(
          context,
          thisLesson,
          I18n.of(context).lessonCardNow((minutesLeftOfThis + 1).toString()),
          (thisBreakLength == 0) ? "" : thisBreakLength.toString(),
          (thisLesson.count == -1) ? "+" : thisLesson.count.toString(),
          thisLesson.subject,
          thisLesson.isMissed
              ? I18n.of(context).substitutionMissed
              : thisLesson.teacher,
          (thisLesson.isSubstitution ? 1 : thisLesson.isMissed ? 2 : 0),
          (thisLesson.homework != null) ? true : false,
          getLessonRangeText(thisLesson),
          thisLesson.room));
    }

    if (nextLesson != null) {
      quickLessons.add(LessonTile(
          context,
          nextLesson,
          I18n.of(context).lessonCardNext((minutesUntilNext + 1).toString()),
          "",
          (nextLesson.count == -1) ? "+" : nextLesson.count.toString(),
          nextLesson.subject,
          nextLesson.isMissed
              ? I18n.of(context).substitutionMissed
              : nextLesson.teacher,
          (nextLesson.isSubstitution ? 1 : nextLesson.isMissed ? 2 : 0),
          (nextLesson.homework != null) ? true : false,
          getLessonRangeText(nextLesson),
          nextLesson.room));
    }

    //If during lesson, that subject. If after lesson, previous subject. Otherwise, null.
    if ([1, 2, 4].contains(lessonCardState))
      homeworkToThisSubject = thisLesson.subject;
    else if ([3, 5].contains(lessonCardState))
      homeworkToThisSubject = previousLesson.subject;
  }

  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    _lessonCardBackend(now, widget.lessons, widget.isLessonsTomorrow);
    return Column(
      children: <Widget>[
        (quickLessons.length > 0)
            ? Container(
                padding: EdgeInsets.all(5.0),
                child: SizedBox(
                    height: 125,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: EdgeInsets.all(4.0),
                            child: quickLessons[index]);
                      },
                      itemCount: quickLessons.length,
                      viewportFraction: 0.95,
                      scale: 0.9,
                      loop: false,
                      index: isInit ? 1 : null,
                      pagination: SwiperCustomPagination(builder:
                          (BuildContext context, SwiperPluginConfig config) {
                        return Align(
                            alignment: Alignment.bottomCenter,
                            child: DotSwiperPaginationBuilder(
                                    activeColor: globals.isDark
                                        ? Colors.white24
                                        : Colors.black26,
                                    color: globals.isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                    size: 8.0,
                                    activeSize: 12.0)
                                .build(context, config));
                      }),
                    )),
              )
            : Container(),
        Row(
          children: <Widget>[
            (homeworkToThisSubject != null)
                ? Container(
                    margin: EdgeInsets.only(left: 10),
                    child: MaterialButton(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.home),
                          Text("+ " + I18n.of(context).homeworkAdd),
                        ],
                      ),
                      onPressed: _addHomeworkToThisSubject,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                              color: Theme.of(context).accentColor, width: 2)),
                    ),
                  )
                : Container(),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ],
    );
  }

  Widget LessonTile(
    BuildContext context,
    Lesson lesson,
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
        child: Row(children: <Widget>[
      Expanded(
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(tabText,
                              style: TextStyle(
                                  color: globals.isDark
                                      ? Colors.white
                                      : Colors.black)),
                          padding: EdgeInsets.fromLTRB(8, 1, 8, 0),
                          decoration: BoxDecoration(
                              color: globals.isDark
                                  ? Color.fromARGB(255, 25, 25, 25)
                                  : Colors.grey[350],
                              boxShadow: [
                                BoxShadow(blurRadius: 2, spreadRadius: -2)
                              ],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                child: GestureDetector(
                  onTap: () {
                    _lessonDialog(lesson);
                  },
                  child: Container(
                    child: ListTile(
                      leading: Text(lessonNumber,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      title: Text(capitalize(lessonSubject),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        lessonSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          hasHomework
                              ? Container(
                                  child: Icon(Icons.home),
                                  padding: EdgeInsets.all(5))
                              : Container(),
                          Column(
                            children: <Widget>[Text(startTime), Text(room)],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: globals.isDark
                            ? Colors.grey[700]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        boxShadow: [
                          BoxShadow(blurRadius: 2.5, spreadRadius: -2)
                        ]),
                  ),
                ),
                decoration: BoxDecoration(
                  color: globals.isDark
                      ? Color.fromARGB(255, 25, 25, 25)
                      : Colors.grey[350],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6)),
                ),
              ),
            ],
          ),
        ),
      ),
      (breakLength != "")
          ? Container(
              child: Text(
                breakLength,
                style: TextStyle(
                    fontSize: 18.0,
                    color: globals.isDark ? Colors.white : Colors.black),
                textAlign: TextAlign.center,
              ),
              width: 35.0,
              height: 35.0,
              margin: EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                  color: globals.isDark ? Colors.grey[600] : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 3, spreadRadius: -2)]),
              padding: EdgeInsets.all(4.0),
              alignment: Alignment(0, 0),
            )
          : Container(),
    ]));
  }

  Future<bool> _addHomeworkToThisSubject() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return ChooseLessonDialog(0, homeworkToThisSubject);
        });
  }

  Future<Null> _lessonDialog(Lesson lesson) async {
    return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return HomeworkDialog(lesson);
          },
        ) ??
        false;
  }
}
