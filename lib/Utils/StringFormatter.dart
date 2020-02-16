import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/generated/i18n.dart';

String getTimetableText(DateTime startDateText) {
  return ((" (" +
      startDateText.month.toString() +
      ". " +
      startDateText.day.toString() +
      ". - " +
      startDateText
          .add(new Duration(days: 6))
          .month
          .toString() +
      ". " +
      startDateText
          .add(new Duration(days: 6))
          .day
          .toString() +
      ".)") ??
      "");
}

String getLessonRangeText(Lesson lesson) {
  return getLessonStartText(lesson) + "-" + getLessonEndText(lesson);
}

String getLessonStartText(Lesson lesson) {
  return lesson.start.hour.toString().padLeft(2, "0") +
      ":" +
      lesson.start.minute.toString().padLeft(2, "0");
}

String getLessonEndText(Lesson lesson) {
  return lesson.end.hour.toString().padLeft(2, "0") +
      ":" +
      lesson.end.minute.toString().padLeft(2, "0");
}

String dateToHuman(DateTime date) {
  return date
      .toIso8601String()
      .substring(0, 11)
      .replaceAll("-", '. ')
      .replaceAll("T", ". ");
}

String lessonToHuman(Lesson lesson) {
  return lesson.date
      .toIso8601String()
      .substring(0, 11)
      .replaceAll("-", '. ')
      .replaceAll("T", ". ");
}

String dateToWeekDay(DateTime date, BuildContext context) {
  switch (date.weekday) {
    case DateTime.monday:
      return I18n.of(context).dateMonday;
    case DateTime.tuesday:
      return I18n.of(context).dateTuesday;
    case DateTime.wednesday:
      return I18n.of(context).dateWednesday;
    case DateTime.thursday:
      return I18n.of(context).dateThursday;
    case DateTime.friday:
      return I18n.of(context).dateFriday;
    case DateTime.saturday:
      return I18n.of(context).dateSaturday;
    case DateTime.sunday:
      return I18n.of(context).dateSunday;
  }
  return "";
}


String capitalize(String s) => s[0].toUpperCase() + s.substring(1);