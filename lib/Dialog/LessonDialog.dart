import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/Datas/Homework.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/Utils/StringFormatter.dart';
import 'package:filcnaplo/Helpers/HomeworkHelper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'NewHomeworkDialog.dart';

class HomeworkDialog extends StatefulWidget {
  const HomeworkDialog(this.lesson);
  final Lesson lesson;

  @override
  HomeworkDialogState createState() => new HomeworkDialogState();
}

class HomeworkDialogState extends State<HomeworkDialog> {
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(widget.lesson.subject),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(capitalize(I18n.of(context).lessonRoom) +
                ": " +
                widget.lesson.room),
            new Text(capitalize(I18n.of(context).lessonTeacher) +
                ": " +
                widget.lesson.teacher),
            new Text(capitalize(I18n.of(context).lessonClass) +
                ": " +
                widget.lesson.group),
            new Text(capitalize(I18n.of(context).lessonStart) +
                ": " +
                getLessonStartText(widget.lesson)),
            new Text(capitalize(I18n.of(context).lessonEnd) +
                ": " +
                getLessonEndText(widget.lesson)),
            widget.lesson.isMissed
                ? new Text(capitalize(I18n.of(context).state) +
                    ": " +
                    widget.lesson.stateName)
                : new Container(),
            (widget.lesson.theme != "" && widget.lesson.theme != null)
                ? new Text(
                    I18n.of(context).lessonTheme + ": " + widget.lesson.theme)
                : new Container(),
            widget.lesson.homework != null
                ? new Text("\n" + capitalize(I18n.of(context).homework) + ": ")
                : Container(),
            widget.lesson.homework != null
                ? new Divider(
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
            ? new FlatButton(
                child: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).pop();
                  return showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return new NewHomeworkDialog(widget.lesson);
                        },
                      ) ??
                      false;
                },
              )
            : Container(),
        new FlatButton(
          child: new Text(I18n.of(context).dialogOk.toUpperCase()),
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
