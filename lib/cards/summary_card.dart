//Contributed by RedyAu

import 'dart:async';

import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';

import 'package:filcnaplo/models/student.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/utils/color_manager.dart';

class SummaryCard extends StatelessWidget {
  List<Evaluation> summaryEvaluations;
  BuildContext context;
  int summaryType;
  DateTime date;
  int type;
  String title;
  bool showTheme;
  bool showTitle;
  bool showColor;

  SummaryCard(List<Evaluation> summaryEvaluations, BuildContext context,
      int type, bool showTheme, bool showTitle, bool showColor) {
    //Summary types: 1: 1st Q, 2: Mid-year, 3: 3rd Q, 4: End-year
    this.summaryEvaluations = summaryEvaluations;
    this.context = context;
    switch (type) {
      case 1:
        title = I18n.of(context).summaryFirstQ;
        break;
      case 2:
        title = I18n.of(context).summarySecondQ;
        break;
      case 3:
        title = I18n.of(context).summaryThirdQ;
        break;
      case 4:
        title = I18n.of(context).summaryFourthQ;
        break;
      case 5:
        title = I18n.of(context).summaryHalfYear;
        break;
      case 6:
        title = I18n.of(context).summaryEndYear;
        break;
    }
    this.showTheme = showTheme;
    this.showTitle = showTitle;
    this.showColor = showColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: !showColor
            ? globals.isDark
                ? Color.fromARGB(255, 25, 25, 25)
                : Colors.grey[300]
            : summaryEvaluations.first.owner.color ??
                (globals.isDark
                    ? Color.fromARGB(255, 25, 25, 25)
                    : Colors
                        .grey[300]), //If a user logs in, default color is null.
        margin: EdgeInsets.all(6.0),
        child: Container(
          child: Column(
            children: <Widget>[
              showTitle
                  ? Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          !showColor
                              ? Container()
                              : Text(
                                  summaryEvaluations.first.owner.name,
                                  textAlign: TextAlign.center,
                                )
                        ],
                        mainAxisAlignment: !showColor
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                      ),
                      padding: EdgeInsets.all(7),
                      constraints: BoxConstraints.expand(height: 36),
                    )
                  : Container(),
              Container(
                child: evaluationList(context),
                padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      style: BorderStyle.none,
                      width: 0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: globals.isDark
                      ? globals.isAmoled
                          ? Colors.black
                          : Color.fromARGB(255, 15, 15, 15)
                      : Colors.white,
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: !showColor
                    ? globals.isDark
                        ? Color.fromARGB(255, 25, 25, 25)
                        : Colors.grey[300]
                    : summaryEvaluations.first.owner.color ??
                        (globals.isDark
                            ? Color.fromARGB(255, 25, 25, 25)
                            : Colors.grey[300]),
                width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            style: BorderStyle.none,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ));
  }

  //Place the card on the main page where the last item on it would go
  String getDate() {
    return summaryEvaluations.first.CreatingTime.toIso8601String() ??
        "" + summaryEvaluations.first.trueID().toString() ??
        "";
  }

  @override
  Key get key => Key(getDate());

  Widget evaluationList(BuildContext context) {
    return Column(children: <Widget>[
      for (Evaluation evaluation in summaryEvaluations) 
        ListTile(
          leading: Container(
            child: Text(evaluation.realValue.toString(),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: globals.isColor
                      ? getColors(context, evaluation.realValue, false)
                      : Colors.white,
                )),
            alignment: Alignment(0, 0),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: globals.isColor
                    ? getColors(context, evaluation.realValue, true)
                    : Color.fromARGB(255, 15, 15, 15),
                borderRadius: BorderRadius.all(Radius.circular(40)),
                border: Border.all(
                  color: (evaluation.Theme == "Dicséret")
                    ? globals.isDark 
                      ? Colors.white38
                      : Colors.black38
                    : Colors.transparent,
                    width: 3
                )
          )),
          title: Text(
            (evaluation.Subject == " " || evaluation.Subject == null) 
              ? evaluation.Jelleg.Leiras
              : evaluation.Subject,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(evaluation.Teacher),
          trailing: Text(dateToHuman(evaluation.Date)),
          onTap: () {
            openDialog(evaluation);
          },
        )
    ]);
  }

  void openDialog(Evaluation evaluation) {
    _evaluationDialog(evaluation);
  }

  Widget listEntry(String data, {bold = false, right = false}) => Container(
        child: Text(
          data??" ",
          style: TextStyle(
              fontSize: right ? 16 : 19,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
        alignment: right ? Alignment(1, -1) : Alignment(0, 0),
        padding: EdgeInsets.only(bottom: 3),
      );

  Future<Null> _evaluationDialog(Evaluation evaluation) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  evaluation.Value != null
                      ? listEntry(evaluation.Value)
                      : Container(),
                  evaluation.Weight != "" &&
                          evaluation.Weight != "100%" &&
                          evaluation.Weight != null
                      ? listEntry(evaluation.Weight,
                          bold: ["200%", "300%"].contains(evaluation.Weight))
                      : Container(),
                  evaluation.Theme != "" && evaluation.Theme != null
                      ? listEntry(evaluation.Theme)
                      : Container(),
                  evaluation.Mode != "" && evaluation.Theme != null
                      ? listEntry(evaluation.Mode)
                      : Container(),
                  evaluation.CreatingTime != null
                      ? listEntry(dateToHuman(evaluation.CreatingTime),
                          right: true)
                      : Container(),
                  evaluation.Teacher != null
                      ? listEntry(evaluation.Teacher, right: true)
                      : Container(),
                ],
              ),
            ),
          ],
          title: (evaluation.Subject != null)
              ? Text(evaluation.Subject)
              : evaluation.Jelleg.Leiras != null
                  ? Text(evaluation.Jelleg.Leiras)
                  : Container(),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }
}
