import 'package:filcnaplo/models/lesson_entry.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:filcnaplo/dialogs/lesson_dialog.dart';
import 'package:filcnaplo/utils/lesson_entry_builder.dart';

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

enum LessonCardTab { previous, current, next, normal }

class _LessonCardState extends State<LessonCard> {
  String _now;
  DateTime now;
  Timer _updater;

  Lesson previousLesson;
  Lesson thisLesson;
  Lesson nextLesson;
  Lesson nextNextLesson;

  int prevBreakLength;
  int thisBreakLength;
  int nextBreakLength;
  int minutesUntilNext;
  int minutesLeftOfThis;

  int lessonCardState;
  bool isInit;

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

  List<Lesson> _lessonCardBackend(
      DateTime now, List<Lesson> justLessons, bool isLessonsTomorrow) {
    List<LessonEntry> lessons = lessonEntryBuilder(justLessons);

    globals.currentLesson = lessons.firstWhere(
        (LessonEntry lesson) =>
            (((lesson.start.isBefore(now) && lesson.end.isAfter(now)) ||
                (lesson.end.isBefore(now) &&
                    lessons[lessons.indexOf(lesson) + 1].start.isAfter(now)))),
        orElse: null);

    globals.isCurrent = (globals.currentLesson.start.isBefore(now) &&
        globals.currentLesson.end.isAfter(now));

    quickLessons = [];

    for (LessonEntry lesson in lessons) {
      LessonCardTab lessonCardTab;
      int topMinutes;

      if (globals.isCurrent &&
          globals.currentLesson == lessons[lessons.indexOf(lesson)]) {
        topMinutes =
            lessons[lessons.indexOf(lesson)].end.difference(now).inMinutes;
        lessonCardTab = LessonCardTab.current;
      } else if (lessons.asMap().containsKey(lessons.indexOf(lesson) + 1) &&
          globals.currentLesson == lessons[lessons.indexOf(lesson) + 1]) {
        lessonCardTab = LessonCardTab.previous;
      } else if (lessons.asMap().containsKey(lessons.indexOf(lesson) - 1) &&
          globals.currentLesson == lessons[lessons.indexOf(lesson) - 1]) {
        topMinutes =
            lessons[lessons.indexOf(lesson)].start.difference(now).inMinutes;
        lessonCardTab = LessonCardTab.next;
      } else {
        lessonCardTab = LessonCardTab.normal;
      }

      quickLessons.add(LessonTile(
          context,
          lesson,
          (lessonCardTab == LessonCardTab.current)
              ? I18n.of(context).lessonCardNow((topMinutes + 1).toString())
              : (lessonCardTab == LessonCardTab.previous)
                  ? I18n.of(context).lessonCardPrevious
                  : (lessonCardTab == LessonCardTab.next)
                      ? I18n.of(context)
                          .lessonCardNext((topMinutes + 1).toString())
                      : null,
          (lesson.breakAfter == 0) ? "" : lesson.breakAfter.toString(),
          (lesson.count == -1) ? "+" : lesson.count.toString(),
          lesson.subject,
          lesson.isMissed
              ? Row(children: [
                  Icon(Icons.clear, color: Colors.red),
                  Text(capitalize(I18n.of(context).substitutionMissed))
                ])
              : lesson.isSubstitution
                  ? Row(children: [
                      Icon(Icons.compare_arrows, color: Colors.yellow),
                      Text(
                        lesson.depTeacher,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      )
                    ])
                  : Text(
                      lesson.teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
          (lesson.isSubstitution ? 1 : lesson.isMissed ? 2 : 0),
          (lesson.homework != null) ? true : false,
          getLessonRangeText(lesson),
          lesson.room));
    }

    return lessons;
  }

  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    List<Lesson> lessons;
    try {
      lessons =
          _lessonCardBackend(now, widget.lessons, widget.isLessonsTomorrow);
    } catch (_) {}

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
                      index: isInit
                          ? lessons.indexOf(globals.currentLesson)
                          : null,
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
    Widget lessonSubtitle,
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
                        (tabText != null)
                            ? Container(
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
                              )
                            : Container(height: 20),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (lessonState == 1)
                                  ? Colors.orange
                                  : (lessonState == 2)
                                      ? Colors.red
                                      : Theme.of(context)
                                          .textTheme
                                          .body1
                                          .color)),
                      subtitle: lessonSubtitle,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          hasHomework
                              ? Container(
                                  child: Icon(Icons.home),
                                  padding: EdgeInsets.all(5))
                              : Container(),
                          Container(
                            width: 85,
                            child: Column(
                              children: <Widget>[
                                Flexible(
                                    child: Text(room,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end)),
                                Text(startTime)
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
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
                      bottomRight: Radius.circular(6),
                      topLeft: Radius.circular(tabText != null ? 0 : 6)),
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
