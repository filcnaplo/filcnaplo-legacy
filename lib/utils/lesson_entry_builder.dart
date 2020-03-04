import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/models/lesson_entry.dart';
import 'dart:async';

List<LessonEntry> lessonEntryBuilder(List<Lesson> lessons) {
  List<LessonEntry> lessonEntries = [];

  for (Lesson lesson in lessons) {
    int i = lessons.indexOf(lesson);

    int breakBefore;
    try {
      breakBefore = lessons[i].start.difference(lessons[i - 1].end).inMinutes;
    } catch (e) {
      breakBefore = 0;
    }

    int breakAfter;
    try {
      breakAfter = lessons[i + 1].start.difference(lessons[i].end).inMinutes;
    } catch (e) {
      breakAfter = 0;
    }

    lessonEntries.add(new LessonEntry(
        lesson.id,
        lesson.count,
        lesson.date,
        lesson.start,
        lesson.end,
        lesson.subject,
        lesson.subjectName,
        lesson.room,
        lesson.group,
        lesson.teacher,
        lesson.depTeacher,
        lesson.state,
        lesson.stateName,
        lesson.presence,
        lesson.presenceName,
        lesson.theme,
        lesson.homework,
        lesson.calendarOraType,
        lesson.homeworkEnabled,
        breakAfter,
        breakBefore));
  }

  return lessonEntries;
}
