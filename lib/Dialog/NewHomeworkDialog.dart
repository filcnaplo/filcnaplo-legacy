import 'dart:html';

import 'package:filcnaplo/Dialog/ChooseLessonDialog.dart';
import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import '../Utils/StringFormatter.dart';
import '../Datas/User.dart';

class NewHomeworkDialog extends StatefulWidget {
  const NewHomeworkDialog(this.lesson);
  final Lesson lesson;

  @override
  NewHomeworkDialogState createState() => new NewHomeworkDialogState();
}

class NewHomeworkDialogState extends State<NewHomeworkDialog> {
  String homework;
  bool uploading = false;

  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: Column(
        children: <Widget>[
          new Text(capitalize(I18n.of(context).homeworkAdd)),
          new Text(
              widget.lesson.subject +
                  " • " +
                  lessonToHuman(widget.lesson) +
                  capitalize(dateToWeekDay(widget.lesson.start, context)),
              style: new TextStyle(
                  fontSize: 15,
                  color: globals.isDark ? Colors.grey : Colors.black54)),
          new Divider(color: globals.isDark ? Colors.grey : Colors.black54)
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          onChanged: (String text) {
            homework = text;
          },
        ),
        uploading
            ? new LinearProgressIndicator()
            : new MaterialButton(
                child: Text(I18n.of(context).dialogOk.toUpperCase()),
                onPressed: _uploadHomework,
              )
      ],
    );
  }

  void _uploadHomework() async {
    setState(() {
      uploading = true;
    });

    if (await RequestHelper().uploadHomework(
        homework, widget.lesson, globals.selectedAccount.user)) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        uploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
