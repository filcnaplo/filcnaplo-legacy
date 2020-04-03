import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/models/lesson.dart';
import 'package:filcnaplo/models/homework.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/utils/string_formatter.dart';
import 'package:filcnaplo/helpers/homework_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:filcnaplo/dialogs/homework_editor_dialog.dart';

class HomeworkDialog extends StatefulWidget {
  const HomeworkDialog(this.lesson);
  final Lesson lesson;

  @override
  HomeworkDialogState createState() => HomeworkDialogState();
}

class HomeworkDialogState extends State<HomeworkDialog> {
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lesson.subject),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(capitalize(I18n.of(context).lessonRoom) +
                ": " +
                widget.lesson.room),
            Text(capitalize(I18n.of(context).lessonTeacher) +
                ": " +
                widget.lesson.teacher),
            Text(capitalize(I18n.of(context).lessonClass) +
                ": " +
                widget.lesson.group),
            Text(capitalize(I18n.of(context).lessonStart) +
                ": " +
                getLessonStartText(widget.lesson)),
            Text(capitalize(I18n.of(context).lessonEnd) +
                ": " +
                getLessonEndText(widget.lesson)),
            widget.lesson.isMissed
                ? Text(capitalize(I18n.of(context).state) +
                    ": " +
                    widget.lesson.stateName)
                : Container(),
            (widget.lesson.theme != "" && widget.lesson.theme != null)
                ? Text(
                    I18n.of(context).lessonTheme + ": " + widget.lesson.theme)
                : Container(),
            widget.lesson.homework != null
                ? Text("\n" + capitalize(I18n.of(context).homework) + ": ")
                : Container(),
            widget.lesson.homework != null
                ? Divider(
                    color: Colors.blueGrey,
                  )
                : Container(),
            widget.lesson.homework != null
                ? Column(
                    children: globals.currentHomeworks.isEmpty
                        ? <Widget>[
                            Container(
                              child: CircularProgressIndicator(),
                              padding: EdgeInsets.all(20),
                            )
                          ]
                        : globals.currentHomeworks
                            .map<Widget>((Homework homework) {
                            return ListTile(
                              title: Html(
                                  data: HtmlUnescape().convert(homework.text)),
                              subtitle: Row(children: [
                                Text(
                                  homework.uploader,
                                  style: TextStyle(
                                      color: homework.byTeacher
                                          ? Colors.green
                                          : Colors.grey),
                                ),
                                Text(
                                  " | " + homework.uploadDate.substring(0, 10),
                                ),
                              ]),
                            );
                          }).toList(),
                  )
                : Container(),
          ],
        ),
      ),
      actions: <Widget>[
        (widget.lesson.homeworkEnabled && !widget.lesson.isMissed)
            ? FlatButton(
                child: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).pop();
                  return showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return NewHomeworkDialog(widget.lesson);
                        },
                      ) ??
                      false;
                },
              )
            : Container(),
        FlatButton(
          child: Text(I18n.of(context).dialogOk.toUpperCase()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void getHomeworks(Lesson lesson) async {
    globals.currentHomeworks.clear();
    globals.currentHomeworks =
        await HomeworkHelper().getHomeworksByLesson(lesson);
    setState(() {});
  }

  @override
  void initState() {
    if (widget.lesson.homework != null)
      getHomeworks(widget.lesson);
    else
      globals.currentHomeworks.clear();

    super.initState();
  }
}
