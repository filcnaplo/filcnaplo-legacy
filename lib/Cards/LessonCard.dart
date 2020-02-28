import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:filcnaplo/Dialog/LessonDialog.dart';

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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
    /*else if (isLessonsTomorrow)
      lessonCardState = 3;*/
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
      prevBreakLength = 0;
      thisBreakLength =
          nextLesson.start.difference(previousLesson.end).inMinutes;
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
          "",
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
          (prevBreakLength == 0) ? "" : (prevBreakLength.toString() + " "),
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
          (lessonCardState == 0 && thisBreakLength == 0)
              ? ""
              : (thisBreakLength.toString() + " "),
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
  }

  @override
  Widget build(BuildContext context) {
    now = new DateTime.now();
    _lessonCardBackend(now, widget.lessons, widget.isLessonsTomorrow);
    return (quickLessons.length > 0)
        ? Container(
            padding: EdgeInsets.all(5.0),
            child: new SizedBox(
                height: 125,
                child: new Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                        margin: EdgeInsets.all(4.0),
                        child: quickLessons[index]);
                  },
                  itemCount: quickLessons.length,
                  viewportFraction: 0.95,
                  scale: 0.9,
                  loop: false,
                  pagination: new SwiperCustomPagination(builder:
                      (BuildContext context, SwiperPluginConfig config) {
                    return new Align(
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
        : Container();
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
        child: new Row(children: <Widget>[
      new Expanded(
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          child: new Text(tabText,
                              style: new TextStyle(
                                  color: globals.isDark
                                      ? Colors.white
                                      : Colors.black)),
                          padding: EdgeInsets.fromLTRB(8, 1, 8, 0),
                          decoration: new BoxDecoration(
                              color: globals.isDark
                                  ? Color.fromARGB(255, 25, 25, 25)
                                  : Colors.grey[350],
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
                ],
              ),
              Container(
                child: new GestureDetector(
                  onTap: () {
                    _lessonDialog(lesson);
                  },
                  child: Container(
                    child: new ListTile(
                      leading: new Text(lessonNumber,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      title: new Text(capitalize(lessonSubject),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: new Text(
                        lessonSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      trailing: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          hasHomework
                              ? new Container(
                                  child: new Icon(Icons.home),
                                  padding: EdgeInsets.all(5))
                              : new Container(),
                          new Column(
                            children: <Widget>[
                              new Text(startTime),
                              new Text(room)
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                    ),
                    decoration: new BoxDecoration(
                        color: globals.isDark
                            ? Colors.grey[700]
                            : Colors.grey[100],
                        borderRadius: new BorderRadius.all(Radius.circular(6)),
                        boxShadow: [
                          new BoxShadow(blurRadius: 3, spreadRadius: -2)
                        ]),
                  ),
                ),
                decoration: new BoxDecoration(
                  color: globals.isDark
                      ? Color.fromARGB(255, 25, 25, 25)
                      : Colors.grey[350],
                  borderRadius: new BorderRadius.only(
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
              child: new Text(
                breakLength,
                style: TextStyle(
                    fontSize: 18.0,
                    color: globals.isDark ? Colors.white : Colors.black),
                textAlign: TextAlign.center,
              ),
              width: 40.0,
              height: 35.0,
              margin: EdgeInsets.only(left: 8.0),
              decoration: new BoxDecoration(
                  color: globals.isDark ? Colors.grey[600] : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: [new BoxShadow(blurRadius: 3, spreadRadius: -2)]),
              padding: EdgeInsets.all(4.0),
              alignment: new Alignment(0, 0),
            )
          : Container(),
    ]));
  }

  Future<Null> _lessonDialog(Lesson lesson) async {
    return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new HomeworkDialog(lesson);
          },
        ) ??
        false;
  }
}
