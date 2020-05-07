import 'dart:convert' show json;
import 'dart:ui';
import 'dart:ui' as dart_ui;

import 'package:charts_flutter/flutter.dart';
import 'package:filcnaplo/cards/summary_card.dart';
import 'package:filcnaplo/utils/select_fab.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:filcnaplo/global_drawer.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/models/average.dart';
import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/utils/color_manager.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(home: EvaluationsScreen()));
}

class EvalCount extends StatelessWidget {
  BuildContext context;
  int value;
  int count;
  EvalCount(BuildContext context, int value, int count) {
    this.context = context;
    this.value = value;
    this.count = count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
          child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text(value.toString(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: getColors(context, value, false),
                        )),
                    alignment: Alignment(0, 0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: getColors(context, value, true),
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                  ),
                  Row(
                    children: <Widget>[
                      Text(count.toString() ?? "0",
                          style: TextStyle(fontSize: 20)),
                      Text(" " + I18n.of(context).pcs)
                    ],
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              padding: EdgeInsets.all(10),
              color: globals.isDark ? Colors.black54 : Colors.white70),
          color: getColors(context, value, true)),
      height: 70,
    );
  }
}

class EvaluationsScreen extends StatefulWidget {
  @override
  EvaluationsScreenState createState() => EvaluationsScreenState();
}

//TODO refactor this file
List<Average> averages = List();
List<TimeAverage> timeData = List();
var series;

class EvaluationsScreenState extends State<EvaluationsScreen> {
  Average selectedAverage;
  final List<Series<TimeAverage, DateTime>> seriesList = List();
  List<Evaluation> evals = List();
  List<Evaluation> toSummaryEvals = List();
  List<Evaluation> allEvals = List();
  String avrString = "";
  String classAvrString = "";
  int db1 = 0;
  int db2 = 0;
  int db3 = 0;
  int db4 = 0;
  int db5 = 0;
  double allAverage = 0.0;
  List<Widget> summaryCardsToShow = List();

  bool hasOfflineLoaded = false;
  bool hasLoaded = true;

  User selectedUser;

  Color color = MaterialPalette.blue.shadeDefault;

  @override
  void initState() {
    switch (globals.themeID) {
      case 0:
        color = MaterialPalette.blue.shadeDefault;
        break;
      case 1:
        color = MaterialPalette.red.shadeDefault;
        break;
      case 2:
        color = MaterialPalette.green.shadeDefault;
        break;
      case 3:
        color = MaterialPalette.green.shadeDefault;
        break;
      case 4:
        color = MaterialPalette.yellow.shadeDefault;
        break;
      case 5:
        color = MaterialPalette.deepOrange.shadeDefault;
        break;
      case 6:
        color = MaterialPalette.gray.shadeDefault;
        break;
      case 7:
        color = MaterialPalette.pink.shadeDefault;
        break;
      case 8:
        color = MaterialPalette.purple.shadeDefault;
        break;
      case 9:
        color = MaterialPalette.teal.shadeDefault;
        break;
    }

    setState(() {
      _initStats();
      _initAllEvals();
    });
    super.initState();
  }

  dart_ui.Color getColorForAverageString(String averageString) {
    double average = 0;
    try {
      average = double.parse(avrString);
    } catch (e) {
      print(
          "[E] evaluationsScreen.getColorForAvarageString(): " + e.toString());
    }

    return getColorForAverage(average);
  }

  dart_ui.Color getColorForAverage(double average) {
    switch (average.round()) {
      case 1:
        return globals.color1;
      case 2:
        return globals.color2;
      case 3:
        return globals.color3;
      case 4:
        return globals.color4;
      case 5:
        return globals.color5;
      default:
        return globals.isDark ? Colors.white : Colors.black;
    }
  }

