import 'dart:async';

import 'package:flutter/material.dart';

import 'package:filcnaplo/Datas/Student.dart';
import 'package:filcnaplo/Helpers/SettingsHelper.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

class EvaluationCard extends StatelessWidget {
  Evaluation evaluation;
  Color bColor;
  Color fColor;

  IconData typeIcon;
  String typeName;
  bool showPadding;
  bool isSingle;

  BuildContext context;

  String textShort;

  Future<bool> get isColor async {
    return await SettingsHelper().getColoredMainPage();
  }

  EvaluationCard(Evaluation evaluation, bool isColor, bool isSingle,
      BuildContext context) {
    this.evaluation = evaluation;
    this.context = context;

    bool hastype = true;
    this.isSingle = isSingle;

    if (isColor) {
      switch (evaluation.realValue) {
        //Define background and foreground color of the card for number values.
        case 1:
          bColor = globals.color1;
          fColor = globals.colorF1;
          break;
        case 2:
          bColor = globals.color2;
          fColor = globals.colorF2;
          break;
        case 3:
          bColor = globals.color3;
          fColor = globals.colorF3;
          break;
        case 4:
          bColor = globals.color4;
          fColor = globals.colorF4;
          break;
        case 5:
          bColor = globals.color5;
          fColor = globals.colorF5;
          break;
        default:
          bColor = Colors.black;
          fColor = Colors.white;
          break;
      } //Define background and foreground color of the card for text values.
    } //Map text values to be more readable
    switch (evaluation.Value) {
      case "Példás":
        textShort = "5";
        break;
      case "Jó":
        textShort = "4";
        break;
      case "Változó":
        textShort = "3";
        break;
      case "Hanyag":
        textShort = "2";
        break;
    }

    switch (evaluation.Mode) {
      //Map evalutaion types to shorter, more readable versions. Set icons.
      case "Írásbeli témazáró dolgozat":
        typeIcon = Icons.widgets;
        typeName = "témazáró";
        break;
      case "Témazáró":
        typeIcon = Icons.widgets;
        typeName = "témazáró";
        break;
      case "Írásbeli röpdolgozat":
        typeIcon = Icons.border_color;
        typeName = "röpdolgozat";
        break;
      case "Beszámoló":
        typeIcon = Icons.border_color;
        typeName = "beszámoló";
        break;
      case "Dolgozat":
        typeIcon = Icons.subject;
        typeName = "dolgozat";
        break;
      case "Projektmunka":
        typeIcon = Icons.assignment;
        typeName = "projektmunka";
        break;
      case "Gyakorlati feladat":
        typeIcon = Icons.directions_walk;
        typeName = "gyakorlati feladat";
        break;
      case "Szódolgozat":
        typeIcon = Icons.language;
        typeName = "szódolgozat";
        break;
      case "Szóbeli felelet":
        typeIcon = Icons.person;
        typeName = "felelés";
        break;
      case "Házi feladat":
        typeIcon = Icons.home;
        typeName = "házi feladat";
        break;
      case "Órai munka":
        typeIcon = Icons.school;
        typeName = "órai munka";
        break;
      case "Versenyen, vetélkedőn való részvétel":
        typeIcon = Icons.account_balance;
        typeName = "verseny";
        break;
      case "Magyar nyelv évfolyamdolgozat":
        typeIcon = Icons.book;
        typeName = "évfolyamdolgozat";
        break;
      case "év végi":
        typeIcon = IconData(0xF23C, fontFamily: "Material Design Icons");
        typeName = "év végi dolgozat";
        break;
      case "Házi dolgozat":
        typeIcon = IconData(0xF224, fontFamily: "Material Design Icons");
        typeName = "házi dolgozat";
        break;
      case "":
        typeIcon = null;
        typeName = "";
        hastype = false;
        break;
      case "Na":
        typeIcon = null;
        typeName = "";
        hastype = false;
        break;
      default:
        typeIcon = IconData(0xf625, fontFamily: "Material Design Icons");
        typeName = evaluation.Mode;
        break;
    }

    showPadding = !isSingle || hastype;
  }

