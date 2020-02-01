import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../Datas/Note.dart';
import '../Utils/StringFormatter.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../globals.dart' as globals;

class NoteCard extends StatelessWidget {
  Note note;
  BuildContext context;
  bool isSingle;

  NoteCard(Note note, isSingle, BuildContext context){
    this.note = note;
    this.isSingle = isSingle;
    this.context = context;
  }

  String getDate(){
    return note.date.toIso8601String();
  }
  @override
  Key get key => new Key(getDate());

  void openDialog() {
    _noteDialog(note);
  }

  Future<Null> _noteDialog(Note note) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new SimpleDialog(
          children: <Widget>[
            new SingleChildScrollView(
              child: new Linkify(
                  text: note.content,
                  onOpen: (String url) {launcher.launch(url);},
                  style: new TextStyle(fontSize: 18.0),
              ),
            ),
          ],
          title: Text(note.title ?? "", ),
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
    if (!note.isEvent)
    return new GestureDetector(
      onTap: openDialog,
      child: new Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          style: BorderStyle.none,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: EdgeInsets.all(6.0),
      color: globals.isColor ? Colors.blue : globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
      child: Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Text(note.title, style: new TextStyle(fontSize: 21.0, color: Colors.white, fontWeight: FontWeight.bold),),
              margin: EdgeInsets.all(10.0),
            ),

            new Container(
              child: new Text(note.content, 
                  style: new TextStyle(
                    fontSize: 17.0, 
                    color: globals.isColor ? Colors.white : globals.isDark ? Colors.white : Colors.black)),
              padding: EdgeInsets.all(10.0),
            ),

            !isSingle ? new Container(
              child: new Text(dateToHuman(note.date) + dateToWeekDay(note.date), style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              alignment: Alignment(1.0, -1.0),
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 10.0, 5.0),
            ) : new Container(),

            new Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    style: BorderStyle.none,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                color: globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
              ),
              child: new Padding(
                padding: new EdgeInsets.all(10.0),
                child: new Row(
                  children: <Widget>[
                    new Container(
                      padding: new EdgeInsets.only(left: 2),
                      child: new Icon(
                        IconData(0xf0e5, fontFamily: "Material Design Icons"),
                        color: globals.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    new Container(
                      child: new Text("Feljegyzés",
                        style: new TextStyle(fontSize: 18.0),
                      ),
                      padding: EdgeInsets.only(left: 8.0),
                    ),
                    new Divider(),
                    isSingle ? new Expanded(
                        child: new Container(
                          child: new Text(dateToHuman(note.date) + dateToWeekDay(note.date), style: new TextStyle(fontSize: 16.0, color: globals.isDark ? Colors.white : Colors.grey[900])),
                          alignment: Alignment(1.0, 0.0),
                        )) : new Container(),

                    !isSingle ? new Expanded(
                      child: new Container(
                        child: new Text(note.owner.name, 
                            style: new TextStyle(
                              color: note.owner.color ??
                                  (globals.isDark ? Colors.white : Colors.black),
                              fontSize: 18.0)),
                        alignment: Alignment(1.0, -1.0),
                      ),
                    ) : new Container(),
                  ],
                  ),
              )
            ),
          ],
        ),
        decoration: new BoxDecoration(
            border: Border.all(
              color: globals.isColor ? Colors.blue : globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
              width: 2.5),
            borderRadius: new BorderRadius.all(Radius.circular(5)),
          ),
        ),
        ),
      );
      else
      return new GestureDetector(
          onTap: openDialog,
          child: Card(
        color: globals.isColor ? Colors.blue : globals.isDark ? Color.fromARGB(255, 25, 25, 25) : Colors.white,
        child: new Column(
          children: <Widget>[

            new Container(
              child: new Text(note.content, style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              padding: EdgeInsets.all(10.0),
            ),

            !isSingle ? new Container(
              child: new Text(dateToHuman(note.date) + dateToWeekDay(note.date), style: new TextStyle(fontSize: 16.0, color: Colors.white)),
              alignment: Alignment(1.0, -1.0),
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 10.0, 5.0),
            ) : new Container(),

            new Container(
                color: Color.fromARGB(255, 25, 25, 25),
                child: new Padding(
                  padding: new EdgeInsets.all(10.0),
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        padding: new EdgeInsets.only(left: 2),
                        child: new Icon(
                          IconData(0xf0e5, fontFamily: "Material Design Icons"),
                          color: globals.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      new Container(
                        child: new Text("Feljegyzés",
                          style: new TextStyle(fontSize: 18.0),
                        ),
                        padding: EdgeInsets.only(left: 8.0),
                      ),
                      isSingle ? new Expanded(
                          child: new Container(
                            child: new Text(dateToHuman(note.date) + dateToWeekDay(note.date), style: new TextStyle(fontSize: 18.0, color: Colors.white)),
                            alignment: Alignment(1.0, 0.0),
                          )) : new Container(),

                      !isSingle ? new Expanded(
                        child: new Container(
                          child: new Text(note.owner.name, 
                              style: new TextStyle(
                                color: note.owner.color ??
                                    (globals.isDark ? Colors.white : Colors.black),
                                fontSize: 18.0)),
                          alignment: Alignment(1.0, -1.0),
                        ),
                      ) : new Container(),
                    ],
                  ),
                )
              ),
          ],
        ),
      ),
    );
  }
}
