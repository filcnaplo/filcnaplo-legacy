import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:filcnaplo/models/note.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/generated/i18n.dart';

class NoteCard extends StatelessWidget {
  Note note;
  BuildContext context;
  bool isSingle;

  NoteCard(Note note, isSingle, BuildContext context) {
    this.note = note;
    this.isSingle = isSingle;
    this.context = context;
  }

  String getDate() {
    return note.date.toIso8601String();
  }

  @override
  Key get key => Key(getDate());

  void openDialog() {
    _noteDialog(note);
  }

  Future<Null> _noteDialog(Note note) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SingleChildScrollView(
              child: Linkify(
                text: note.content,
                onOpen: (String url) {
                  launcher.launch(url);
                },
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
          title: Text(
            note.title ?? "",
          ),
          contentPadding: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
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
        shape: RoundedRectangleBorder(
          side: BorderSide(
            style: BorderStyle.none,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: EdgeInsets.all(6.0),
        color: globals.isColor
            ? note.isEvent ? Colors.lightBlueAccent[400] : Colors.blue[600]
            : globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Text(
                  note.title,
                  style: TextStyle(
                      fontSize: 21.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.all(10.0),
              ),
              Container(
                child: Text(note.content,
                    maxLines: 4,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17.0,
                        color: globals.isColor
                            ? Colors.white
                            : globals.isDark ? Colors.white : Colors.black)),
                padding: EdgeInsets.all(10.0),
              ),
              !isSingle
                  ? Container(
                      child: Text(dateToHuman(note.date),
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                      alignment: Alignment(1.0, -1.0),
                      padding: EdgeInsets.fromLTRB(5.0, 5.0, 10.0, 5.0),
                    )
                  : Container(),
              Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        style: BorderStyle.none,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: globals.isDark
                        ? Color.fromARGB(255, 25, 25, 25)
                        : Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 2),
                          child: Icon(
                            note.isEvent
                                ? IconData(0xf0e5,
                                    fontFamily: "Material Design Icons")
                                : Icons.comment,
                            color: globals.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Container(
                          child: Text(
                            note.isEvent
                                ? I18n.of(context).note2
                                : I18n.of(context).note,
                            style: TextStyle(fontSize: 18.0),
                          ),
                          padding: EdgeInsets.only(left: 8.0),
                        ),
                        Divider(),
                        isSingle
                            ? Expanded(
                                child: Container(
                                child: Text(dateToHuman(note.date),
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: globals.isDark
                                            ? Colors.white
                                            : Colors.grey[900])),
                                alignment: Alignment(1.0, 0.0),
                              ))
                            : Container(),
                        !isSingle
                            ? Expanded(
                                child: Container(
                                  child: Text(note.owner.name,
                                      style: TextStyle(
                                          color: note.owner.color ??
                                              (globals.isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          fontSize: 18.0)),
                                  alignment: Alignment(1.0, -1.0),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  )),
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
                color: globals.isColor
                    ? note.isEvent ? Colors.lightBlueAccent[400] : Colors.blue[600]
                    : globals.isDark
                        ? Color.fromARGB(255, 25, 25, 25)
                        : Colors.white,
                width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}