  void initEvals() async {
    await globals.selectedAccount.refreshStudentString(true, false);

    toSummaryEvals.addAll(globals.selectedAccount.student.Evaluations);

    evals.addAll(globals.selectedAccount.student.Evaluations);
    evals.removeWhere((Evaluation evaluation) =>
        evaluation.NumberValue == 0 ||
        evaluation.Mode == "Na" ||
        evaluation.Weight == null ||
        evaluation.Weight == "-" ||
        evaluation.isSummaryEvaluation());

    for (Evaluation e in evals)
      switch (e.NumberValue) {
        case 1:
          db1++;
          break;
        case 2:
          db2++;
          break;
        case 3:
          db3++;
          break;
        case 4:
          db4++;
          break;
        case 5:
          db5++;
          break;
      }
    allAverage = getAllAverages() ?? 0.0;

    refreshSort();

    List<Evaluation> firstQuarterEvaluations = (toSummaryEvals
        .where((Evaluation evaluation) => (evaluation.isFirstQuarter()))
        .toList());
    List<Evaluation> halfYearEvaluations = (toSummaryEvals
        .where((Evaluation evaluation) => (evaluation.isHalfYear()))
        .toList());
    List<Evaluation> thirdQuarterEvaluations = (toSummaryEvals
        .where((Evaluation evaluation) => (evaluation.isThirdQuarter()))
        .toList());
    List<Evaluation> endYearEvaluations = (toSummaryEvals
        .where((Evaluation evaluation) => (evaluation.isEndYear()))
        .toList());

    if (endYearEvaluations.isNotEmpty)
      summaryCardsToShow
          .add(SummaryCard(endYearEvaluations, context, 4, false, true, false));
    if (thirdQuarterEvaluations.isNotEmpty)
      summaryCardsToShow.add(
          SummaryCard(thirdQuarterEvaluations, context, 3, false, true, false));
    if (halfYearEvaluations.isNotEmpty)
      summaryCardsToShow.add(
          SummaryCard(halfYearEvaluations, context, 2, false, true, false));
    if (firstQuarterEvaluations.isNotEmpty)
      summaryCardsToShow.add(SummaryCard(firstQuarterEvaluations, context, 1,
          false, true, false)); //localization

    if (summaryCardsToShow.isEmpty)
      summaryCardsToShow.add(Card(
          child: Container(
              padding: EdgeInsets.all(5),
              child: Text(I18n.of(context).evaluationSummaryPlaceholder))));
  }

  double getAllAverages() {
    double sum = 0;
    double n = 0;
    for (Evaluation e in evals) {
      if (e.NumberValue != 0) {
        double multiplier = 1;
        try {
          multiplier = double.parse(e.Weight.replaceAll("%", "")) / 100;
        } catch (e) {
          print("[E] evaluationsScreen.getAllAverages(): " + e.toString());
        }
        sum += e.NumberValue * multiplier;
        n += multiplier;
      }
    }
    if (n > 0) return sum / n;

    return 0;
  }

  double getAverage(List<Evaluation> evaluations) {
    double db = 0;
    double sum = 0;
    for (Evaluation evaluation in evaluations) {
      if (evaluation.IsAtlagbaBeleszamit && evaluation.NumberValue != 0) {
        double multiplier = 1;
        try {
          multiplier =
              double.parse(evaluation.Weight.replaceAll("%", "")) / 100;
        } catch (e) {
          print("[E] evaluationsScreen.getAverage(): " + e.toString());
        }
        sum += evaluation.NumberValue * multiplier;
        db += multiplier;
      }
    }
    if (db > 0) return sum / db;

    return 0;
  }

  void _initStats() async {
    await globals.selectedAccount.refreshStudentString(true, false);
    setState(() {
      averages = globals.selectedAccount.averages ?? List();
      averages.removeWhere((Average average) => average.value < 1);
      if (averages == null || averages.isEmpty) {
        Map<String, List<Evaluation>> evaluationsBySubject = Map();
        for (Evaluation evaluation
            in globals.selectedAccount.midyearEvaluations) {
          if (evaluationsBySubject[evaluation.Subject] == null)
            evaluationsBySubject[evaluation.Subject] = List();
          evaluationsBySubject[evaluation.Subject].add(evaluation);
        }

        evaluationsBySubject.forEach((String subject, List evaluations) {
          averages.add(Average(
              subject,
              evaluations[0].SubjectCategory,
              evaluations[0].SubjectCategoryName,
              double.parse(getAverage(evaluations).toStringAsFixed(2)),
              0.0,
              0.0));
        });
      }
      if (averages == null || averages.isEmpty)
        averages = [Average("", "", "", 0.0, 0.0, 0.0)];
      averages.sort((Average a, Average b) {
        return a.subject.compareTo(b.subject);
      });
      selectedAverage = averages[0];
      globals.selectedAverage = selectedAverage;
      avrString = selectedAverage.value.toString();
      classAvrString = selectedAverage.classValue.toString();
    });

    initEvals();
  }

