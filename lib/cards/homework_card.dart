import 'package:filcnaplo/datas/homework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:filcnaplo/datas/note.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class HomeworkCard extends StatelessWidget {
  Homework homework;
  BuildContext context;
  bool isSingle;

  HomeworkCard(Homework homework, isSingle, BuildContext context) {
    this.homework = homework;
    this.isSingle = isSingle;
    this.context = context;
  }

  String getDate() {
    return homework.uploadDate;
  }

  @override
  Key get key => Key(getDate());

  void openDialog() {
    //_noteDialog(note);
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
              ),
            ),
          ],
          title: Text(
            note.title ?? "",
          ),
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
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
        color: Colors.lightBlue,
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                homework.uploader,
                style: TextStyle(
                    fontSize: 21.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              margin: EdgeInsets.all(10.0),
            ),
            Container(
              child: Html(
                data: HtmlUnescape().convert(homework.text),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            Divider(
              height: 1.0,
              color: Colors.white,
            ),
            Container(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Divider(),
                      isSingle || homework.owner == null
                          ? Expanded(
                              child: Container(
                              child: Text(homework.deadline,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white)),
                              alignment: Alignment(1.0, 0.0),
                            ))
                          : Container(),
                      !isSingle
                          ? Expanded(
                              child: Container(
                                child: Text(homework.owner.name,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.0)),
                                alignment: Alignment(1.0, -1.0),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
