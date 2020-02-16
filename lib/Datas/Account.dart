import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:filcnaplo/Helpers/AbsentHelper.dart';
import 'package:filcnaplo/Helpers/AverageHelper.dart';
import 'package:filcnaplo/Helpers/DBHelper.dart';
import 'package:filcnaplo/Helpers/MessageHelper.dart';
import 'package:filcnaplo/Helpers/NotesHelper.dart';
import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/Helpers/TestHelper.dart';
import 'package:filcnaplo/Utils/Saver.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'Average.dart';
import 'Message.dart';
import 'Note.dart';
import 'Student.dart';
import 'Test.dart';
import 'User.dart';
import 'package:filcnaplo/globals.dart' as globals;

class Account {
  Student student;
  User user;

  String _eventsString;
  String testString;

  Map _studentJson;
  Map<String, List<Absence>> absents;

  List<Test> tests;
  List testJson;
  List<Note> notes;
  List<Average> averages;
  List<Message> messages;

  //TODO add a Bearer token here

  Account(User user) {
    this.user = user;
  }

  String getStudentString() => json.encode(_studentJson);

  Map getStudentJson() => _studentJson;

  Future<void> refreshStudentString(bool isOffline, bool showErrors) async {
    if (!user.getRecentlyRefreshed("refreshStudentString")) {
      if (isOffline && _studentJson == null) {
        try {
          _studentJson = await DBHelper().getStudentJson(user);
        } catch (e) {
          Fluttertoast.showToast(
              msg: I18n.of(globals.context).errorReadAccount,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        messages = await MessageHelper().getMessagesOffline(user);
      } else if (!isOffline) {
        String studentString =
            await RequestHelper().getStudentString(user, showErrors);
        if (studentString != null) {
          _studentJson = json.decode(studentString);
          await DBHelper().addStudentJson(_studentJson, user);
        }
        messages = await MessageHelper().getMessages(user, showErrors);
      }

      student = Student.fromMap(_studentJson, user);
      absents = await AbsentHelper().getAbsentsFrom(student.Absences);
      await _refreshEventsString(isOffline, showErrors);
      notes = await NotesHelper()
          .getNotesFrom(_eventsString, json.encode(_studentJson), user);
      averages = await AverageHelper()
          .getAveragesFrom(json.encode(_studentJson), user);

      user.setRecentlyRefreshed("refreshStudentString");
    }
    /*else {
      Fluttertoast.showToast(
        msg: I18n.of(context).refreshLimit(User.RATE_LIMIT_MINUTES.toString()));
    } */
  }

  Future<void> refreshTests(bool isOffline, bool showErrors) async {
    BuildContext context;
    if (!user.getRecentlyRefreshed("refreshTests")) {
      if (isOffline) {
        testJson = await DBHelper().getTestsJson(user);
        tests = await TestHelper().getTestsFrom(testJson, user);
      } else {
        testString = await RequestHelper().getTests(
            await RequestHelper().getBearerToken(user, showErrors),
            user.schoolCode);
        testJson = json.decode(testString);
        tests = await TestHelper().getTestsFrom(testJson, user);
        DBHelper().addTestsJson(testJson, user);
      }
      user.setRecentlyRefreshed("refreshTests");
    }
    /*else {
      Fluttertoast.showToast(
        msg: I18n.of(context).refreshLimit(User.RATE_LIMIT_MINUTES.toString()));
    } */
  }

  Future<void> _refreshEventsString(bool isOffline, bool showErrors) async {
    BuildContext context;
    if (!user.getRecentlyRefreshed("_refreshEventsString")) {
      if (isOffline)
        _eventsString = await readEventsString(user);
      else
        _eventsString = await RequestHelper().getEventsString(user, showErrors);
      user.setRecentlyRefreshed("_refreshEventsString");
    }
    /*else {
      Fluttertoast.showToast(
        msg: I18n.of(context).refreshLimit(User.RATE_LIMIT_MINUTES.toString()));
    } */
  }

  List<Evaluation> get midyearEvaluations => student.Evaluations.where(
      (Evaluation evaluation) => evaluation.isMidYear()).toList();
}
