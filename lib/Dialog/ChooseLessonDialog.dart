//Contributed by RedyAu

import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import '../Utils/StringFormatter.dart';
import '../Datas/Lesson.dart';
import '../Helpers/TimetableHelper.dart';
import '../Dialog/NewHomeworkDialog.dart';

enum SearchFor { next, previous }
bool suppliedData = true;

class ChooseLessonDialog extends StatefulWidget {
  int searchForInt; //0: next, 1: previous
  String _subject;

  ChooseLessonDialog([int searchForInt, String _subject]) {
    if (searchForInt == null) {
      searchForInt = 0;
      suppliedData = false;
    }
    this.searchForInt = searchForInt;

    if (_subject == null) {
      _subject = "...";
      suppliedData = false;
    }
    this._subject = _subject;
  }

  @override
  _ChooseLessonDialogState createState() => new _ChooseLessonDialogState();
}

class _ChooseLessonDialogState extends State<ChooseLessonDialog> {
  List<String> subjects = [];
  List<Lesson> lessons = [];
  DateTime now = new DateTime.now();
  SearchFor _searchFor;

  Widget build(BuildContext context) {
    if (suppliedData) {
      if (widget.searchForInt == 0)
        _searchFor = SearchFor.next;
      else if (widget.searchForInt == 1) _searchFor = SearchFor.previous;
    } else _searchFor = SearchFor.next;

    if (subjects.isEmpty) _getLessons();
    if (subjects.isNotEmpty &&
        !subjects.contains(widget._subject) &&
        widget._subject != "...") {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Nincs ilyen tantárgyú órád a következő 7 napban.");
      throw ("No lesson is recorded with '" +
          widget._subject +
          "' subject next week.");
    }

    return new SimpleDialog(
      title: new Text(capitalize(I18n.of(context).homeworkAdd) + "..."),
      children: <Widget>[
        subjects.isEmpty
            ? Column(
                children: <Widget>[
                  Container(
                      width: 45,
                      height: 45,
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator()),
                  Text("Órák betöltése..."),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new ListTile(
                      leading: new Radio(
                        value: SearchFor.next,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: new Text("a következő")),
                  new ListTile(
                      leading: new Radio(
                        value: SearchFor.previous,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: new Text("a legutóbbi")),
                  new Container(
                    child: new DropdownButton<String>(
                      value: widget._subject,
                      items: subjects.map((String subject) {
                        return DropdownMenuItem<String>(
                            value: subject, child: Text(capitalize(subject)));
                      }).toList(),
                      onChanged: (String selectedSubject) {
                        setState(() {
                          widget._subject = selectedSubject;
                        });
                      },
                    ),
                  ),
                  new Text(
                    "órához",
                    style: new TextStyle(fontSize: 15),
                  ),
                  Container(
                    child: new FlatButton(
                      child: new Text("MEGNYITÁS",
                          style: new TextStyle(
                              color: (widget._subject == "...")
                                  ? Colors.grey
                                  : Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold)),
                      onPressed: (widget._subject == "...")
                          ? null
                          : _openHomeworkDialog,
                    ),
                    margin: new EdgeInsets.only(top: 10),
                  )
                ],
              ),
      ],
    );
  }

  void _openHomeworkDialog() async {
    Navigator.of(context).pop();
    if (_searchFor == SearchFor.next) {
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new NewHomeworkDialog(lessons.firstWhere(
                (Lesson lesson) => (lesson.subject == widget._subject)));
          });
    } else {
      lessons.clear();
      lessons = await getLessons(
          now.subtract(Duration(days: 7)), now, globals.selectedUser, false);
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return new NewHomeworkDialog(lessons.lastWhere(
                (Lesson lesson) => (lesson.subject == widget._subject)));
          });
    }
  }

  void _getLessons() async {
    lessons = await getLessons(
        now, now.add(Duration(days: 7)), globals.selectedUser, false);
    for (Lesson lesson in lessons) {
      if (!subjects.contains(lesson.subject)) subjects.add(lesson.subject);
    }
    subjects.sort((a, b) => a.compareTo(b));
    subjects.insert(0, "...");
    setState(() {});
    if (suppliedData) {
      _openHomeworkDialog();
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
