import 'dart:async';

import 'package:filcnaplo/Dialog/ChooseLessonDialog.dart';
import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:filcnaplo/Datas/Homework.dart';
import 'package:filcnaplo/Datas/User.dart';
import 'package:filcnaplo/Dialog/TimeSelectDialog.dart';
import 'package:filcnaplo/GlobalDrawer.dart';
import 'package:filcnaplo/Helpers/HomeworkHelper.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/globals.dart' as globals;

void main() {
  runApp(new MaterialApp(home: new HomeworkScreen()));
}

class HomeworkScreen extends StatefulWidget {
  @override
  HomeworkScreenState createState() => new HomeworkScreenState();
}

class HomeworkScreenState extends State<HomeworkScreen> {
  List<User> users;

  bool hasLoaded = true;
  bool hasOfflineLoaded = false;

  List<Homework> homeworks = new List();
  List<Homework> selectedHomework = new List();

  @override
  void initState() {
    super.initState();
    _onRefreshOffline();
    _onRefresh(showErrors: false);
  }

  void refHomework() {
    setState(() {
      selectedHomework.clear();
    });

    for (Homework n in homeworks) {
      if (n.owner.id == globals.selectedUser.id) {
        setState(() {
          selectedHomework.add(n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return new WillPopScope(
        onWillPop: () {
          globals.screen = 0;
          Navigator.pushReplacementNamed(context, "/main");
        },
        child: Scaffold(
            drawer: GDrawer(),
            appBar: new AppBar(
              title: new Text(capitalize(I18n.of(context).homeworkTitle)),
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.access_time),
                  onPressed: () {
                    timeDialog().then((b) {
                      _onRefreshOffline();
                      refHomework();
                      _onRefresh();
                      refHomework();
                    });
                  },
                ),
                new IconButton(icon: Icon(Icons.plus_one), onPressed: _openChooser,)
              ],
            ),
            body: new Container(
                child: hasOfflineLoaded
                    ? new Column(children: <Widget>[
                        !hasLoaded
                            ? Container(
                                child: new LinearProgressIndicator(
                                  value: null,
                                ),
                                height: 3,
                              )
                            : Container(
                                height: 3,
                              ),
                        new Expanded(
                            child: new RefreshIndicator(
                                child: new ListView.builder(
                                  itemBuilder: _itemBuilder,
                                  itemCount: selectedHomework.length,
                                ),
                                onRefresh: _onRefresh)),
                      ])
                    : new Center(child: new CircularProgressIndicator()))));
  }

  Future<bool> _openChooser() {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return new ChooseLessonDialog();
      }
    );
  }

  Future<bool> timeDialog() {
    return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new TimeSelectDialog();
          },
        ) ?? 
        false;
  }

  Future<Null> homeworksDialog(Homework homework) async {
    if (homework.deletedBy > 0) {
      homework.text = "<strike>${homework.text}</strike>";
    }

    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(homework.subject + " " + I18n.of(context).homework),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                homework.deadline != null
                    ? new Text(capitalize(I18n.of(context).homeworkDeadline) +
                        ": " +
                        homework.deadline)
                    : new Container(),
                new Text(capitalize(I18n.of(context).homeworkSubject) +
                    ": " +
                    homework.subject),
                new Text(capitalize(I18n.of(context).homeworkUploadUser) +
                    ": " +
                    homework.uploader),
                new Text(capitalize(I18n.of(context).homeworkUploadTime) +
                    ": " +
                    homework.uploadDate
                        .substring(0, 11)
                        .replaceAll("-", '. ')
                        .replaceAll("T", ". ")),
                new Divider(
                  height: 4.0,
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                ),
                new Html(data: HtmlUnescape().convert(homework.text)),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: Icon(Icons.delete),
              onPressed: () {
                RequestHelper().deleteHomework(homework.id, globals.selectedUser);
              },
            ),
            new FlatButton(
              child: new Text(I18n.of(context).dialogOk.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> _onRefresh({bool showErrors = true}) async {
    setState(() {
      hasLoaded = false;
    });
    Completer<Null> completer = new Completer<Null>();
    List<Homework> homeworksNew = await HomeworkHelper().getHomeworks(
        globals.timeData[globals.selectedTimeForHomework], showErrors);
    if (homeworksNew.length > homeworks.length) homeworks = homeworksNew;
    homeworks
        .sort((Homework a, Homework b) => b.uploadDate.compareTo(a.uploadDate));
    if (mounted)
      setState(() {
        refHomework();
        hasLoaded = true;
        hasOfflineLoaded = true;
        completer.complete();
      });
    return completer.future;
  }

  Future<Null> _onRefreshOffline() async {
    setState(() {
      hasOfflineLoaded = false;
    });
    Completer<Null> completer = new Completer<Null>();
    homeworks = await HomeworkHelper()
        .getHomeworksOffline(globals.timeData[globals.selectedTimeForHomework]);
    homeworks
        .sort((Homework a, Homework b) => b.uploadDate.compareTo(a.uploadDate));
    if (mounted)
      setState(() {
        refHomework();
        hasOfflineLoaded = true;
        completer.complete();
      });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return new Column(
      children: <Widget>[
        new ListTile(
          title: new Text(
            selectedHomework[index].uploadDate.substring(0, 10) +
                " " +
                dateToWeekDay(
                    DateTime.parse(selectedHomework[index].uploadDate),
                    context) +
                (selectedHomework[index].subject == null
                    ? ""
                    : (" - " + selectedHomework[index].subject)),
            style: TextStyle(fontSize: 20.0),
          ),
          subtitle: new Html(
              data: HtmlUnescape().convert(selectedHomework[index].text)),
          isThreeLine: true,
          onTap: () {
            homeworksDialog(selectedHomework[index]);
          },
        ),
        new Divider(
          height: 5.0,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedHomework.clear();
    super.dispose();
  }
}
