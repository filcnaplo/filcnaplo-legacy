import 'dart:async';

import 'dart:convert' show utf8, json;

import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/helpers/database_helper.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';

Future<List<Lesson>> getLessonsOffline(
    DateTime from, DateTime to, User user) async {
  List<dynamic> ttMap;
  try {
    ttMap = await DBHelper().getTimetableMap(
        from.year.toString() +
            "-" +
            from.month.toString() +
            "-" +
            from.day.toString() +
            "_" +
            to.year.toString() +
            "-" +
            to.month.toString() +
            "-" +
            to.day.toString(),
        user);
  } catch (e) {
    print("[E] TimetableHelper.GetLessonsOffline() (1): " + e.toString());
  }

  List<Lesson> lessons = List();

  try {
    for (dynamic d in ttMap) lessons.add(Lesson.fromJson(d));
  } catch (e) {
    print("[E] TimetableHelper.GetLessonsOffline() (2): " + e.toString());
  }

  return lessons;
}

Future<String> getLessonsJson(
    DateTime from, DateTime to, User user, bool showErrors) async {
  String code = await RequestHelper().getBearerToken(user, showErrors);

  String timetableString = await RequestHelper().getTimeTable(
      from.toIso8601String().substring(0, 10),
      to.toIso8601String().substring(0, 10),
      code,
      user.schoolCode);

  return timetableString;
}

Future<List<Lesson>> getLessons(
    DateTime from, DateTime to, User user, bool showErrors) async {
  if (!user.getRecentlyRefreshed("getLessons" + fromToString(from, to))) {
  //  print(user.lastRefreshMap);
    String code = await RequestHelper().getBearerToken(user, showErrors);

    String timetableString = await RequestHelper().getTimeTable(
        from.toIso8601String().substring(0, 10),
        to.toIso8601String().substring(0, 10),
        code,
        user.schoolCode);
    
    List<dynamic> ttMap = json.decode(timetableString);

    await DBHelper().saveTimetableMap(fromToString(from, to), user, ttMap);

    List<Lesson> lessons = List();
    for (dynamic d in ttMap) {
      lessons.add(Lesson.fromJson(d));
    }

    user.setRecentlyRefreshed("getLessons" + fromToString(from, to));
    return lessons;
  }
  return getLessonsOffline(from, to, user);
}

String fromToString(DateTime from, DateTime to) {
  return from.year.toString() +
      "-" +
      from.month.toString() +
      "-" +
      from.day.toString() +
      "_" +
      to.year.toString() +
      "-" +
      to.month.toString() +
      "-" +
      to.day.toString();
}
