import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:filcnaplo/helpers/absent_helper.dart';
import 'package:filcnaplo/helpers/average_helper.dart';
import 'package:filcnaplo/helpers/database_helper.dart';
import 'package:filcnaplo/helpers/message_helper.dart';
import 'package:filcnaplo/helpers/notes_helper.dart';
import 'package:filcnaplo/helpers/request_helper.dart';
import 'package:filcnaplo/helpers/test_helper.dart';
import 'package:filcnaplo/utils/saver.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/models/average.dart';
import 'package:filcnaplo/models/message.dart';
import 'package:filcnaplo/models/note.dart';
import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/models/test.dart';
import 'package:filcnaplo/models/user.dart';
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

  Future<void> refreshStudentString(bool isOffline, bool showErrors, {bool userInit = false, BuildContext context}) async {
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
    } else if (userInit) {
      Fluttertoast.showToast(
              msg: I18n.of(context).rateLimitAlert(globals.rateLimitMinutes.toString()),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
              toastLength: Toast.LENGTH_LONG);
    }
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
  }

  List<Evaluation> get midyearEvaluations => student.Evaluations.where(
      (Evaluation evaluation) => evaluation.isMidYear()).toList();
}
