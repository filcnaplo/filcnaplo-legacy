import 'package:filcnaplo/models/lesson.dart';

class LessonEntry extends Lesson {
  int breakBefore;
  int breakAfter;

  LessonEntry(
      int id,
      int count,
      DateTime date,
      DateTime start,
      DateTime end,
      String subject,
      String subjectName,
      String room,
      String group,
      String teacher,
      String depTeacher,
      String state,
      String stateName,
      String presence,
      String presenceName,
      String theme,
      int homework,
      String calendarOraType,
      bool homeworkEnabled,
      this.breakAfter,
      this.breakBefore)
      : super(
            id,
            count,
            date,
            start,
            end,
            subject,
            subjectName,
            room,
            group,
            teacher,
            depTeacher,
            state,
            stateName,
            presence,
            presenceName,
            theme,
            homework,
            calendarOraType,
            homeworkEnabled);
}