  String getDate() {
    return evaluation.CreatingTime.toIso8601String() ??
        "" + evaluation.trueID().toString() ??
        "";
  }

  @override
  Key get key => new Key(getDate());

  void openDialog() {
    _evaluationDialog(evaluation);
  }

  Widget listEntry(String data, {bold = false, right = false}) => Container(
        child: Text(
          data,
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
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openDialog,
      child: Card(
        margin: EdgeInsets.all(6.0),
        color: bColor,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: ListTile(
                  title: evaluation.Subject != null
                      ? Text(evaluation.Subject,
                          style: TextStyle(
                              color: fColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold))
                      : evaluation.Jelleg.Leiras != null
                          ? Text(evaluation.Jelleg.Leiras,
                              style: TextStyle(
                                  color: fColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold))
                          : Container(),
                  leading: (evaluation.NumberValue != 0 && textShort == null)
                      ? Text(evaluation.NumberValue.toString(),
                          style: TextStyle(
                              color: fColor,
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold))
                      : Text(textShort ?? "",
                          style: TextStyle(
                              color: fColor,
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      evaluation.isText()
                          ? Text(evaluation.Value)
                          : Container(),
                      evaluation.Theme != null
                          ? Text(evaluation.Theme,
                              style:
                                  TextStyle(color: fColor, fontSize: 18.0))
                          : Container(),
                      Text(
                        evaluation.Teacher,
                        style: TextStyle(color: fColor, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
                margin: EdgeInsets.all(6.0),
              ),
              !showPadding || !isSingle
                  ? Container(
                      child: Text(
                          dateToHuman(evaluation.Date) ??
                              "" + dateToWeekDay(evaluation.Date, context) ??
                              "",
                          style: TextStyle(fontSize: 16.0, color: fColor)),
                      alignment: Alignment(1.0, -1.0),
                    )
                  : Container(),
              showPadding
                  ? Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            style: BorderStyle.none,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        color: globals.isDark
                            ? Color.fromARGB(255, 25, 25, 25)
                            : Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(7.0, 3.0, 12.0, 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Divider(),
                            Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Icon(typeIcon,
                                  color: globals.isDark
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                            Padding(
                              padding: EdgeInsets.all(7.0),
                              child: typeName != null
                                  ? Text(
                                      typeName,
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: globals.isDark
                                              ? Colors.white
                                              : Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )
                                  : Text(
                                      evaluation.Value,
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: globals.isDark
                                              ? Colors.white
                                              : Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                            ),
                            Container(
                              child: Padding(
                                child: (evaluation.Weight != "100%" &&
                                        evaluation.Weight != null)
                                    ? Text(evaluation.Weight,
                                        style: TextStyle(
                                            color: globals.isDark
                                                ? Colors.white
                                                : Colors.black87))
                                    : null,
                                padding: EdgeInsets.all(2.0),
                              ),
                              alignment: Alignment(-1.0, 0.0),
                            ),
                            !isSingle
                                ? Expanded(
                                    child: Container(
                                      child: Text(
                                          evaluation.owner.name ?? "",
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: evaluation.owner.color ??
                                                  Colors.black,
                                              fontSize: 18.0)),
                                      alignment: Alignment(1.0, -1.0),
                                    ),
                                  )
                                : Container(),
                            isSingle
                                ? Expanded(
                                    child: Container(
                                      child: Text(
                                        dateToHuman(evaluation.Date) ??
                                            "" +
                                                dateToWeekDay(
                                                    evaluation.Date, context) ??
                                            "",
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: globals.isDark
                                                ? Colors.white
                                                : Colors.black87),
                                        textAlign: TextAlign.end,
                                      ),
                                      alignment: Alignment(1.0, 0.0),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ))
                  : Container()
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}
