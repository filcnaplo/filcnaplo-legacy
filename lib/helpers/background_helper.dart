import 'dart:async';
import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/models/note.dart';
import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/helpers/database_helper.dart';
import 'package:filcnaplo/helpers/settings_helper.dart';
import 'package:filcnaplo/helpers/timetable_helper.dart';
import 'package:filcnaplo/helpers/encrypt_codec.dart';
import 'package:filcnaplo/utils/account_manager.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'settings_helper.dart';

class BackgroundHelper {
  Future<bool> get canSyncOnData async =>
      await SettingsHelper().getCanSyncOnData();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void doEvaluations(
      List<Evaluation> offlineEvals, List<Evaluation> evals) async {
    for (Evaluation e in evals) {
      bool exist = false;
      for (Evaluation o in offlineEvals)
        if (e.trueID() == o.trueID()) exist = true;
      if (!exist) {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'evaluations',
          'jegyek',
          'értesítések a jegyekről',
          importance: Importance.Max,
          priority: Priority.High,
          color: Colors.grey,
        );
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin.show(
            e.trueID(),
            e.Subject +
                " - " +
                (e.NumberValue != 0 ? e.NumberValue.toString() : e.Value),
            e.owner.name + ", " + (e.Theme ?? ""),
            platformChannelSpecifics,
            payload: e.trueID().toString());
      }

      //TODO jegyek változása
      //TODO új házik
      //TODO ha óra elmarad/helyettesítés
    }
  }

  void doNotes(List<Note> offlineNotes, List<Note> notes) async {
    for (Note n in notes) {
      if (!offlineNotes.map((Note note) => note.id).contains(n.id)) {
        //print(offlineNotes.map((Note note) => note.id).toList());
        //print(n.id);
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'notes', 'feljegyzések', 'értesítések a feljegyzésekről',
            importance: Importance.Max,
            priority: Priority.High,
            color: Colors.blue);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        flutterLocalNotificationsPlugin.show(
            n.id, n.title + " - " + n.type, n.content, platformChannelSpecifics,
            payload: n.id.toString());
      }
    }
  }

  void doAbsences(Map<String, List<Absence>> offlineAbsences,
      Map<String, List<Absence>> absences) async {
    if (absences != null)
      absences.forEach((String date, List<Absence> absenceList) {
        for (Absence absence in absenceList) {
          bool exist = false;
          offlineAbsences
              .forEach((String dateOffline, List<Absence> absenceList2) {
            for (Absence offlineAbsence in absenceList2)
              if (absence.AbsenceId == offlineAbsence.AbsenceId) exist = true;
          });
          if (!exist) {
            var androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'absences',
              'mulasztások',
              'értesítések a hiányzásokról',
              importance: Importance.Max,
              priority: Priority.High,
              color: Colors.blue,
              groupKey: absenceList.first.owner.id.toString() + absence.Type,
            );
            var iOSPlatformChannelSpecifics = IOSNotificationDetails();
            var platformChannelSpecifics = NotificationDetails(
                androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            flutterLocalNotificationsPlugin.show(
              absence.AbsenceId,
              absence.Subject + " " + absence.TypeName,
              absence.owner.name +
                  (absence.DelayTimeMinutes != 0
                      ? (", " +
                          absence.DelayTimeMinutes.toString() +
                          " perc késés")
                      : ""),
              platformChannelSpecifics,
              payload: absence.AbsenceId.toString(),
            );
          }
        }
      });
  }

  void cancelNextLesson() async {
    DateTime startDate = DateTime.now();
    startDate = startDate.add(Duration(days: (-1 * startDate.weekday + 1)));

    List<Lesson> lessons = await getLessonsOffline(startDate,
        startDate.add(Duration(days: 7)), globals.selectedAccount.user);

    bool nextLesson = await SettingsHelper().getNextLesson();
    if (nextLesson)
      for (Lesson lesson in lessons) {
        if (lesson.end.isAfter(DateTime.now()) &&
            lesson.id != lessons.last.id) {
          int index = lessons.indexOf(lesson);
          if (lessons[index].date == lessons[index + 1].date) {
            await flutterLocalNotificationsPlugin.cancel(
                lesson.end.weekday * 24 * 3600 +
                    lesson.end.hour * 3600 +
                    lesson.end.minute * 60 +
                    lesson.end.second);
          }
        }
      }
  }

  void doLessons(Account account) async {
    try {
      DateTime startDate = DateTime.now();
      startDate = startDate.add(Duration(days: (-1 * startDate.weekday + 1)));

      List<Lesson> lessonsOffline = await getLessonsOffline(
          startDate, startDate.add(Duration(days: 7)), account.user);
      List<Lesson> lessons = await getLessons(
          startDate, startDate.add(Duration(days: 7)), account.user, false);

      bool nextLesson = await SettingsHelper().getNextLesson();
      if (nextLesson) if (account.user.id == globals.accounts[0].user.id)
        for (Lesson lesson in lessons) {
          bool exist = false;
          // Értesítés a következő óráról WIP
          //print("1");
          //print(lesson.end);
          if (lesson.end.isAfter(DateTime.now()) &&
              lesson.id != lessons.last.id) {
            //print("2");
            int index = lessons.indexOf(lesson);
            //print("index: " + index.toString());
            if (lessons[index].date == lessons[index + 1].date) {
              // print("3");
              //print(lesson.end.toIso8601String());
              //print(lessons[index + 1].subject);
              var scheduledNotificationDateTime = lesson.end;
              var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  'next-lesson',
                  'Következő óra',
                  'Értesítés a következő óráról',
                  playSound: false,
                  enableVibration: false,
                  color: Colors.blue);
              var iOSPlatformChannelSpecifics = IOSNotificationDetails();
              NotificationDetails platformChannelSpecifics =
                  NotificationDetails(androidPlatformChannelSpecifics,
                      iOSPlatformChannelSpecifics);
              await flutterLocalNotificationsPlugin.schedule(
                  lesson.end.weekday * 24 * 3600 +
                      lesson.end.hour * 3600 +
                      lesson.end.minute * 60 +
                      lesson.end.second,
                  lessons[index + 1].subject +
                      " " +
                      ((lessons[index + 1].start.hour == lesson.end.hour)
                          ? ""
                          : (lessons[index + 1].start.hour - lesson.end.hour)
                                  .toString() +
                              " óra és ") +
                      (lessons[index + 1].start.minute - lesson.end.minute)
                          .toString() +
                      " perc múlva",
                  "Terem: " + lessons[index + 1].room,
                  scheduledNotificationDateTime,
                  platformChannelSpecifics,
                  androidAllowWhileIdle: true);
            }
          }

          for (Lesson offlineLesson in lessonsOffline) {
            exist = (lesson.id == offlineLesson.id &&
                ((lesson.isMissed && !offlineLesson.isMissed) ||
                    (lesson.isSubstitution && !offlineLesson.isSubstitution)));
          }
          if (exist) {
            var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                'lessons',
                'órák',
                'értesítések elmaradt/helyettesített órákról',
                importance: Importance.Max,
                priority: Priority.High,
                style: AndroidNotificationStyle.BigText,
                color: Colors.blue);
            var iOSPlatformChannelSpecifics = IOSNotificationDetails();
            var platformChannelSpecifics = NotificationDetails(
                androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            flutterLocalNotificationsPlugin.show(
                lesson.id,
                lesson.subject +
                    " " +
                    lesson.date.toIso8601String().substring(0, 10),
                lesson.stateName + " " + lesson.depTeacher,
                platformChannelSpecifics,
                payload: lesson.id.toString());
          }
        }
    } catch (e) {
      print("[e] BackgroundHelper.doLessons(): " + e.toString());
    }
  }

  void doBackground() async {
    print("[i] BackgroundHelper.doBackground() called");
    final storage = FlutterSecureStorage();
    String value = await storage.read(key: "db_key");
    if (value == null) {
      int randomNumber = Random.secure().nextInt(4294967296);
      await storage.write(key: "db_key", value: randomNumber.toString());
      value = await storage.read(key: "db_key");
    }

    var codec = getEncryptSembastCodec(password: value);

    globals.db = await globals.dbFactory.openDatabase(
        (await DBHelper().localFolder) + DBHelper().dbPath,
        codec: codec);

    List accounts = List();
    for (User user in await AccountManager().getUsers())
      accounts.add(Account(user));
    for (Account account in accounts) {
      try {
        //offfine check
        await account.refreshStudentString(true, false);
        List<Evaluation> offlineEvals = account.student.Evaluations;
        List<Note> offlineNotes = account.notes;
        Map<String, List<Absence>> offlineAbsences = account.absents;

        //online check
        await account.refreshStudentString(false, false);
        List<Evaluation> evals = account.student.Evaluations;
        List<Note> notes = account.notes;
        Map<String, List<Absence>> absences = account.absents;

        doEvaluations(offlineEvals, evals);
        doNotes(offlineNotes, notes);
        doAbsences(offlineAbsences, absences);
        doLessons(account);
      } catch (e) {
        print("[E] BackgroundHelper.doBackground(): " + e.toString());
      }
    }
  }

  Future<int> backgroundTask() async {
    print("[i] BackgroundHelper.backgroundTask() called");
    await Connectivity()
        .checkConnectivity()
        .then((ConnectivityResult result) async {
      try {
        if (result == ConnectivityResult.mobile && await canSyncOnData ||
            result == ConnectivityResult.wifi) doBackground();
      } catch (e) {
        print("[E] BackgroundHelper.backgroundTask(): " + e.toString());
      }
    });

    return 0;
  }

  void backgroundFetchHeadlessTask(String taskId) async {
    print("[i] BackgroundHelper.backgroundFetchHeadlessTask() called");
    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('notification_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      await backgroundTask();
      BackgroundFetch.finish(taskId);
    } catch (e) {
      print("[e] BackgroundHelper.backgroundFetchHeadlessTask(): " +
          e.toString());
    }
  }

  Future<void> configure() async {
    print("[i] BackgroundHelper.configure() called");
    if (await SettingsHelper().getNotification()) {
      await SettingsHelper()
          .getRefreshNotification()
          .then((int _refreshNotification) {
        BackgroundFetch.configure(
            BackgroundFetchConfig(
                minimumFetchInterval: _refreshNotification,
                stopOnTerminate: false,
                enableHeadless: true,
                startOnBoot: true), (String taskId) {
          print('[BackgroundFetch] Event received.');
          BackgroundFetch.finish(taskId);
        });
      });
    }
  }
}
