import 'package:filcnaplo/Helpers/RequestHelper.dart';
import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/Datas/Lesson.dart';
import 'package:filcnaplo/globals.dart' as globals;
import '../Utils/StringFormatter.dart';

class NewHomeworkDialog extends StatefulWidget {
  const NewHomeworkDialog(this.lesson);
  final Lesson lesson;

  @override
  NewHomeworkDialogState createState() => NewHomeworkDialogState();
}

class NewHomeworkDialogState extends State<NewHomeworkDialog> {
  String homework;
  bool uploading = false;

  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: <Widget>[
          Text(capitalize(I18n.of(context).homeworkAdd)),
          Text(
              widget.lesson.subject +
                  " • " +
                  lessonToHuman(widget.lesson) +
                  capitalize(dateToWeekDay(widget.lesson.start, context)),
              style: TextStyle(
                  fontSize: 15,
                  color: globals.isDark ? Colors.grey : Colors.black54)),
          Divider(color: globals.isDark ? Colors.grey : Colors.black54)
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          onChanged: (String text) {
            homework = text;
          },
        ),
        uploading
            ? LinearProgressIndicator()
            : MaterialButton(
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
