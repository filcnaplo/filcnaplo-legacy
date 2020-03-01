import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/helpers/timetable_helper.dart';
import 'package:filcnaplo/dialogs/add_homework_dialog.dart';

enum SearchFor { next, previous }
bool suppliedData;

class ChooseLessonDialog extends StatefulWidget {
  int searchForInt; //0: next, 1: previous
  String _subject;

  ChooseLessonDialog([int searchForInt, String _subject]) {
    suppliedData = true;

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
  _ChooseLessonDialogState createState() => _ChooseLessonDialogState();
}

class _ChooseLessonDialogState extends State<ChooseLessonDialog> {
  List<String> subjects = [];
  List<Lesson> lessons = [];
  DateTime now = DateTime.now();
  SearchFor _searchFor = SearchFor.next;

  Widget build(BuildContext context) {
    if (suppliedData) {
      if (widget.searchForInt == 0)
        _searchFor = SearchFor.next;
      else if (widget.searchForInt == 1) _searchFor = SearchFor.previous;
    }

    if (subjects.isEmpty) _getLessons();
    if (subjects.isNotEmpty &&
        !subjects.contains(widget._subject) &&
        widget._subject != "...") {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: I18n.of(context).chooseSubjectNotFound);
      throw ("No lesson is recorded with '" +
          widget._subject +
          "' subject next week."); // TODO: I18n
    }

    return SimpleDialog(
      title: Text(capitalize(I18n.of(context).homeworkAdd) + "..."),
      children: <Widget>[
        subjects.isEmpty
            ? Column(
                children: <Widget>[
                  Container(
                      width: 45,
                      height: 45,
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator()),
                  Text(I18n.of(context).chooseLoading),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                      leading: Radio(
                        value: SearchFor.next,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: Text(I18n.of(context).chooseNext)),
                  ListTile(
                      leading: Radio(
                        value: SearchFor.previous,
                        groupValue: _searchFor,
                        onChanged: (SearchFor value) {
                          setState(() {
                            _searchFor = value;
                          });
                        },
                      ),
                      title: Text(I18n.of(context).choosePrevious)),
                  Container(
                    child: DropdownButton<String>(
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
                  Text(
                    I18n.of(context).chooseForLesson,
                    style: TextStyle(fontSize: 15),
                  ),
                  Container(
                    child: FlatButton(
                      child: Text(I18n.of(context).chooseAdd.toUpperCase(),
                          style: TextStyle(
                              color: (widget._subject == "...")
                                  ? Colors.grey
                                  : Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold)),
                      onPressed: (widget._subject == "...")
                          ? null
                          : _openHomeworkDialog,
                    ),
                    margin: EdgeInsets.only(top: 10),
                  )
                ],
              ),
      ],
    );
  }

  void _openHomeworkDialog() async {
    if (_searchFor == SearchFor.next) {
      Navigator.of(context).pop();
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return NewHomeworkDialog(lessons.firstWhere(
                (Lesson lesson) => (lesson.subject == widget._subject && lesson.start.isAfter(now))));
          });
    } else {
      lessons.clear();
      lessons = await getLessons(
          now.subtract(Duration(days: 7)), now, globals.selectedUser, false);
      Navigator.of(context).pop();
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return NewHomeworkDialog(lessons.lastWhere(
                (Lesson lesson) => (lesson.subject == widget._subject && lesson.end.isBefore(now))));
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
