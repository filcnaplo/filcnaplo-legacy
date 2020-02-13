import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/generated/i18n.dart';

class Week {
  List<Lesson> monday;
  List<Lesson> tuesday;
  List<Lesson> wednesday;
  List<Lesson> thursday;
  List<Lesson> friday;
  List<Lesson> saturday;
  List<Lesson> sunday;
  DateTime startDay;

  List<List<Lesson>> dayList() {
    List<List<Lesson>> days = new List();
    if (monday.isNotEmpty) days.add(monday);
    if (tuesday.isNotEmpty) days.add(tuesday);
    if (wednesday.isNotEmpty) days.add(wednesday);
    if (thursday.isNotEmpty) days.add(thursday);
    if (friday.isNotEmpty) days.add(friday);
    if (saturday.isNotEmpty) days.add(saturday);
    if (sunday.isNotEmpty) days.add(sunday);
    return days;
  }

  List<String> dayStrings(BuildContext context) {
    List<String> days = new List();
    if (monday.isNotEmpty) days.add(I18n.of(context).dateMondayShort);
    if (tuesday.isNotEmpty) days.add(I18n.of(context).dateTuesdayShort);
    if (wednesday.isNotEmpty) days.add(I18n.of(context).dateWednesdayShort);
    if (thursday.isNotEmpty) days.add(I18n.of(context).dateThursdayShort);
    if (friday.isNotEmpty) days.add(I18n.of(context).dateFridayShort);
    if (saturday.isNotEmpty) days.add(I18n.of(context).dateSaturdayShort);
    if (sunday.isNotEmpty) days.add(I18n.of(context).dateSundayShort);
    return days;
  }

  Week(this.monday, this.tuesday, this.wednesday, this.thursday, this.friday,
      this.saturday, this.sunday, this.startDay);
}