  void _initAllEvals() async {
    try {
      await globals.selectedAccount.refreshStudentString(true, false);
      allEvals = (globals.selectedAccount.student.Evaluations
          .where((Evaluation evaluation) => evaluation.isMidYear())).toList();
    } catch (exeption) {
      Fluttertoast.showToast(
          msg: "Nem sikerült betölteni a jegyeket",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _onSelect(Average average) async {
    setState(() {
      selectedAverage = average;
      globals.selectedAverage = selectedAverage;
      globals.currentEvals.clear();
      timeData.clear();
      series = [
        Series(
          displayName: "asd",
          id: "averages",
          colorFn: (_, __) => color,
          domainFn: (TimeAverage sales, _) => sales.time,
          measureFn: (TimeAverage sales, _) => sales.sales,
          data: timeData,
        ),
      ];
    });

    for (Evaluation e in evals) {
      if (e.NumberValue != 0) {
        if (average.subject == e.Subject) {
          globals.currentEvals.add(e);
          setState(() {
            timeData.add(TimeAverage(e.CreatingTime, e.NumberValue));
            series = [
              Series(
                displayName: "asd",
                id: "averages",
                colorFn: (_, __) => color,
                domainFn: (TimeAverage sales, _) => sales.time,
                measureFn: (TimeAverage sales, _) => sales.sales,
                data: timeData,
              ),
            ];
          });
        }
      }
    }
    avrString = average.value.toString();
  }

  void callback() {
    setState(() {
      timeData.clear();
      double sum = 0;
      double n = 0;
      for (Evaluation e in globals.currentEvals) {
        if (e.NumberValue != 0) {
          double multiplier = 1;
          try {
            multiplier = double.parse(e.Weight.replaceAll("%", "")) / 100;
          } catch (e) {
            print("[E] evaluationsScreen.callback(): " + e.toString());
          }

          sum += e.NumberValue * multiplier;
          n += multiplier;

          setState(() {
            timeData.add(TimeAverage(e.CreatingTime, e.NumberValue));
            series = [
              Series(
                displayName: "asd",
                id: "averages",
                colorFn: (_, __) => color,
                domainFn: (TimeAverage sales, _) => sales.time,
                measureFn: (TimeAverage sales, _) => sales.sales,
                data: timeData,
              ),
            ];
          });
          avrString = (sum / n).toStringAsFixed(2);
        }
      }
    });
  }

  void refreshSort() async {
    setState(() {
      switch (globals.sort) {
        case 0:
          allEvals.sort((a, b) => b.CreatingTime.compareTo(a.CreatingTime));
          break;
        case 1:
          allEvals.sort((a, b) {
            if (a.realValue == b.realValue)
              return b.CreatingTime.compareTo(a.CreatingTime);
            return a.realValue.compareTo(b.realValue);
          });
          break;
        case 2:
          allEvals.sort((a, b) => b.Date.compareTo(a.Date));
          break;
        case 3:
          allEvals.sort((a, b) {
            if (a.Subject == b.Subject)
              return b.CreatingTime.compareTo(a.CreatingTime);
            return a.Subject.compareTo(b.Subject);
          });
          break;
      }
    });
  }

  int currentBody = 0;
  Widget evaluationsBody;
  Widget averageBody;
  Widget dataBody;

  @override
  Widget build(BuildContext context) {
    series = [
      Series(
        displayName: "asd",
        id: "averages",
        colorFn: (_, __) => color,
        domainFn: (TimeAverage sales, _) => sales.time,
        measureFn: (TimeAverage sales, _) => sales.sales,
        data: timeData,
      ),
    ];

    Card Separator(String text) {
      return Card(
          color: globals.isDark ? Colors.grey[1000] : Colors.grey[300],
          child: Container(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            alignment: Alignment(0, 0),
            constraints: BoxConstraints.expand(height: 36),
          ),
          margin: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 3));
    }

    Widget _allBuilder(BuildContext context, int index) {
      Widget sep = Container();
      if (globals.sort == 1) {
        if (((index == 0) && (allEvals[index].Value.length < 16) ||
            (allEvals[index].Value != allEvals[index - 1].Value &&
                allEvals[index].Value.length < 16)))
          sep = Separator(allEvals[index].Value);
      } else if (globals.sort == 3) {
        if (index == 0 ||
            (allEvals[index].Subject != allEvals[index - 1].Subject))
          sep = Separator(allEvals[index].Subject);
      }

      return Column(
        children: <Widget>[
          sep,
          Card(
            child: ListTile(
              leading: Container(
                child: Text(
                  allEvals[index].realValue.toString() ?? "",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color:
                          getColors(context, allEvals[index].realValue, false)),
                ),
                alignment: Alignment(0, 0),
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    color: getColors(context, allEvals[index].realValue, true),
                    border: Border.all(
                        color: (allEvals[index].Weight != "100%" &&
                                allEvals[index].Weight != null)
                            ? globals.isDark ? Colors.white38 : Colors.black38
                            : Colors.transparent,
                        width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(40))),
              ),
              title: Text(allEvals[index].Subject ??
                  allEvals[index].Jelleg.Leiras ??
                  ""),
              subtitle: Text(
                (allEvals[index].Mode != null)
                    ? (allEvals[index].Theme == "")
                        ? allEvals[index].Mode
                        : allEvals[index].Theme
                    : "",
                style: TextStyle(
                    fontStyle: (allEvals[index].Theme == "")
                        ? FontStyle.italic
                        : FontStyle.normal),
              ),
              trailing: Column(
                children: <Widget>[
                  Text(dateToHuman(allEvals[index].Date)) ?? "",
                  Text(dateToWeekDay(allEvals[index].Date, context)) ?? "",
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
              onTap: () {
                _evaluationDialog(allEvals[index]);
              },
            ),
          ),
        ],
      );
    }

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final List<ButtonOptionItem> items = [
      ButtonOptionItem(I18n
          .of(context)
          .sortTime, Icon(Icons.timer)),
      ButtonOptionItem(I18n
          .of(context)
          .sortEval, Icon(Icons.apps)),
      ButtonOptionItem(I18n
          .of(context)
          .sortTimeReal, Icon(Icons.access_time)),
      ButtonOptionItem(I18n
          .of(context)
          .homeworkSubject, Icon(Icons.category)),
    ];

    evaluationsBody = Scaffold(
        floatingActionButton: new SelectButton(
          items: items,
          selected: globals.sort,
          onChanged: (int i) {
            globals.sort = i;
            refreshSort();
          },
          tooltip: I18n.of(context).sort,
        ),
        body: (Container(
            child: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemBuilder: _allBuilder,
              itemCount: allEvals.length,
            ))
          ],
        ))));

    averageBody = Scaffold(
      //"Statisztika" "Statistics"
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: selectedAverage != null
                  ? DropdownButton(
                      items: averages.map((Average average) {
                        return DropdownMenuItem<Average>(
                            value: average,
                            child: Row(
                              children: <Widget>[
                                Text(average.subject),
                              ],
                            ));
                      }).toList(),
                      onChanged: _onSelect,
                      value: selectedAverage,
                    )
                  : Container(),
              alignment: Alignment(0, 0),
              margin: EdgeInsets.all(5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(capitalize(I18n.of(context).evaluationAverage) + ": "),
                Text(
                  avrString,
                  style: TextStyle(
                      color: getColorForAverageString(avrString),
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                ),
                selectedAverage != null
                    ? selectedAverage.classValue != null
                        ? Text(capitalize(
                                I18n.of(context).evaluationAverageClass) +
                            ": ")
                        : Container()
                    : Container(),
                selectedAverage != null
                    ? selectedAverage.classValue != null
                        ? Text(
                            selectedAverage.classValue != 0
                                ? selectedAverage.classValue.toString()
                                : r"¯\_(ツ)_/¯",
                            style: TextStyle(
                                color: getColorForAverage(
                                    selectedAverage.classValue),
                                fontWeight: FontWeight.bold),
                          )
                        : Container()
                    : Container(),
              ],
            ),
            Container(
              child: SizedBox(
                child: TimeSeriesChart(
                  series,
                  animate: true,
                  primaryMeasureAxis: NumericAxisSpec(
                    showAxisLine: true,
                  ),
                ),
                height: 150,
              ),
            ),
            Flexible(
              //Build list of evaluations below graph
              child: ListView.builder(
                itemBuilder: _itemBuilder,
                itemCount: globals.currentEvals.length,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  return GradeDialog(this.callback);
                },
              ) ??
              false;
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        tooltip: I18n.of(context).sort,
      ),
    );

    dataBody = ListView(children: <Widget>[
      //"Eredmények" "Results"
      Table(
        children: [
          TableRow(
            children: <Widget>[
              EvalCount(context, 5, db5),
              EvalCount(context, 4, db4),
              EvalCount(context, 3, db3)
            ],
          ),
          TableRow(
            children: <Widget>[
              EvalCount(context, 2, db2),
              EvalCount(context, 1, db1),
              Container(
                  child: Card(
                      child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                  capitalize(
                                          I18n.of(context).evaluationAverage) +
                                      ": ",
                                  style: TextStyle(fontSize: 18.0)),
                              Text(
                                allAverage.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          color:
                              globals.isDark ? Colors.black54 : Colors.white70),
                      color: getColorForAverage(allAverage)),
                  height: 70)
            ],
          )
        ],
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      ),
      Column(children: summaryCardsToShow)
    ]);

    return WillPopScope(
        onWillPop: () {
          globals.screen = 0;
          Navigator.pushReplacementNamed(context, "/home");
        },
        child: Scaffold(
            key: _scaffoldKey,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentBody,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    title: Text(I18n.of(context).evaluationNavigationAll)),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  title: Text(I18n.of(context).evaluationNavigationStatistics),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  title: Text(I18n.of(context).evaluationNavigationResults),
                ),
              ],
              onTap: switchToScreen,
            ),
            drawer: GlobalDrawer(),
            appBar: AppBar(
                title: Text(capitalize(I18n.of(context).evaluationTitle))),
            body: (currentBody == 0
                ? evaluationsBody
                : (currentBody == 1 ? averageBody : dataBody))));
  }

  void switchToScreen(int n) {
    setState(() {
      currentBody = n;
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    try {
      return Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Container(
                child: Text(
                  globals.currentEvals[index].realValue.toString(),
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: getColors(context,
                          globals.currentEvals[index].realValue, false)),
                ),
                alignment: Alignment(0, 0),
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    color: getColors(
                        context, globals.currentEvals[index].realValue, true),
                    border: Border.all(
                        color: (globals.currentEvals[index].Weight != "100%" &&
                                globals.currentEvals[index].Weight != null)
                            ? globals.isDark ? Colors.white38 : Colors.black38
                            : Colors.transparent,
                        width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(40))),
              ),
              title: Text(
                (globals.currentEvals[index].Mode != null)
                    ? (globals.currentEvals[index].Theme == "")
                        ? globals.currentEvals[index].Mode
                        : globals.currentEvals[index].Theme
                    : "",
                style: TextStyle(
                    fontStyle: (globals.currentEvals[index].Theme == "")
                        ? FontStyle.italic
                        : FontStyle.normal),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(dateToHuman(globals.currentEvals[index].Date)),
                      Text(dateToWeekDay(
                          globals.currentEvals[index].Date, context)),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                  globals.currentEvals[index].Mode == "Hamis"
                      ? Container(
                          padding: EdgeInsets.all(0.0),
                          margin: EdgeInsets.all(0),
                          height: 40,
                          width: 40,
                          child: FlatButton(
                            onPressed: () {
                              setState(() {
                                globals.currentEvals.removeAt(index);
                                callback();
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                            padding: EdgeInsets.all(0.0),
                          ),
                        )
                      : Container(),
                ],
              ),
              onTap: () {
                try {
                  _evaluationDialog(globals.currentEvals[index]);
                } catch (exeption) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      content: Text(
                        I18n.of(context).error,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      )));
                  print("[E] evaluationsScreen._itemBuilder()1: " +
                      exeption.toString());
                }
              },
            ),
          ),
        ],
      );
    } catch (e) {
      print("[E] evaluationsScreen._itemBuilder()2: " + e.toString());
    }
  }

  Future<Null> _evaluationDialog(Evaluation evaluation) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(evaluation.Subject ?? "" + evaluation.Value ?? ""),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                evaluation.Theme != null
                    ? Text(capitalize(I18n.of(context).lessonTheme) +
                            ": " +
                            evaluation.Theme ??
                        "")
                    : Container(),
                Text(capitalize(I18n.of(context).lessonTeacher) +
                        ": " +
                        evaluation.Teacher ??
                    ""),
                Text(capitalize(I18n.of(context).time) +
                    ": " +
                    dateToHuman(evaluation.Date ?? "")),
                evaluation.Mode != null
                    ? Text(capitalize(I18n.of(context).evaluationMode) +
                        ": " +
                        evaluation.Mode)
                    : Container(),
                Text(capitalize(I18n.of(context).administrationTime) +
                    ": " +
                    dateToHuman(evaluation.CreatingTime ?? "")),
                evaluation.Weight != null
                    ? Text(capitalize(I18n.of(context).evaluationWeight) +
                            ": " +
                            evaluation.Weight ??
                        "")
                    : Container(),
                Text(capitalize(I18n.of(context).evaluationValue) +
                        ": " +
                        evaluation.Value ??
                    ""),
                Text(capitalize(I18n.of(context).evaluationRange) +
                        ": " +
                        evaluation.FormName ??
                    ""),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(I18n.of(context).dialogOk.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TimeAverage {
  DateTime time;
  int sales;

  TimeAverage(this.time, this.sales);
}

class GradeDialog extends StatefulWidget {
  Function callback;
  GradeDialog(this.callback);
  @override
  GradeDialogState createState() => GradeDialogState();
}

class GradeDialogState extends State<GradeDialog> {
  static const List<int> GRADES = [1, 2, 3, 4, 5];

  var jegy = 1;
  bool isTZ = false;

  String weight = "100";
  String tzWeight = "200";

  void _onWeightInput(String text) {
    tzWeight = text;
    weight = text;
  }

  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text(I18n.of(context).evaluationIf),
      children: <Widget>[
        Container(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Radio<int>(
                  value: 1,
                  groupValue: jegy,
                  onChanged: (int value) {
                    setState(() {
                      jegy = value;
                    });
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
                Radio<int>(
                  value: 2,
                  groupValue: jegy,
                  onChanged: (int value) {
                    setState(() {
                      jegy = value;
                    });
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
                Radio<int>(
                  value: 3,
                  groupValue: jegy,
                  onChanged: (int value) {
                    setState(() {
                      jegy = value;
                    });
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
                Radio<int>(
                  value: 4,
                  groupValue: jegy,
                  onChanged: (int value) {
                    setState(() {
                      jegy = value;
                    });
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
                Radio<int>(
                  value: 5,
                  groupValue: jegy,
                  onChanged: (int value) {
                    setState(() {
                      jegy = value;
                    });
                  },
                  activeColor: Theme.of(context).accentColor,
                ),
              ]),
          padding: EdgeInsets.only(left: 20, right: 20),
        ),
        Container(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              Text(
                "1",
                textAlign: TextAlign.center,
              ),
              Text(
                "2",
                textAlign: TextAlign.center,
              ),
              Text(
                "3",
                textAlign: TextAlign.center,
              ),
              Text(
                "4",
                textAlign: TextAlign.center,
              ),
              Text(
                "5",
                textAlign: TextAlign.center,
              ),
            ])),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(capitalize(I18n.of(context).evaluationWeight) + ": "),
              Checkbox(
                value: isTZ,
                onChanged: (value) {
                  setState(() {
                    isTZ = value;
                    if (value)
                      weight = tzWeight;
                    else
                      weight = "100";
                  });
                },
                activeColor: Theme.of(context).accentColor,
              ),
              Container(
                width: 60,
                child: TextField(
                  maxLines: 1,
                  onChanged: _onWeightInput,
                  autocorrect: false,
                  autofocus: isTZ,
                  decoration:
                      InputDecoration(suffix: Text("%"), hintText: "200"),
                  keyboardAppearance: Brightness.dark,
                  enabled: isTZ,
                ),
              ),
            ],
          ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              Evaluation falseGrade = Evaluation.fromMap(json.decode("""
              {
      "EvaluationId": 12345678,
      "Form": "Mark",
      "FormName": "Elégtelen (1) és Jeles (5) között az öt alapértelmezett érték",
      "Type": "MidYear",
      "TypeName": "Évközi jegy/értékelés",
      "Subject": "${globals.selectedAverage.subject}",
      "SubjectCategory": null,
      "SubjectCategoryName": "",
      "Theme": "${I18n.of(context).evaluationIf}",
      "IsAtlagbaBeleszamit": true,
      "Mode": "Hamis",
      "Weight": "$weight%",
      "Value": "Jeles(5)",
      "NumberValue": $jegy,
      "SeenByTutelaryUTC": null,
      "Teacher": "",
      "Date": "${DateTime.now().toIso8601String()}",
      "CreatingTime": "${DateTime.now().toIso8601String()}",
      "Jelleg": {
        "Id": 1,
        "Nev": "Ertekeles",
        "Leiras": "Értékelés"
      },
      "JellegNev": "Ertekeles",
      "ErtekFajta": {
        "Id": 1,
        "Nev": "Osztalyzat",
        "Leiras": "Osztályzat"
      }
    }
              """), globals.selectedUser);
              globals.currentEvals.insert(0, falseGrade);
              this.widget.callback();
              Navigator.pop(context);
            });
          },
          child: Text(
            I18n.of(context).dialogDone.toUpperCase(),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          padding: EdgeInsets.all(10),
        ),
      ],
    );
  }
}
