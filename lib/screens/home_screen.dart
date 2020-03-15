import 'dart:async';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:filcnaplo/cards/lesson_card.dart';
import 'package:filcnaplo/cards/tomorrow_lesson_card.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filcnaplo/cards/summary_card.dart';
import 'package:filcnaplo/cards/absence_card.dart';
import 'package:filcnaplo/cards/changed_lesson_card.dart';
import 'package:filcnaplo/cards/evaluation_card.dart';
import 'package:filcnaplo/cards/note_card.dart';
import 'package:filcnaplo/models/account.dart';
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/models/note.dart';
import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/global_drawer.dart';
import 'package:filcnaplo/helpers/background_helper.dart';
import 'package:filcnaplo/helpers/settings_helper.dart';
import 'package:filcnaplo/helpers/timetable_helper.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:filcnaplo/dialogs/choose_lesson_dialog.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List HomeScreenCards;
  List<Evaluation> evaluations = List();
  Map<String, List<Absence>> absents = Map();
  List<Note> notes = List();
  List<Lesson> lessons = List();
  DateTime get now => DateTime.now();
  DateTime startDate;
  bool hasOfflineLoaded = false;
  bool hasLoaded = true;
  List realLessons;
  bool isLessonsToday = false;
  bool isLessonsTomorrow = false;

  List<Lesson> lessonsToday;
  List<Lesson> lessonsTomorrow;

  void _initSettings() async {
    DynamicTheme.of(context).setBrightness(await SettingsHelper().getDarkTheme()
        ? Brightness.dark
        : Brightness.light);
    BackgroundHelper().configure();
    // refresh color settings
    globals.color1 = await SettingsHelper().getEvalColor(0);
    globals.color2 = await SettingsHelper().getEvalColor(1);
    globals.color3 = await SettingsHelper().getEvalColor(2);
    globals.color4 = await SettingsHelper().getEvalColor(3);
    globals.color5 = await SettingsHelper().getEvalColor(4);
    globals.colorF1 =
        globals.color1.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF2 =
        globals.color2.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF3 =
        globals.color3.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF4 =
        globals.color4.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
    globals.colorF5 =
        globals.color5.computeLuminance() >= 0.5 ? Colors.black : Colors.white;

    if (globals.users.length == 1) {
      globals.isSingle = true;
      SettingsHelper().setSingleUser(true);
    }
  }

  _launchDownloadWebsite() async {
    const url = 'https://www.filcnaplo.hu/download/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future showUpdateDialog() async {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              children: <Widget>[
                Text(I18n.of(context).downloadLatest + ":"),
                Text(
                  globals.latestVersion + "\n",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: _launchDownloadWebsite,
                      child: Text(capitalize(I18n.of(context).download)),
                    )
                  ],
                )
              ],
              title: Text(I18n.of(context).updateAvailable),
              contentPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                side: BorderSide(style: BorderStyle.none, width: 1),
                borderRadius: BorderRadius.circular(10),
              ));
        });
  }

  @override
  void initState() {
    _initSettings();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (globals.version != globals.latestVersion &&
          globals.latestVersion != "") showUpdateDialog();
    });

    _onRefresh(offline: true, showErrors: false).then((var a) async {
      HomeScreenCards = await feedItems();
    });
    if (globals.firstMain) {
      _onRefresh(offline: false, showErrors: false).then((var a) async {
        HomeScreenCards = await feedItems();
      });
      globals.firstMain = false;
    }
    startDate = now;
    Timer.periodic(
        Duration(seconds: 10),
        (Timer t) => () async {
              HomeScreenCards = await feedItems();
              setState(() {});
            });
  }

  Future<List<Widget>> feedItems() async {
    int maximumFeedLength = 50;
    List<Widget> feedCards = List();

    for (Account account in globals.accounts) {
      List<Evaluation> firstQuarterEvaluations = (evaluations.where(
          (Evaluation evaluation) => (evaluation.isFirstQuarter() &&
              evaluation.owner == account.user))).toList();
      List<Evaluation> halfYearEvaluations = (evaluations.where(
          (Evaluation evaluation) => (evaluation.isHalfYear() &&
              evaluation.owner == account.user))).toList();
      List<Evaluation> thirdQuarterEvaluations = (evaluations.where(
          (Evaluation evaluation) => (evaluation.isThirdQuarter() &&
              evaluation.owner == account.user))).toList();
      List<Evaluation> endYearEvaluations = (evaluations.where(
              (Evaluation evaluation) =>
                  (evaluation.isEndYear() && evaluation.owner == account.user)))
          .toList();

      if (firstQuarterEvaluations.isNotEmpty)
        feedCards.add(SummaryCard(firstQuarterEvaluations, context, 1, false,
            true, !globals.isSingle));
      if (halfYearEvaluations.isNotEmpty)
        feedCards.add(SummaryCard(
            halfYearEvaluations, context, 2, false, true, !globals.isSingle));
      if (thirdQuarterEvaluations.isNotEmpty)
        feedCards.add(SummaryCard(thirdQuarterEvaluations, context, 3, false,
            true, !globals.isSingle));
      if (endYearEvaluations.isNotEmpty)
        feedCards.add(SummaryCard(
            endYearEvaluations, context, 4, false, true, !globals.isSingle));
    }

    for (String day in absents.keys.toList())
      feedCards.add(AbsenceCard(absents[day], globals.isSingle, context));
    for (Evaluation evaluation in evaluations.where((Evaluation evaluation) =>
        !evaluation.isSummaryEvaluation())) //Only add non-summary evals
      feedCards.add(EvaluationCard(
          evaluation, globals.isColor, globals.isSingle, context));
    for (Note note in notes)
      feedCards.add(NoteCard(note, globals.isSingle, context));
    for (Lesson l in lessons.where((Lesson lesson) =>
        (lesson.isMissed || lesson.isSubstitution) && lesson.date.isAfter(now)))
      feedCards.add(ChangedLessonCard(l, context));

    //realLessons = lessons.where((Lesson l) => !l.isMissed).toList();
    lessonsToday = lessons
        .where((Lesson lesson) => (lesson.start.day == now.day))
        .toList();
    lessonsTomorrow = lessons
        .where((Lesson lesson) =>
            (lesson.start.day == now.add(Duration(days: 1)).day))
        .toList();

    try {
      if (lessonsToday.length > 0 && lessonsToday.last.end.isAfter(now)) {
        isLessonsToday = true;
        isLessonsTomorrow = false;
      } else if (lessonsTomorrow.first.start.day ==
          now.add(Duration(days: 1)).day) {
        isLessonsToday = false;
        isLessonsTomorrow = true;
      } else {
        isLessonsToday = false;
        isLessonsTomorrow = false;
      }

      if (isLessonsToday) feedCards.add(LessonCard(lessonsToday, context));
      if (isLessonsTomorrow)
        feedCards.add(TomorrowLessonCard(lessonsTomorrow, context, now));
    } catch (e) {
      print("[E] HomeScreen.feedItems() (1): " + e.toString());
    }

    try {
      feedCards.sort((Widget a, Widget b) {
        return b.key.toString().compareTo(a.key.toString());
      });
    } catch (e) {
      print("[E] HomeScreen.feedItems() (2): " + e.toString());
    }

    if (maximumFeedLength > feedCards.length)
      maximumFeedLength = feedCards.length;
    return feedCards.sublist(0, maximumFeedLength);
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(I18n.of(context).closeTitle),
          content: Text(I18n.of(context).closeConfirm),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(I18n.of(context).dialogNo.toUpperCase()),
            ),
            FlatButton(
              onPressed: () async {
                await SystemChannels.platform
                    .invokeMethod<void>('SystemNavigator.pop');
              },
              child: Text(I18n.of(context).dialogYes.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _addHomeworkToThisSubject() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return ChooseLessonDialog(
              0, globals.currentLesson.subject, globals.currentLesson.teacher);
        });
  }

  Widget _unicornOption({IconData iconData, String hero, Function onPressed}) {
    return UnicornButton(
        currentButton: FloatingActionButton(
      heroTag: hero,
      mini: true,
      child: Icon(iconData),
      onPressed: onPressed,
    ));
  }

  List<UnicornButton> _getUnicornMenu() {
    List<UnicornButton> children = [];

    if (globals.currentLesson != null) {
      children.add(_unicornOption(
          iconData: Icons.home,
          hero: I18n.of(context).homeworkAdd,
          onPressed: _addHomeworkToThisSubject));
    }

    children.add(_unicornOption(
        iconData: IconData(0xf520, fontFamily: "Material Design Icons"),
        hero: I18n.of(context).drawerTimetable,
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/timetable");
        }));

    return children;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          drawer: GlobalDrawer(),
          appBar: AppBar(
            title: Text(globals.isSingle
                ? globals.selectedAccount.user.name
                : I18n.of(context).appTitle),
          ),
          body: hasOfflineLoaded &&
                  globals.isColor != null &&
                  HomeScreenCards != null
              ? Container(
                  child: Column(children: <Widget>[
                  !hasLoaded
                      ? Container(
                          child: LinearProgressIndicator(
                            value: null,
                          ),
                          height: 3,
                        )
                      : Container(
                          height: 3,
                        ),
                  Expanded(
                    child: RefreshIndicator(
                      child: ListView(
                        children: HomeScreenCards,
                      ),
                      onRefresh: () {
                        Completer<Null> completer = Completer<Null>();
                        _onRefresh().then((bool b) async {
                          HomeScreenCards = await feedItems();
                          setState(() {
                            completer.complete();
                          });
                        });
                        return completer.future;
                      },
                    ),
                  ),
                ]))
              : Center(child: CircularProgressIndicator()),
          floatingActionButton: UnicornDialer(
            parentButton: Icon(Icons.menu),
            childButtons: _getUnicornMenu(),
          ),
        ));
  }

  Future<Null> _onRefresh(
      {bool offline = false, bool showErrors = true}) async {
    List<Evaluation> tempEvaluations = List();
    Map<String, List<Absence>> tempAbsents = Map();
    List<Note> tempNotes = List();
    setState(() {
      if (offline)
        hasOfflineLoaded = false;
      else
        hasLoaded = false;
    });
    if (globals.isSingle) {
      try {
        await globals.selectedAccount.refreshStudentString(offline, showErrors);
        tempEvaluations.addAll(globals.selectedAccount.student.Evaluations);
        tempNotes.addAll(globals.selectedAccount.notes);
        tempAbsents.addAll(globals.selectedAccount.absents);
      } catch (exception) {
        print("[E] HomeScreen.onRefresh() (1): " + exception.toString());
      }
    } else {
      for (Account account in globals.accounts) {
        try {
          try {
            await account.refreshStudentString(offline, showErrors);
          } catch (e) {
            print("[E] HomeScreen.onRefresh() (2): " + e.toString());
          }
          tempEvaluations.addAll(account.student.Evaluations);
          tempNotes.addAll(account.notes);
          tempAbsents.addAll(account.absents);
        } catch (exception) {
          print("[E] HomeScreen.onRefresh() (3): " + exception.toString());
        }
      }
    }

    if (tempEvaluations.length > 0) evaluations = tempEvaluations;
    if (tempAbsents.length > 0) absents = tempAbsents;
    if (tempNotes.length > 0) notes = tempNotes;
    startDate = now;

    if (offline) {
      if (globals.lessons.length > 0) {
        lessons.addAll(globals.lessons);
      } else {
        try {
          lessons = await getLessonsOffline(startDate,
              startDate.add(Duration(days: 6)), globals.selectedUser);
        } catch (exception) {
          print("[E] HomeScreen.onRefresh() (4): " + exception.toString());
        }
        if (lessons.length > 0) globals.lessons.addAll(lessons);
      }
    } else {
      try {
        lessons = await getLessons(startDate, startDate.add(Duration(days: 6)),
            globals.selectedUser, showErrors);
      } catch (exception) {
        print("[E] HomeScreen.onRefresh() (5): " + exception.toString());
      }
    }
    try {
      lessons.sort((Lesson a, Lesson b) => a.start.compareTo(b.start));
      if (lessons.length > 0) globals.lessons = lessons;
    } catch (e) {
      print("[E] HomeScreen.onRefresh() (6): " + e.toString());
    }
    Completer<Null> completer = Completer<Null>();
    if (!offline) hasLoaded = true;
    hasOfflineLoaded = true;
    if (mounted) {
      setState(() {
        completer.complete();
      });
    }
    return completer.future;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
